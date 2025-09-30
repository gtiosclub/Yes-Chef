//
//  ChallengeTesterView.swift
//  Yes Chef
//
//  Created by Yifan Wang on 9/25/25.
//

import SwiftUI

struct ChallengeTesterView: View {
    // Use Observation’s model with @State
    @State private var ai = AIViewModel()
    
    @State private var isLoading = false
    @State private var output: String = "Tap a button to test."
    
    // For catchyDescription()
    @State private var recipeTitle: String = "Spicy Garlic Lemon Pasta"
    
    @State private var showNoKeyAlert = false
    
    var body: some View {
        VStack(spacing: 18) {
            // MARK: – Result
            ScrollView {
                Text(output)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(maxHeight: 220)
            
            // MARK: – catchyDescription input
            VStack(alignment: .leading, spacing: 8) {
                Text("Recipe Title")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextField("Enter a recipe title…", text: $recipeTitle)
                    .textFieldStyle(.roundedBorder)
            }
            
            // MARK: – Buttons
            VStack(spacing: 12) {
                Button {
                    runWeeklyChallenge()
                } label: {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("Get Weekly Challenge (chat.completions)")
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    runCatchyDescription()
                } label: {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("Generate Catchy Description (async)")
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .navigationTitle("Challenge Tester")
        .alert("OpenAI key not loaded yet", isPresented: $showNoKeyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Waiting for Firestore to return the API key. Try again in a moment.")
        }
    }
    
    // MARK: – Actions
    private func ensureKey() -> Bool {
        if (ai.openAIKey ?? "").isEmpty {
            showNoKeyAlert = true
            return false
        }
        return true
    }
    
    private func runWeeklyChallenge() {
        guard ensureKey() else { return }
        isLoading = true
        output = "Requesting weekly challenge…"
        
        ai.suggestWeeklyChallenge { result in
            DispatchQueue.main.async {
                self.isLoading = false
                self.output = result ?? "No challenge received / unexpected response."
            }
        }
    }
    
    private func runCatchyDescription() {
        guard ensureKey() else { return }
        isLoading = true
        output = "Generating description…"
        
        Task {
            let text = await ai.catchyDescription(title: recipeTitle)
            await MainActor.run {
                self.isLoading = false
                self.output = text ?? "No description received / unexpected response."
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChallengeTesterView()
    }
}
