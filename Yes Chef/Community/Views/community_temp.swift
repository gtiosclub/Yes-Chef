//
//  temp.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/7/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                // Change Password Button
                Button(action: {
                    // Code to change password
                }) {
                    Text("Change Password")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Change Username Button
                Button(action: {
                    // Code to change username
                }) {
                    Text("Change Username")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Delete Account Button
                Button(action: {
                    // Code to delete account
                }) {
                    Text("Delete Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
}
