//
//  EditProfileView.swift
//  Yes Chef
//
//  Created by Aryan on 10/21/2025
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userViewModel = UserViewModel()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var selectedUIImage: UIImage?
    
    let user: User
    @State private var name: String
    @State private var username: String
    @State private var pronouns: String
    @State private var bio: String
    @State private var profilePhotoURL: String
    
    private let maxBioLength = 250
    
    init(user: User) {
        self.user = user
        self._name = State(initialValue: user.username) // Using username as display name for now
        self._username = State(initialValue: user.username)
        self._pronouns = State(initialValue: "")
        self._bio = State(initialValue: user.bio ?? "")
        self._profilePhotoURL = State(initialValue: user.profilePhoto)
    }
    
    var body: some View {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Photo Section
                        profilePhotoSection
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                        
                        // Form Fields
                        formFieldsSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                    }
                }
                
                // Fixed Save Button at bottom
                VStack {
                    Spacer()
                    saveButton
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .alert("Profile Update", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let newValue = newValue {
                    await loadImage(from: newValue)
                }
            }
        }
    }
    
    // MARK: - Profile Photo Section
    private var profilePhotoSection: some View {
        VStack(spacing: 16) {
            // Profile photo as clickable button
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // Plain text (no button styling)
            Text("Edit Photo or Avatar")
                .font(.subheadline)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Form Fields Section
    private var formFieldsSection: some View {
        VStack(spacing: 24) {
            // Name Field
            profileField(
                title: "Name",
                text: $name,
                placeholder: "Captain Olimar",
                helperText: "Help people discover your account by using your name you're known by. You can only change your name every 7 days."
            )
            
            // Username Field
            profileField(
                title: "Username",
                text: $username,
                placeholder: "pikmin_father",
                helperText: "Usernames are unique to each person on YesChef. You can only change your username every 30 days.",
                showAtSymbol: true
            )
            
            // Pronouns Field
            profileField(
                title: "Pronouns",
                text: $pronouns,
                placeholder: "he/him/his",
                helperText: "Add your pronouns so people know how to refer to you. You can edit or remove them at any time."
            )
            
            // Bio Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Bio")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing, spacing: 4) {
                    TextField("Captain of the ship, making foods for me and my pikmin to try", text: $bio, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                        .onChange(of: bio) { _, newValue in
                            if newValue.count > maxBioLength {
                                bio = String(newValue.prefix(maxBioLength))
                            }
                        }
                    
                    Text("\(bio.count)/\(maxBioLength)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Profile Field Helper
    private func profileField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        helperText: String,
        showAtSymbol: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                if showAtSymbol {
                    Text("@")
                        .foregroundColor(.secondary)
                }
                TextField(placeholder, text: text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Text(helperText)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        VStack(spacing: 0) {
            // Divider line
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            Button(action: saveProfile) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isLoading ? "Saving..." : "Save Changes")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black)
                )
            }
            .disabled(isLoading || username.isEmpty)
            .opacity(isLoading || username.isEmpty ? 0.6 : 1.0)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.white)
    }
    
    // MARK: - Helper Functions
    private func loadImage(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }
        
        await MainActor.run {
            profileImage = Image(uiImage: uiImage)
            selectedUIImage = uiImage
        }
    }
    
    private func saveProfile() {
        guard !username.isEmpty else {
            alertMessage = "Username cannot be empty"
            showAlert = true
            return
        }
        
        guard !name.isEmpty else {
            alertMessage = "Name cannot be empty"
            showAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("recipe_media_\(UUID().uuidString)")
            try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            let imageURL = tempDir.appendingPathComponent("file").appendingPathExtension("jpg")
            if selectedUIImage == nil {
                return
            }
            if let imageData = selectedUIImage!.jpegData(compressionQuality: 0.9) {
                do {
                    try imageData.write(to: imageURL)
                } catch {
                    print("Failed to write image data: \(error.localizedDescription)")
                }
            }
            
            let success = await userViewModel.updateUserProfileWithImage(
                userID: user.userId,
                username: username,
                bio: bio.isEmpty ? nil : bio,
                image: MediaItem(image: profileImage, localPath: imageURL, mediaType: .photo)
            )
            
            await MainActor.run {
                isLoading = false
                if success {
                    alertMessage = "Profile updated successfully!"
                } else {
                    alertMessage = "Failed to update profile. Please try again."
                }
                showAlert = true
            }
        }
    }
}

// MARK: - Preview
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockUser = User(
            userId: "001",
            username: "kushi",
            email: "kushi@example.com",
            bio: "Lover of food, code, and community!"
        )
        
        EditProfileView(user: mockUser)
    }
}
