//
//  AccountCreationView.swift
//  Yes Chef
//
//  Created by Kushi Kashyap on 9/23/25.
//

import SwiftUI

struct AccountCreationView : View {
    @State private var selectedTab = "Login"
    
    
    var body: some View {
        VStack {
            VStack {
                Text("Welcome to Yes Chef!")
                    .font(.system(size:30, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                Text("Sign up or login below")
                    .font(.system(.subheadline))
                    .foregroundColor(.gray)

                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .frame(height: 56)

                    HStack(spacing: 0) {
                        Button(action: { selectedTab = "Login" }) {
                            VStack(spacing: 8) {
                                Text("Login")
                                    .font(.body)
                                    .fontWeight(selectedTab == "Login" ? .semibold : .regular)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.bottom , 10)
                        .frame(maxWidth: .infinity)
                        .zIndex(selectedTab == "Login" ? 1 : 0)
                        .background(
                            RoundedCorner(radius: 25, corners: selectedTab == "Login" ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                                .fill(selectedTab == "Login" ? Color.white : Color(.systemGray6))
                                .frame(width: (UIScreen.main.bounds.width)/2, height: 50)
                                .background(
                                    RoundedCorner(radius: 25, corners: selectedTab == "Login" ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                                        .fill(Color(.systemGray4))
                                        .frame(width: (UIScreen.main.bounds.width)/2 + 1, height: 50)
                                        .padding(selectedTab == "Login" ? .bottom : .top, 3)
                                        .overlay(
                                            Rectangle()
                                                .fill(Color.white)
                                                .padding(selectedTab == "Login" ? .top : .bottom, 35)
                                        )
                                )
                        )

                        Button(action: { selectedTab = "Sign Up" }) {
                            VStack(spacing: 8) {
                                Text("Sign Up")
                                    .font(.body)
                                    .fontWeight(selectedTab == "Sign Up" ? .semibold : .regular)
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .zIndex(selectedTab == "Sign Up" ? 2 : 0)
                        .background(
                            RoundedCorner(radius: 25, corners: selectedTab == "Sign Up" ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft,.topRight,.topLeft])
                                .fill(selectedTab == "Sign Up" ? Color.white : Color(.systemGray6))
                                .frame(width: (UIScreen.main.bounds.width)/2, height: 50)
                                .background(
                                    RoundedCorner(radius: 25, corners: selectedTab == "Sign Up" ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft,.topRight,.topLeft])
                                        .fill(Color(.systemGray4))
                                        .frame(width: (UIScreen.main.bounds.width)/2 + 1, height: 50)
                                        .padding(selectedTab == "Sign Up" ? .bottom : .top, 3)
                                        .overlay(
                                            Rectangle()
                                                .fill(Color.white)
                                                .padding(selectedTab == "Sign Up" ? .top : .bottom, 35)
                                        )
                                )
                        )
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 0)
                }


            }
            if selectedTab == "Sign Up" {
                NewRegister()
            } else {
                NewLogin()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 100)
        .navigationBarHidden(false)
        .preferredColorScheme(.light)

    }
}
struct NewRegister : View {
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
    @Environment(AuthenticationVM.self) private var authVM
    var body : some View {
            TextField("Enter your name", text: $usernameText)
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
            TextField("Enter your email", text: $emailText)
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
                .textContentType(.none)
                .autocapitalization(.none)
                .disableAutocorrection(true)
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
                .textContentType(.none)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            if let confirmPasswordErrorMessage = confirmPasswordErrorMessage {
                Text(confirmPasswordErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
            }
            Button(action: {
                error = false
                nameErrorMessage = nil
                emailErrorMessage = nil
                phoneErrorMessage = nil
                passwordErrorMessage = nil
                confirmPasswordErrorMessage = nil
                
                if usernameText.isEmpty {
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
//                if !phoneNumberText.isValidPhone {
//                    phoneErrorMessage = "Please enter a valid phone number."
//                    error = true
//                }
                if !error {
                    passwordErrorMessage = nil
                    confirmPasswordErrorMessage = nil
                    emailErrorMessage = nil
                    phoneErrorMessage = nil
                    authVM.register(email: emailText, password: passwordText, username: usernameText)
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
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    .textContentType(.none)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Button(action: {
                    Task {
                        await authVM.login(email: email, password: password)
                    }
                }) {
                    if authVM.isLoading {
                        Text("Loading...")
                            .foregroundColor(.gray)
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
// MARK: - Custom Shapes
fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    AccountCreationView()
}
