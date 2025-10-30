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
    
    var authVM: AuthenticationVM
    @State private var showingEmailChange = false
    @State private var showingPasswordChange = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
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
                            } label: {
                                settingsRow(icon: "arrow.right", title: "Log Out")
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
    @State private var selectedTab: Tab = .forYou
    
    enum Tab {
        case forYou, following
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Different possible heights for visual variation
    let imageHeights: [CGFloat] = [160, 190, 220]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                
                // Title with icon
                HStack {
                    Text("Welcome Link!")
                        .font(.custom("Georgia", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#404741"))
                    
                    Spacer()
                    
                    Image(systemName: "paperplane")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#404741"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Custom tab bar - Z-stack overlapping style
                ZStack(alignment: .bottom) {
                    // Background for unselected tabs
                    Color(hex: "#F5F5F5")
                        .frame(height: 50)
                    
                    HStack(spacing: 0) {
                        // For You Tab
                        Button {
                            selectedTab = .forYou
                        } label: {
                            Text("For You")
                                .font(.custom("WorkSans-Regular", size: 16))
                                .foregroundColor(Color(hex: "#404741"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    GeometryReader { geo in
                                        Path { path in
                                            let w = geo.size.width
                                            let h = geo.size.height
                                            let cornerRadius: CGFloat = 8
                                            
                                            if selectedTab == .forYou {
                                                // Start bottom left
                                                path.move(to: CGPoint(x: 0, y: h))
                                                // Left side up
                                                path.addLine(to: CGPoint(x: 0, y: cornerRadius))
                                                // Top left curve
                                                path.addQuadCurve(
                                                    to: CGPoint(x: cornerRadius, y: 0),
                                                    control: CGPoint(x: 0, y: 0)
                                                )
                                                // Top side
                                                path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
                                                // Top right curve
                                                path.addQuadCurve(
                                                    to: CGPoint(x: w, y: cornerRadius),
                                                    control: CGPoint(x: w, y: 0)
                                                )
                                                // Right side down
                                                path.addLine(to: CGPoint(x: w, y: h))
                                                // Bottom
                                                path.addLine(to: CGPoint(x: 0, y: h))
                                            }
                                        }
                                        .fill(Color.white)
                                    }
                                )
                        }
                        .buttonStyle(.plain)
                        .zIndex(selectedTab == .forYou ? 1 : 0)
                        
                        // Following Tab
                        Button {
                            selectedTab = .following
                        } label: {
                            Text("Following")
                                .font(.custom("WorkSans-Regular", size: 16))
                                .foregroundColor(Color(hex: "#404741"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    GeometryReader { geo in
                                        Path { path in
                                            let w = geo.size.width
                                            let h = geo.size.height
                                            let cornerRadius: CGFloat = 8
                                            
                                            if selectedTab == .following {
                                                // Start bottom left
                                                path.move(to: CGPoint(x: 0, y: h))
                                                // Left side up
                                                path.addLine(to: CGPoint(x: 0, y: cornerRadius))
                                                // Top left curve
                                                path.addQuadCurve(
                                                    to: CGPoint(x: cornerRadius, y: 0),
                                                    control: CGPoint(x: 0, y: 0)
                                                )
                                                // Top side
                                                path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
                                                // Top right curve
                                                path.addQuadCurve(
                                                    to: CGPoint(x: w, y: cornerRadius),
                                                    control: CGPoint(x: w, y: 0)
                                                )
                                                // Right side down
                                                path.addLine(to: CGPoint(x: w, y: h))
                                                // Bottom
                                                path.addLine(to: CGPoint(x: 0, y: h))
                                            }
                                        }
                                        .fill(Color.white)
                                    }
                                )
                        }
                        .buttonStyle(.plain)
                        .zIndex(selectedTab == .following ? 1 : 0)
                    }
                }
                .frame(height: 50)
                
                // ScrollView for posts
                ScrollView {
                    if viewModel.recipes.isEmpty {
                        Text("No recipes available.")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.recipes, id: \.id) { recipe in
                                NavigationLink(destination: PostView(recipe: recipe)) {
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
                                        
                                        Text(recipe.name)
                                            .font(.custom("Inter-Regular", size: 12))
                                            .foregroundColor(Color(hex: "#404741"))
                                            .frame(width: 154, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                .background(Color.white)
            }
            .background(Color.white)
            .task {
                do {
                    try await viewModel.fetchPosts()
                } catch {
                    print("Failed to fetch recipes: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper
    private func deterministicHeight(for hash: Int) -> CGFloat {
        imageHeights[abs(hash) % imageHeights.count]
    }
}

extension String {
    var uuidHash: Int {
        unicodeScalars.map { Int($0.value) }.reduce(0, +)
    }
}
#Preview {
    SettingsView(authVM: AuthenticationVM())
}
