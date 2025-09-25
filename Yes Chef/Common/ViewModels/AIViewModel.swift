//
//  AIViewModel.swift
//  Yes Chef
//
//  Created by Nitya Potti on 9/22/25.
//

import Foundation
import Observation
import FirebaseFirestore

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
    func suggestIngredients(title: String, description:String) {
        
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
        Your task is to create a catchy, natural description based on the recipe title provided. 
        The description should be around 200 characters and should sound as humanly as possible. Focus on the main ingredients, the flavor profile, and the type of dish. 
        Highlight the taste, key ingredients, and style of the dish. Return only the description in plain text.
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
    
}
