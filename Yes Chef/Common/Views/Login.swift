//
//  Login.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/7/25.
//

import Foundation
import SwiftUI

struct Login: View {
    @Environment(AuthenticationVM.self) private var authVM
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    Task {
                        await authVM.login(email: email, password: password)
                    }
                }) {
                    if authVM.isLoading {
                        Text("Loading...")
                    } else {
                        Text("Log In")
                            .bold()
                    }
                }
                .padding()
                
                NavigationLink("Register Instead") {
                    Register()
                }
            }
            .padding()
    }
}

#Preview {
    Login()
}
