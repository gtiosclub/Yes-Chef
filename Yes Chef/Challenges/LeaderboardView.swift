import SwiftUI
import Foundation
import Firebase

import Foundation

import Foundation

struct UserTest: Identifiable {
    let id: String            // Firebase UID or UUID
    let username: String
    let profileImageURL: String? // optional for avatars later
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let user: UserTest
    let recipeName: String
    let datePosted: Date
}

struct LeaderboardView: View {
    // Sample data for testing
    let entries: [LeaderboardEntry] = (1...10).map { i in
        let user = UserTest(
            id: UUID().uuidString,
            username: "User \(i)",
            profileImageURL: nil
        )
        
        return LeaderboardEntry(
            rank: i,
            user: user,
            recipeName: "Recipe \(i)",
            datePosted: Date().addingTimeInterval(-Double(i) * 86400)
        )
    }

    var body: some View {
        VStack{
            ZStack {
                HStack(spacing: 60) {
                    VStack{
                        Circle()
                            .frame(width: 75, height: 150)
                            .offset(y: 20)
                        Text("#2")
                    }
                   
                    
                    VStack{
                        Circle()
                            .frame(width: 75, height: 75)
                            .offset(y: -20)
                        Text("#1")
                    }
                    
                    VStack{
                        Circle()
                            .frame(width: 75, height: 150)
                            .offset(y: 20)
                        Text("#3")
                    }
                }
            }.padding(50)
            
            Spacer()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(entries) { entry in
                        LeaderboardRow(entry: entry)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry

    var body: some View {
        HStack {
            Text("#\(entry.rank)")
                .font(.title2)
                .fontWeight(.bold)
                .frame(width: 50, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.user.username)
                    .font(.headline)
                Text(entry.recipeName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(entry.datePosted, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(radius: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    LeaderboardView()
}
