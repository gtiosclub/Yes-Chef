//
//  AccountCreationView.swift
//  Yes Chef
//
//  Created by Kushi Kashyap on 9/23/25.
//

import SwiftUI

struct AccountCreationView : View {
    @State private var selectedTab = "Sign Up"
    
    var body: some View {
        VStack {
            VStack {
                Text("Welcome to Yes Chef!")
                    .font(.system(size:30, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                Text("Sign up or login below")
                    .font(.system(.subheadline))
                    .foregroundColor(.gray)
                HStack(spacing: 0) {
                    Button(action: { selectedTab = "Login" }) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(selectedTab == "Login" ? Color(.systemGray6) : Color(.systemGray5))
                            .foregroundColor(.black)
                    }
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20)))
                    Button(action: { selectedTab = "Sign Up" }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(selectedTab == "Sign Up" ? Color(.systemGray6) : Color(.systemGray5))
                            .foregroundColor(.black)
                    }
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20)))
                }
            }
            .padding(.horizontal)
            if selectedTab == "Sign Up" {
                NewRegister()
            } else {
                NewLogin()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 100)
    }
}
struct NewRegister : View {
    @State private var nameText = ""
    @State private var usernameText = ""
    @State private var emailText = ""
    @State private var phoneNumberText = ""
    @State private var passwordText = ""
    @State private var confirmPasswordText = ""
    @State private var nameErrorMessage: String?
    @State private var emailErrorMessage: String?
    @State private var phoneErrorMessage: String?
    @State private var passwordErrorMessage: String?
    @State private var confirmPasswordErrorMessage: String?
    @State private var error: Bool = false
    @State private var viewModel = AuthenticationVM()
    var body : some View {
            TextField("Enter your name", text: $nameText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.top, 20)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            if let nameErrorMessage = nameErrorMessage {
                Text(nameErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
            }
            TextField("Enter your email", text: $usernameText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            if let emailErrorMessage = emailErrorMessage {
                Text(emailErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
            }
            SecureField("Enter your password", text: $passwordText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            if let passwordErrorMessage = passwordErrorMessage {
                Text(passwordErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
            }
            SecureField("Confirm your password", text: $confirmPasswordText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            if let confirmPasswordErrorMessage = confirmPasswordErrorMessage {
                Text(confirmPasswordErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
            }
            Button(action: {
                if nameText.isEmpty {
                    nameErrorMessage = "Please enter a name."
                }
                if !passwordText.isValidPassword {
                    passwordErrorMessage = "- 8 characters minimum, 25 characters maximum \n- at least 1 uppercase, 1 lowercase, 1 number, 1 special character (# ? ! @)"
                    error = true
                }
                if confirmPasswordText != passwordText {
                    confirmPasswordErrorMessage = "Passwords do not match."
                    error = true
                }
                if !emailText.isValidEmail {
                    emailErrorMessage = "Please enter a valid email."
                    error = true
                }
                if !phoneNumberText.isValidPhone {
                    phoneErrorMessage = "Please enter a valid phone number."
                    error = true
                }
                if !error {
                    passwordErrorMessage = nil
                    confirmPasswordErrorMessage = nil
                    emailErrorMessage = nil
                    phoneErrorMessage = nil
                    viewModel.register(email: emailText, password: passwordText, username: usernameText)
                }
            }) {
                Text("Sign Up")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 40)
        }
    }
struct NewLogin: View {
    @Environment(AuthenticationVM.self) private var authVM
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                Button(action: {
                    Task {
                        await authVM.login(email: email, password: password)
                    }
                }) {
                    if authVM.isLoading {
                        Text("Loading...")
                    } else {
                        Text("Log In")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                }
                .padding()
            }
            .padding()
    }
}
extension String {
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        let regex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    var isValidPassword: Bool {
        if (self.count >= 8 && self.count <= 25 && (self.contains("#") || self.contains("?") || self.contains("!") || self.contains("@")) && self.containsUppercase() && self.containsLowercase()) {
            return true;
        } else {
            return false
        }
    }
    func containsUppercase() -> Bool {
        for character in self {
            if character.isUppercase {
                return true
            }
        }
        return false
    }
    func containsLowercase() -> Bool {
        for character in self {
            if character.isLowercase {
                return true
            }
        }
        return false
    }
}
#Preview {
    AccountCreationView()
}
