//
//  AccountCreationView.swift
//  Yes Chef
//
//  Created by Kushi Kashyap on 9/23/25.
//

import SwiftUI

struct AccountCreationView : View {
    @State private var nameText = ""
    @State private var usernameText = ""
    @State private var emailText = ""
    @State private var phoneNumberText = ""
    @State private var passwordText = ""
    @State private var confirmPasswordText = ""
    @State private var errorMessage: String?
    @State private var viewModel = AuthenticationVM()
    
    var body: some View {
        VStack {
            Text("Create an account")
                .frame(maxWidth: .infinity)
                .font(.largeTitle)
                .padding(.bottom, 5)
            HStack {
                Text("Full Name")
                    .frame(maxWidth: 125, alignment: .leading)
                TextField("", text: $nameText)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    .padding(.horizontal)
                    .frame(maxWidth: 300, alignment: .trailing)
            }
            .frame(maxWidth: 350)
            .padding(7)
            HStack {
                Text("Username")
                    .frame(maxWidth: 125, alignment: .leading)
                TextField("", text: $usernameText)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    .padding(.horizontal)
                    .frame(maxWidth: 300, alignment: .trailing)
            }
            .frame(maxWidth: 350)
            .padding(7)
            HStack {
                Text("Email")
                    .frame(maxWidth: 125, alignment: .leading)
                TextField("", text: $emailText)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    .padding(.horizontal)
                    .frame(maxWidth: 300, alignment: .trailing)
            }
            .frame(maxWidth: 350)
            .padding(7)
            HStack {
                Text("Phone Number")
                    .frame(maxWidth: 125, alignment: .leading)
                TextField("", text: $phoneNumberText)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    .padding(.horizontal)
                    .frame(maxWidth: 300, alignment: .trailing)
            }
            .frame(maxWidth: 350)
            .padding(7)
            HStack {
                Text("Password")
                    .frame(maxWidth: 125, alignment: .leading)
                TextField("", text: $passwordText)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    .padding(.horizontal)
                    .frame(maxWidth: 300, alignment: .trailing)
            }
            .frame(maxWidth: 350)
            .padding(7)
            HStack {
                Text("Confirm Password")
                    .frame(maxWidth: 125, alignment: .leading)
                TextField("", text: $confirmPasswordText)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    .padding(.horizontal)
                    .frame(maxWidth: 300, alignment: .trailing)
            }
            .frame(maxWidth: 350)
            .padding(7)
            Button("Confirm") {
                if confirmPasswordText != passwordText {
                    errorMessage = "Passwords do not match."
                } else if !emailText.isValidEmail {
                    errorMessage = "Please enter a valid email."
                } else if !phoneNumberText.isValidPhone {
                    errorMessage = "Please enter a valid phone number."
                } else {
                    errorMessage = nil
                    viewModel.register(email: emailText, password: passwordText, username: usernameText)
                }
                viewModel.register(email: emailText, password: passwordText, username: usernameText)
            }
            .bold()
            .padding(.top, 5)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
        .padding(.bottom, 100)
    }
}
extension String {
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        // Example: 10-digit US phone number
        let regex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
#Preview {
    AccountCreationView()
}
