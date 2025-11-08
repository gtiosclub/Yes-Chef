//
//  AIChefBaseView.swift
//  Yes Chef
//
//  Created by RushilC on 10/21/25.
//

import SwiftUI

struct AIChefBaseView: View {
    @State private var userMessage: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State var recipeVM: CreateRecipeVM
    
    let suggestions = [
        "Make it easier to cook with less steps",
        "Change ingredients to be vegetarian",
        "Make it peanut-free",
        "Add a low-carb option",
        "Make it spicier"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: AI Calls
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(recipeVM.messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    
                    if recipeVM.isThinking {
                        HStack {
                            TypingIndicator()
                                .padding(10)
                                .background(Color(hex: "#F5F2F0"))
                                .cornerRadius(16)
                            Spacer()
                            }
                            .transition(.opacity)
                            .animation(.easeInOut, value: recipeVM.isThinking)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
                if recipeVM.messages.isEmpty {
                    VStack(spacing: 8) {
                        Text("How can I help you cook?")
                            .font(.custom("Georgia", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#453736"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: 295, alignment: .center)
                            .position(x: 49 + 295/2, y: 213 + 72/2)
                    }
                }
            }
            
            VStack(spacing: 8) {
                
                if recipeVM.toolcall == nil {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Text(suggestion)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "#E3EFD8"))
                                    .foregroundColor(.primary)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 5)
                }
                
                HStack(spacing: 8) {
                    TextField("Chat with AI Chef…", text: $userMessage)
                        .padding(10)
                        .background(Color(hex: "#F9F5F2"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                        .focused($isTextFieldFocused)
                        .submitLabel(.send)
                        .onSubmit{
                            Task {
                                await recipeVM.sendMessage(userMessage: userMessage)
                                userMessage = ""
                                isTextFieldFocused = false
                            }
                        }
                    
                    Button {
                        Task {
                            await recipeVM.sendMessage(userMessage: userMessage)
                            userMessage = ""
                            isTextFieldFocused = false
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(userMessage.isEmpty ? Color(hex: "#FFCB88") : Color(hex: "#FFA947"))
                    }
                    .disabled(userMessage.isEmpty || recipeVM.isThinking)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 6)
            
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(Color(hex: "#FFFFFC"))
    }
}

#Preview {
    AIChefBaseView(recipeVM: CreateRecipeVM())
}

