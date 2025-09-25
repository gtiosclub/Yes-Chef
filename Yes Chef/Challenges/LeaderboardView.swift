import SwiftUI
import Foundation
import Firebase

import Foundation

import Foundation



struct LeaderboardView: View {
    // Sample data for testing
    @StateObject var data : LeaderboardData = LeaderboardData()
   
    

    

    var body: some View {
        
        VStack{
           /* Button(action: {
                data.addLeaderboard()
            }) {
                Text("Publish Leaderboard")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }*/
            
            ZStack {
                HStack(spacing: 60) {
                    VStack{
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                            .foregroundStyle(.blue)
                            .frame(width: 75, height: 150)
                            .offset(y: 20)
                        Text("#2")
                    }
                   
                    
                    VStack{
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                            .foregroundStyle(.blue)
                            .frame(width: 75, height: 75)
                            .offset(y: -20)
                        Text("#1")
                    }
                    
                    VStack{
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                            .foregroundStyle(.blue)
                            .frame(width: 75, height: 150)
                            .offset(y: 20)
                        Text("#3")
                    }
                }
            }.padding(50)
            
            Spacer()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(data.currentLeaderboard.entries) { entry in
                        LeaderboardRow(entry: entry)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}


struct LeaderboardRow: View {
    let entry: LeaderboardData.LeaderboardEntry

    var body: some View {
        let mockUser = User(userId: "#\(entry.rank)", username: entry.user.username, email: "john@example.com")
        let mockVM = UserBlockViewModelDH(mockUser: mockUser)
        
        //Placeholders
        var profilepicture: String = "person.circle.fill"
        var signitureDish: String = "Pasta"
        
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
                Text(mockVM.user?.username ?? "")
                    .font(.headline)
                    .foregroundStyle(.blue)
                //signiture dish/most famous dish
                Text("SignitureDish: \(entry.recipeName)")
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
       
       /* HStack {
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
        )*/
        .padding(.horizontal)
    }
}

#Preview {
    LeaderboardView()
}
