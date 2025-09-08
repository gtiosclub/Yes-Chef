//
//  AuthenticationVM.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/7/25.
//

@preconcurrency import FirebaseAuth

@Observable class AuthenticationVM {
    var errorMessage: String?
    var isLoading = false
    var currentUser: User?
    
    let auth = Auth.auth()

    init() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.fetchUser(userId: user.uid, email: user.email ?? "", username: user.displayName ?? "")
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    
    func login(email: String, password: String) async {
        isLoading = true
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let user = authResult.user
            
            DispatchQueue.main.async {
                self.fetchUser(userId: user.uid, email: email, username: user.displayName ?? "")
                self.isLoading = false
                print("Signed in up as \(user.displayName ?? "Anonymous")")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func register(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error registering: \(error.localizedDescription)")
            } else {
                print("User registered: \(result?.user.uid ?? "")")
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
    
    private func fetchUser(userId: String, email: String, username: String) {
        Task {
            do {
                let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
                DispatchQueue.main.async {
                    if document.exists {
                        self.currentUser = User(userId: userId, username: username, email: email)
                    } else {
                        self.errorMessage = "User not found."
//                        Task { try await Firebase.db.collection("USERS").document(userId).setData(["email": email, "username": username]) }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
                }
            }
        }
    }
}
