//
//  Register.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/7/25.
//

import Foundation
import SwiftUI

struct Register: View {
//    @Environment(AuthenticationVM.self) private var authVM
    @State private var authVM = AuthenticationVM()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let errorMessage = authVM.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Register"){
                    authVM.register(email: email, password: password)
                }
                .padding()
                
                NavigationLink("Log in Instead") {
                    Login()
                }
            }
            .padding()
        }
    }
}

#Preview {
    Login()
}
