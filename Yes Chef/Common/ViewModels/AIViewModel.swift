//
//  AIViewModel.swift
//  Yes Chef
//
//  Created by Nitya Potti on 9/22/25.
//

import Foundation
import Observation
import FirebaseFirestore


struct ToolCallEntry: Codable {
    let item: String
    let removing: [String]
    let adding: [String]
    
}

struct SmartSuggestion: Codable {
    let toolcall: [ToolCallEntry]
    let message: String
}

@Observable class AIViewModel {
    var openAIKey: String?
    let db = Firestore.firestore()
    init()  {
        fetchAPIKey()
    }
    private func fetchAPIKey() {
        Task {
            do {
                let document = try await db.collection("APIKEYS").document("OpenAI").getDocument()
                if let data = document.data(), let key = data["key"] as? String {
                    DispatchQueue.main.async {
                        self.openAIKey = key
                    }
                } else {
                    print("No key found in document")
                }
            } catch {
                print("Error fetching API key from Firestore: \(error)")
            }
        }
    }
    
    
//      =================== EXAMPLE ================
    
//    func suggestPostCategories(question: String, captions: [String], completion: @escaping (([Category]) -> Void)) {
//        let categories: [String] = Category.allCategoryStrings
//        
//        let systemPrompt = """
//            You are a classifier that assigns categories to a post based on 
//            a post's question and its captions. 
//            Only respond with valid categories from the provided list. 
//            Do not create new categories. Return the answer as a JSON array.
//            """
//        
//        let userPrompt = """
//            Question: \(question)
//            Captions: \(captions.joined(separator: ", "))
//            Valid Categories: \(categories.joined(separator: ", "))
//
//            Provide the category list as a JSON array without using any
//            markdown or coding blocks, just the raw string value.
//            """
//        
//        let parameters: [String: Any] = [
//           "model": "gpt-4o-mini",
//           "messages": [
//                ["role": "system", "content": systemPrompt],
//                ["role": "user", "content": userPrompt]
//           ],
//           "temperature": 0.2
//        ]
//        
//        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
//            print("Invalid URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(self.openAIKey)", forHTTPHeaderField: "Authorization")
//        
//        do {
//            print("body created")
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
//        } catch {
//            print("Error serializing request body: \(error)")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error querying OpenAI: \(error)")
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received from OpenAI")
//                return
//            }
//            
//            do {
//                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let choices = jsonResponse["choices"] as? [[String: Any]],
//                   let message = choices[0]["message"] as? [String : Any],
//                   let content = message["content"] as? String,
//                   let jsonData = content.data(using: .utf8),
//                   let rawCategories = try? JSONDecoder().decode([String].self, from: jsonData).filter({ categories.contains($0) }) {
//                    let suggestedCategories = Category.mapStringsToCategories(returnedStrings: rawCategories)
//                    completion(suggestedCategories)
//                } else {
//                    print("Incorrect response formatting")
//                }
//            } catch {
//                print("Error parsing OpenAI response: \(error)")
//            }
//        }.resume()
//    }
    
    
    func catchyDescription(title: String) async -> String? {
        let prompt = """
        You are a friendly food writer. Given a recipe title, write a short, simple, human-sounding description (1–2 sentences). Focus on the main ingredients and flavors. Make it easy to read, casual, and appetizing. Make it sound like a 10th grader. It should be personalized. Add a personalized word before the dish name. Return only the description in plain text. Example. "This pasta will be the greatest dish you have eaten. Must try on any occasion, with the chance to blow your tastebuds out the water"
        """

        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": prompt],
                ["role": "user", "content": title]
            ],
            "temperature": 0.2
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.openAIKey ?? "")", forHTTPHeaderField: "Authorization")

        do {
            print("body created")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let message = choices[0]["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("Unexpected response format")
                return nil
            }
            
            return content
            
        } catch {
            print("Error querying OpenAI: \(error)")
            return nil
        }
    }
    func suggestWeeklyChallenge(completion: @escaping (String?) -> Void) {
        let systemPrompt = """
        You are a creative chef. Generate a weekly cooking challenge meal idea. 
        Keep it short (1–2 sentences, under 200 characters). 
        Return only plain text, no markdown or code blocks.
        """

        let userPrompt = """
        Please suggest one weekly challenge meal idea that is fun, creative, 
        and encourages home cooks to try something new.
        """

        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.openAIKey ?? "")", forHTTPHeaderField: "Authorization")

        do {
            print("body created")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error querying OpenAI: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received from OpenAI")
                completion(nil)
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let message = choices[0]["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    print("Unexpected response format")
                    completion(nil)
                }
            } catch {
                print("Error parsing response: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func smartSuggestion(recipe: Recipe, userMessage: String) async throws -> SmartSuggestion {
        guard let key = self.openAIKey, !key.isEmpty else {
            throw NSError(domain: "AIViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "OpenAI API key not loaded yet"])
        }

        let body = ChatRequest(
            model: "gpt-4o-mini",
            response_format: ["type": "json_object"],
            temperature: 0.2,
            messages: [
                .init(role: "system", content: smartSystemPrompt),
                .init(role: "user", content: smartUserContent(recipe: recipe, userMessage: userMessage))
            ]
        )

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw NSError(domain: "AIViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let serverText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "AIViewModel", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: serverText])
        }

        struct ChatResponse: Decodable {
            struct Choice: Decodable {
                struct Msg: Decodable { let content: String }
                let message: Msg
            }
            let choices: [Choice]
        }

        let chat = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = chat.choices.first?.message.content.data(using: .utf8) else {
            throw NSError(domain: "AIViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Empty response content"])
        }

        do {
            return try JSONDecoder().decode(SmartSuggestion.self, from: content)
        } catch {
            let raw = String(data: content, encoding: .utf8) ?? ""
            print("SmartSuggestion JSON decoding failed. Raw content:\n\(raw)")
            throw error
        }
    }

    
}

private struct ChatRequest: Encodable {
    let model: String
    let response_format: [String:String]
    let temperature: Double
    let messages: [ChatMessage]
}

private struct ChatMessage: Encodable {
    let role: String
    let content: String
}


private let smartSystemPrompt = """
You are a culinary assistant that edits recipes to satisfy user constraints (dietary needs, allergies, preferences) with minimal, smart changes.

Return ONLY valid JSON with this exact shape and key names (no markdown, no extra text):
{
  "toolcall": [
    { "item": "ingredients|title|allergens|steps|tags|description|<specific-ingredient>",
      "removing": ["..."],
      "adding": ["..."]
    }
  ],
  "message": "short, friendly explanation"
}

Rules:
- Use arrays for both "removing" and "adding" (use [] if none).
- Prefer substitutions over deletions when feasible.
- Keep cuisine and texture intact, propose common grocery items.
- If the request conflicts with the dish, make conservative edits and explain in "message".
- If an ingredient is removed or replaced, update any step that mentions it.
"""

private func smartUserContent(recipe: Recipe, userMessage: String) -> String {
    let ingredientsArray = recipe.ingredients.map { ing -> [String: Any] in
        return [
            "name": ing.name,
            "quantity": ing.quantity,
            "unit": ing.unit,
            "preparation": ing.preparation
        ]
    }
    
    let payload: [String: Any] = [
        "user_request": userMessage,
        "recipe": [
            "name": recipe.name,
            "ingredients": ingredientsArray,
            "allergens": recipe.allergens,
            "tags": recipe.tags,
            "steps": recipe.steps,
            "description": recipe.description,
            "prepTime": recipe.prepTime,
            "difficulty": recipe.difficulty.rawValue
        ],
        "examples": [
            [
                "user_request": "Make it vegetarian",
                    "expected": [
                        [
                            "item": "ingredients",
                            "removing": ["chicken"],
                            "adding": ["tofu"]
                        ],
                        [
                            "item": "steps",
                            "removing": ["Stir-fry chicken"],
                            "adding": ["Sauté tofu until golden"]
                        ]
                    ]
            ],
            [
                "user_request": "I can't eat peanuts",
                "expected": [
                    ["item":"ingredients","removing":["peanuts","peanut oil"],"adding":["toasted pumpkin seeds","avocado oil"]],
                    ["item":"allergens","removing":["peanuts"],"adding":[]]
                ]
            ]
        ]
    ]
    let data = try! JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
    return String(data: data, encoding: .utf8)!
}
