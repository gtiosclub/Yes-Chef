//
//  AuthenticationVM.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/7/25.
//

@preconcurrency import FirebaseAuth
import Observation

@Observable class AuthenticationVM {
    var errorMessage: String?
    var isLoading = false
    var isLoggedIn = false
    var currentUser: User?
    var auth: Auth
    
    init() {
        self.auth = Auth.auth()
    }
    
    
    func login(email: String, password: String) async {
        isLoading = true
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let user = authResult.user
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.isLoggedIn = true
                print("Signed in as \(user.displayName ?? "Anonymous")")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func register(email: String, password: String, username: String) {
        auth.createUser(withEmail: email, password: password) {result, error in
            if let error = error {
                print("Error registering: \(error.localizedDescription)")
            } else {
                print("User registered: \(result?.user.uid ?? "")")
            }
            
            guard let user = result?.user else {return}
            
            let newUser = User(userId: user.uid, username: username, email: email)
            
            let userData: [String: Any] = [
                "userId": newUser.userId,
                "username": newUser.username,
                "email": newUser.email,
                "phoneNumber": newUser.phoneNumber ?? "",
                "bio": newUser.bio ?? "",
                "profilePhoto": newUser.profilePhoto,
                "followers": newUser.followers,
                "following": newUser.following,
                "myRecipes": newUser.myRecipes,
                "savedRecipes": newUser.savedRecipes,
                "badges": newUser.badges
            ]
            Firebase.db.collection("users").document(newUser.userId).setData(userData) { err in
                        if let err = err {
                            print("Error saving user: \(err)")
                        } else {
                            print("User profile saved in Firestore")
                            
                            // 3. Update currentUser
                            DispatchQueue.main.async {
                                self.currentUser = newUser
                                self.isLoggedIn = true
                                self.isLoading = false
                            }
                        }
                    }
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
