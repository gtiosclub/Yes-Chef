import SwiftUI

struct ProfileView: View {
    @State private var selectedTab = 0
    @State private var isFollowing = false
    
    // Simple boolean to toggle between own profile vs other's profile for UI demo
    let isOwnProfile: Bool
    
    init(isOwnProfile: Bool = true) {
        self.isOwnProfile = isOwnProfile
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Profile Info
                profileInfoSection
                
                // Stats
                statsSection
                
                // Action Button
                actionButton
                
                // Tab Selection
                tabSelection
                
                // Content Grid
                contentGrid
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            if !isOwnProfile {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            } else {
                Spacer()
            }
            
            Spacer()
            
            if isOwnProfile {
                Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Profile Info
    private var profileInfoSection: some View {
        VStack(spacing: 12) {
            Text("@username")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Profile Image
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)
            
            // Display Name
            Text("Display Name")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Bio
            Text("new to all of this, trying my best")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 40) {
            VStack(spacing: 4) {
                Text("821")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Followers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("1.2k")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Following")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("34")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Recipes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: {
            if !isOwnProfile {
                isFollowing.toggle()
            }
        }) {
            Text(isOwnProfile ? "edit" : (isFollowing ? "following" : "follow"))
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isOwnProfile ? .black : (isFollowing ? .black : .white))
                .frame(width: 120, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isOwnProfile ? Color.gray.opacity(0.2) : (isFollowing ? Color.gray.opacity(0.2) : Color.black))
                )
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Tab Selection
    private var tabSelection: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                VStack(spacing: 8) {
                    Text("my posts")
                        .font(.body)
                        .fontWeight(selectedTab == 0 ? .semibold : .regular)
                        .foregroundColor(.black)
                    
                    Rectangle()
                        .fill(selectedTab == 0 ? Color.black : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
            
            Button(action: { selectedTab = 1 }) {
                VStack(spacing: 8) {
                    Text(isOwnProfile ? "saved" : "recipes")
                        .font(.body)
                        .fontWeight(selectedTab == 1 ? .semibold : .regular)
                        .foregroundColor(.black)
                    
                    Rectangle()
                        .fill(selectedTab == 1 ? Color.black : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Content Grid
    private var contentGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    // Recipe Image
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text("picture")
                                .foregroundColor(.gray)
                                .font(.body)
                        )
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Recipe Title
                    Text("Food Title")
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .padding(.horizontal, 4)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    print("Recipe \(index) tapped")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(isOwnProfile: true)
        }
        .previewDisplayName("Own Profile")
        
        NavigationView {
            ProfileView(isOwnProfile: false)
        }
        .previewDisplayName("Other User Profile")
    }
}
