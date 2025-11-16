/**
 * Weekly Challenge Reset Function
 * Runs every Sunday at 12 AM (America/New_York)
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import OpenAI from "openai";

admin.initializeApp();
const db = admin.firestore();

export const weeklyChallengeReset = onSchedule(
  {
    schedule: "12 13 * * 0",
    timeZone: "America/New_York",
  },
  async (event) => {
    console.log("Starting weekly challenge reset");

    try {
      const keyDoc = await db.collection("APIKEYS").doc("OpenAI").get();
      const apiKey = keyDoc.exists ? (keyDoc.data()?.key as string) : null;

      if (!apiKey) {
        console.error("No OpenAI API key found in Firestore!");
        return;
      }

      const openai = new OpenAI({ apiKey });

      const weeklyDoc = await db.collection("weeklyChallenge").doc("current").get();
      const currentPrompt = weeklyDoc.exists
        ? (weeklyDoc.data()?.prompt as string)
        : "Create your best dish!";

      console.log("Current prompt:", currentPrompt);

      const submissionsSnap = await db.collection("CURRENT_CHALLENGE_SUBMISSIONS").get();
      console.log("Submissions fetched:", submissionsSnap.size);
      submissionsSnap.forEach((doc) => {
        console.log("Submission found:", doc.id, doc.data());
      });
      const submissions = submissionsSnap.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        
      }));
      console.log("Found ${submissions.length} submissions");

      const archiveData = {
        prompt: currentPrompt,
        submissions,
        archivedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      await db.collection("CHALLENGEHISTORY").add(archiveData);
      console.log("Archived current challenge to CHALLENGEHISTORY");


      console.log("Generating new weekly challenge prompt with OpenAI");

      const completion = await openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content:
              "You are a creative chef. Generate a short (1–2 sentences) weekly cooking challenge idea under 200 characters.",
          },
          {
            role: "user",
            content:
              "Please suggest one fun, creative weekly cooking challenge that encourages home cooks to try something new.",
          },
        ],
        temperature: 0.7,
      });

      const newPrompt =
        completion.choices[0].message?.content?.trim() ||
        "Create your best comfort dish!";

      console.log("Generated new prompt:", newPrompt);

      const batch = db.batch();
      submissionsSnap.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
      console.log("Cleared CURRENT_CHALLENGE_SUBMISSIONS");


      await db.collection("weeklyChallenge").doc("current").set(
        {
          prompt: newPrompt,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      console.log("Updated weekly challenge prompt");
      console.log("Weekly reset complete!");
    } catch (error) {
      console.error("Weekly challenge reset failed:", error);
    }
  }
);
