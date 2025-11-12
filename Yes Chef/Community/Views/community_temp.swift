//
//  temp.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/7/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var selectedLanguage = "English"
    @State private var selectedTheme = "Light"
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationVM.self) var authVM
    @State private var showingEmailChange = false
    @State private var showingPasswordChange = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {dismiss()}){
                            Image(systemName: "chevron.backward").font(Font.title2)
                        }
                        .foregroundColor(.black)
                        .padding(.leading, screen.width * 0.04)
                        Spacer()
                    }
                    // MARK: - Title
                    Text("Settings")
                        .font(.custom("Georgia", size: 32))
                        .fontWeight(.bold)
                        .frame(height: 29)
                        .padding(.top, 70) // moved slightly up from 89
                        .padding(.bottom, 36)
                    
                    // MARK: - Preferences Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Preferences")
                            .font(.custom("Georgia", size: 24))
                            .fontWeight(.bold)
                            .padding(.horizontal, 11)
                        
                        Rectangle() // bold line directly under header
                            .fill(Color(.systemGray))
                            .frame(height: 2)
                            .padding(.top, 4)
                            .padding(.bottom, 16)
                        
                        VStack(spacing: 26) {
                            // Notifications Toggle
                            HStack {
                                Image(systemName: "bell")
                                    .frame(width: 24)
                                Text("Notifications")
                                    .font(.custom("Work Sans", size: 16))
                                Spacer()
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .tint(.orange) // orange toggle
                            }
                            
                            // Language Button
                            Button {
                                // TODO: Language selection
                            } label: {
                                HStack {
                                    Image(systemName: "globe")
                                        .frame(width: 24)
                                    Text("Languages")
                                        .font(.custom("Work Sans", size: 16))
                                    Spacer()
                                    Text(selectedLanguage)
                                        .font(.custom("Work Sans", size: 16))
                                        .foregroundColor(.gray)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            // Theme Button
                            Button {
                                // TODO: Theme selection
                            } label: {
                                HStack {
                                    Image(systemName: "paintpalette")
                                        .frame(width: 24)
                                    Text("Theme")
                                        .font(.custom("Work Sans", size: 16))
                                    Spacer()
                                    Text(selectedTheme)
                                        .font(.custom("Work Sans", size: 16))
                                        .foregroundColor(.gray)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(width: 391, height: 126)
                        .padding(.horizontal, 11)
                        
                        Rectangle() // bold line below box
                            .fill(Color(.systemGray))
                            .frame(height: 2)
                            .padding(.top, 16)
                    }
                    .padding(.bottom, 32)
                    
                    // MARK: - Account Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Account")
                            .font(.custom("Georgia", size: 24))
                            .fontWeight(.bold)
                            .padding(.horizontal, 11)
                        
                        Rectangle()
                            .fill(Color(.systemGray))
                            .frame(height: 2)
                            .padding(.top, 4)
                            .padding(.bottom, 16)
                        
                        VStack(spacing: 26) {
                            // Change Email
                            Button {
                                showingEmailChange = true
                            } label: {
                                settingsRow(icon: "envelope", title: "Change Email")
                            }
                            .foregroundColor(.black)
                            
                            .fullScreenCover(isPresented: $showingEmailChange) {
                                ChangeEmailView(authVM: authVM, isPresented: $showingEmailChange)
                            }
                            
                            // Change Password
                            Button {
                                showingPasswordChange = true
                            } label: {
                                settingsRow(icon: "lock", title: "Change Password")
                            }
                            .foregroundColor(.black)
                            
                            .fullScreenCover(isPresented: $showingPasswordChange) {
                                ChangePasswordView(isPresented: $showingPasswordChange, authVM: authVM)
                            }
                            
                            // Log Out
                            Button {
                                // TODO: log out
                                showAlert = true
                            } label: {
                                settingsRow(icon: "arrow.right", title: "Log Out")
                            }
                            
                            .alert("Confirmation", isPresented: $showAlert) {
                                        Button("Yes") {
                                            authVM.signOut()
                                            dismiss()
                                        }
                                        Button("No", role: .cancel) {
                                        }
                                    } message: {
                                        Text("Are you sure you want to logout?")
                                    }
                            .foregroundColor(.black)
                            
                            // Delete Account
                            Button {
                                // TODO: delete account
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .frame(width: 24)
                                    Text("Delete Account")
                                        .font(.custom("Work Sans", size: 16))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(width: 391, height: 178)
                        .padding(.horizontal, 11)
                        
                        Rectangle()
                            .fill(Color(.systemGray))
                            .frame(height: 2)
                            .padding(.top, 16)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.light)
        }
    }
    
    // MARK: - Helper
    private func settingsRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
                .font(.custom("Work Sans", size: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Change Email View
struct ChangeEmailView: View {
    var authVM: AuthenticationVM
    @Binding var isPresented: Bool
    @State private var oldEmail = ""
    @State private var newEmail = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // Top buttons
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button("Done") {
                        Task {
                            guard oldEmail == authVM.currentUser?.email else {
                                print("Old email does not match")
                                return
                            }

                            do {
                                // Update email in Firestore
                                try await Firebase.db.collection("users")
                                    .document(authVM.currentUser!.userId)
                                    .updateData(["email": newEmail])

                                // Update local model
                                authVM.currentUser?.email = newEmail
                                isPresented = false
                                print("Email updated successfully")
                            } catch {
                                print("Failed to update email: \(error.localizedDescription)")
                            }
                        }
                    }
                    .disabled(oldEmail.isEmpty || newEmail.isEmpty)
                    .foregroundColor(.green)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Spacer to push everything down a bit
                Spacer().frame(height: 20)
                
                // Title
                Text("Change Email")
                    .font(.custom("Georgia", size: 32))
                    .bold()
                
                // Old Email
                TextField("Old Email", text: $oldEmail)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .frame(width: 324, height: 51)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                
                // New Email
                TextField("New Email", text: $newEmail)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .frame(width: 324, height: 51)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                
                // Info bullet point
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                    Text("Emails are uniquely tied to account")
                        .font(.custom("WorkSans-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Change Password View
struct ChangePasswordView: View {
    @Binding var isPresented: Bool
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    var authVM: AuthenticationVM
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // Top buttons
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button("Done") {
                        Task {
                            // 1. Verify old password
                            guard oldPassword == authVM.currentUser?.password else {
                                print("Old password does not match")
                                return
                            }

                            // 2. Verify new password confirmation
                            guard newPassword == confirmPassword else {
                                print("Passwords do not match")
                                return
                            }

                            do {
                                // 3. Update Firestore
                                try await Firebase.db.collection("users")
                                    .document(authVM.currentUser!.userId)
                                    .updateData(["password": newPassword])

                                // 4. Update local model
                                authVM.currentUser?.password = newPassword
                                isPresented = false
                                print("Password updated successfully")
                            } catch {
                                print("Failed to update password: \(error.localizedDescription)")
                            }
                        }
                    }
                    .disabled(oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                    .foregroundColor(.green)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Spacer to push content down slightly
                Spacer().frame(height: 20)
                
                // Title
                Text("Change Password")
                    .font(.custom("Georgia", size: 32))
                    .bold()
                
                // Old Password
                SecureField("Old Password", text: $oldPassword)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .frame(width: 324, height: 51)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                
                // New Password
                SecureField("New Password", text: $newPassword)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .frame(width: 324, height: 51)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                
                // Info bullet points
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        Text("8 characters minimum, 25 characters maximum")
                            .font(.custom("WorkSans-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        Text("At least 1 uppercase, 1 lowercase, 1 number, 1 special character (# ? ! @)")
                            .font(.custom("WorkSans-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                .padding(.vertical, 20)
                
                // Confirm Password
                SecureField("Confirm New Password", text: $confirmPassword)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .frame(width: 324, height: 51)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct FeedView: View {
    @State private var viewModel = PostViewModel()
    @State private var selectedTab: Int = 0
    @Environment(AuthenticationVM.self) var authVM
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Different possible heights for visual variation
    let imageHeights: [CGFloat] = [160, 190, 220]
    
    var filteredRecipes: [Recipe] {
        if selectedTab == 0 {
            // For You - show all recipes
            return viewModel.recipes
        } else {
            // Following - show only recipes from users the current user follows
            guard let currentUser = authVM.currentUser,
                  !currentUser.following.isEmpty else {
                return []
            }
            return viewModel.recipes.filter { recipe in
                currentUser.following.contains(recipe.userId)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Title with icon
                HStack {
                    Text("Welcome \(authVM.currentUser?.username ?? "User")")
                        .font(.custom("Georgia", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#404741"))
                    
                    Spacer()
                    NavigationLink(destination: UserListView()) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#404741"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Custom tab bar
                tabSelection
                
                // ScrollView for posts
                ScrollView {
                    if filteredRecipes.isEmpty {
                        Text(selectedTab == 0 ? "No recipes available." : "No recipes from people you follow.")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredRecipes, id: \.id) { recipe in
                                NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        let height = deterministicHeight(for: recipe.id.uuidHash)
                                        
                                        if let firstImage = recipe.media.first,
                                           let url = URL(string: firstImage) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                Color.gray.opacity(0.3)
                                            }
                                            .frame(width: 154, height: height)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .clipped()
                                        } else {
                                            Color.gray.opacity(0.3)
                                                .frame(width: 154, height: height)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        
                                        FeedText(text: recipe.name)
                                            .frame(width: 154, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                .background(Color(hex: "#fffdf7"))
            }
            .background(Color(hex: "#fffdf7"))
            .task {
                do {
                    try await viewModel.fetchPosts()
                } catch {
                    print("Failed to fetch recipes: \(error)")
                }
            }
        }
        .onAppear {
            Task {
                // Only update if currentUser exists and has a valid userId
                if let userId = authVM.currentUser?.userId, !userId.isEmpty {
                    await authVM.updateCurrentUser()
                }
            }
        }
    }
    
    private var tabSelection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "fffdf7"))
                .frame(height: 56)
            
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 8) {
                        BodyText(text: "For You")
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 0 ? 1 : 0)
                .background(
                    RoundedCorner(radius: 25, corners: selectedTab == 0 ? [.topLeft, .topRight] : [.bottomRight, .topRight, .topLeft])
                        .fill(selectedTab == 0 ? Color(hex: "fffdf7") : Color(hex: "#F9F5F2"))
                        .frame(width: (UIScreen.main.bounds.width) / 2, height: 50)
                        .background(
                            RoundedCorner(radius: 25, corners: selectedTab == 0 ? [.topLeft, .topRight] : [.bottomRight, .topRight, .topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: (UIScreen.main.bounds.width) / 2 + 1, height: 50)
                                .padding(selectedTab == 0 ? .bottom : .top, 3)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(hex: "fffdf7"))
                                        .padding(selectedTab == 0 ? .top : .bottom, 35)
                                )
                        )
                )
                
                Button(action: { selectedTab = 1 }) {
                    VStack(spacing: 8) {
                        BodyText(text: "Following")
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 1 ? 2 : 0)
                .background(
                    RoundedCorner(radius: 25, corners: selectedTab == 1 ? [.topLeft, .topRight] : [.bottomRight, .bottomLeft, .topRight, .topLeft])
                        .fill(selectedTab == 1 ? Color(hex: "fffdf7") : Color(hex: "#F9F5F2"))
                        .frame(width: (UIScreen.main.bounds.width) / 2, height: 50)
                        .background(
                            RoundedCorner(radius: 25, corners: selectedTab == 1 ? [.topLeft, .topRight] : [.bottomRight, .bottomLeft, .topRight, .topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: (UIScreen.main.bounds.width) / 2 + 1, height: 50)
                                .padding(selectedTab == 1 ? .bottom : .top, 3)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(hex: "fffdf7"))
                                        .padding(selectedTab == 1 ? .top : .bottom, 35)
                                )
                        )
                )
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
            .padding(.horizontal, 0)
        }
    }
    
    // MARK: - Helper
    private func deterministicHeight(for hash: Int) -> CGFloat {
        imageHeights[abs(hash) % imageHeights.count]
    }
    
    struct RoundedCorner: Shape {
        var radius: CGFloat
        var corners: UIRectCorner

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }
}

extension String {
    var uuidHash: Int {
        unicodeScalars.map { Int($0.value) }.reduce(0, +)
    }
}

#Preview {
    FeedView()
        .environment(AuthenticationVM())
}
