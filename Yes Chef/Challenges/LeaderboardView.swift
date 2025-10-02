/*import SwiftUI
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
            Text("\(entry.rank)")
                .padding(5)
            //pfp
            /*Image(systemName: profilepicture)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .foregroundStyle(.blue)*/
            AsyncImage(url: URL(string: entry.user.profileImageURL ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        // Fallback if the image fails to load
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.blue)
                    } else {
                        // Placeholder while loading
                        ProgressView()
                            .frame(width: 75, height: 75)
                    }
                }
            .scaledToFit()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            //name
            VStack (alignment: .leading, spacing: 4){
                Text(mockVM.user?.username ?? "")
                    .font(.headline)
                    .foregroundStyle(.blue)
                //signiture dish/most famous dish
                Text("Dish: \(entry.recipeName)")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(entry.likes)")
            }
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
}*/

import SwiftUI
import Foundation
import Firebase

struct LeaderboardView: View {
    @StateObject private var data: LeaderboardData = LeaderboardData()
    @State private var reloadTrigger: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                /*Button(action: {
                    data.recalibrateEntries()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.blue)
                }*/
                Spacer()
                Button(action: {
                    print("History button tapped")
                }) {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
            }
            .padding(.horizontal)
            
            Text("Leaderboard")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 4) {
                Text("This Week")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Prompt for weekly challenge")
                    .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack {
                Spacer()
                
                HStack(alignment: .bottom, spacing: 40) {
                    VStack {
                        Text("2nd")
                            .font(.caption)
                        AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].user.profileImageURL ?? "" : "")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)
                            }
                        }
                        Text(data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].user.username : "Chef #2")
                            .font(.caption2)
                        Text(data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].recipeName : "Recipe")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .offset(y: 20)
                    
                    VStack {
                        ZStack(alignment: .top) {
                            AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].user.profileImageURL ?? "" : "")) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.blue)
                                }
                            }
                            Image("ChefHat")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .offset(y: -25)
                                .foregroundColor(.gray)
                        }
                        Text(data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].user.username : "Chef #1")
                            .font(.caption2)
                        Text(data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].recipeName : "Recipe")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .offset(y: -10)
                    
                    VStack {
                        Text("3rd")
                            .font(.caption)
                        AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].user.profileImageURL ?? "" : "")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)
                            }
                        }
                        Text(data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].user.username : "Chef #3")
                            .font(.caption2)
                        Text(data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].recipeName : "Recipe")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .offset(y: 20)
                }
                
                Spacer()
            }
            .padding(.top)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(data.currentLeaderboard.entries.dropFirst(3)) { entry in
                        LeaderboardRow(entry: entry)
                    }
                }
                .padding(.vertical)
            }
            
            HStack(spacing: 20) {
                Button(action: {                    LeaderboardData.clearUserRecipes()
                    data.recalibrateEntries()
                }) {
                    Text("Clear Leaderboard")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    LeaderboardData.seedRandomUserRecipes()
                    data.recalibrateEntries()
                }) {
                    Text("Load New Sample Entries")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .task {
                await data.refreshData()
            }
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardData.LeaderboardEntry

    var body: some View {
        HStack {
            Text("\(entry.rank)")
                .font(.headline)
                .frame(width: 30)
            
            AsyncImage(url: URL(string: entry.user.profileImageURL ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.user.username)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text(entry.recipeName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(entry.likes)")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(radius: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    LeaderboardView()
}
