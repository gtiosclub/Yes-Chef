//
//  UserBlockView.swift
//  Yes Chef
//
//  Created by David Huang on 9/18/25.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore

struct UserBlockViewDH: View {
    @ObservedObject var userBlockView: UserBlockViewModelDH
    //Placeholders
    var profilepicture: String = "person.circle.fill"
    var signitureDish: String = "Pasta"

    var body: some View {
        HStack {
            //pfp
            Image(systemName: profilepicture)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .foregroundStyle(.blue)
            //name
            VStack (alignment: .leading, spacing: 4){
                Text(userBlockView.user?.username ?? "")
                    .font(.headline)
                    .foregroundStyle(.blue)
                //signiture dish/most famous dish
                Text("SignitureDish: \(signitureDish)")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.3), radius: 5)
        )
        .padding(.horizontal)
    }
}

#Preview {
    let mockUser = User(userId: "1", username: "John", email: "john@example.com")
    let mockVM = UserBlockViewModelDH(mockUser: mockUser)
    
    UserBlockViewDH(userBlockView: mockVM)
}

//class AppDelegate: NSObject, UIApplicationDelegate {
//   func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        return true
//    }
//}
