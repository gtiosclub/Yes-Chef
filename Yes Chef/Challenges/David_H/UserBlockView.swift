//
//  UserBlockView.swift
//  Yes Chef
//
//  Created by David Huang on 9/18/25.
//

import SwiftUI
import UIKit
import Firebase

struct UserBlockView: View {
    //Placeholders
    var profilepicture: String = "person.circle.fill"
    var username: String = "James"
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
                Text(username)
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
    UserBlockView()
}
