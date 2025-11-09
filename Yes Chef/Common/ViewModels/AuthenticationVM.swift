//
//  AuthenticationVM.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/7/25.
//

@preconcurrency import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable
class AuthenticationVM {
    var errorMessage: String?
    var isLoading = false
    var isLoggedIn = false
    var currentUser: User?
    var auth: Auth
    var savedRecipes: [Recipe] = []
    private var handler: AuthStateDidChangeListenerHandle?
    init() {
        self.auth = Auth.auth()
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                            guard let self = self else { return }

                            if let user = user {
                                self.currentUser = User(userId: user.uid, username: user.displayName ?? "", email: user.email ?? "")
                            } else {
                                self.currentUser = nil
                            }
                        }
        }
    }
    
    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let user = authResult.user
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.isLoggedIn = true
                print("Signed in as \(user.uid ?? "Anonymous")")
                self.currentUser = User(userId: user.uid, username: user.uid, email: email, bio: "Hi! Learning to cook!")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    //saving recipes logic like save, unsave, fetch saved
    func saveRecipe(recipeId: String) async {
        guard let userId = currentUser?.userId else {
            return
        }
        let db = Firestore.firestore()
        let userReferenceInFirebase = db.collection("users").document(userId)
        do {
            try await userReferenceInFirebase.setData(["savedRecipes": FieldValue.arrayUnion([recipeId])
                                                      ])
        } catch {
            print("could not save to firebase \(error)")
        }
    }
    func unsaveRecipe(recipeId: String) async {
        guard let userId = currentUser?.userId else {
            return
        }
        let db = Firestore.firestore()
        let userReferenceInFirebase = db.collection("users").document(userId)
        do {
            try await userReferenceInFirebase.setData(
                ["savedRecipes": FieldValue.arrayRemove([recipeId])],
                merge: true
            )
        } catch {
            print("coudl not save to firebase \(error.localizedDescription)")
        }
    }
    func fetchSavedRecipes() async {
        guard let userId = currentUser?.userId else {return}
        let db = Firestore.firestore()
        do {
            let userDocument = try await db.collection("users").document(userId).getDocument()
            guard let data = userDocument.data(), let savedIds = data["savedRecipes"] as? [String], !savedIds.isEmpty else {
                    await MainActor.run {self.savedRecipes = []}
                    return
                }
                var fetched: [Recipe] = []
                for recipeId in savedIds {
                    if let recipe = await Recipe.fetchById(recipeId) {
                        fetched.append(recipe)
                    }
                }
                
            
            await MainActor.run {
                self.savedRecipes = fetched
            }
        } catch {
            print("couldn't get the saved recipes :( \(error.localizedDescription)")
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
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Failed to set displayName: \(error.localizedDescription)")
                } else {
                    print("FirebaseAuth displayName set successfully")
                }
            }
            let newUser = User(userId: user.uid, username: username, email: email, password: password)
            
            let userData: [String: Any] = [
                "userId": newUser.userId,
                "username": newUser.username,
                "email": newUser.email,
                "password": newUser.password ?? "",
                "phoneNumber": newUser.phoneNumber ?? "",
                "bio": newUser.bio ?? "",
                "profilePhoto": newUser.profilePhoto,
                "followers": newUser.followers,
                "following": newUser.following,
                "myRecipes": newUser.myRecipes,
                "savedRecipes": newUser.savedRecipes,
                "likedRecipes": newUser.likedRecipes,
                "badges": newUser.badges,
                "suggestionProfile": newUser.suggestionProfile
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
    
    func updateCurrentUser() async {
        guard let userId = self.currentUser?.userId, !userId.isEmpty else {
                print("Error: currentUser or userId is nil/empty")
                return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        do {
            let document = try await userRef.getDocument()
            let data = document.data()
            self.currentUser?.profilePhoto = data?["profilePhoto"] as? String ?? ""
            self.currentUser?.username = data?["username"] as? String ?? "username"
            self.currentUser?.bio = data?["bio"] as? String ?? "bio"
            self.currentUser?.email = data?["email"] as? String ?? "email"
            self.currentUser?.followers = data?["followers"] as? [String] ?? []
            self.currentUser?.following = data?["following"] as? [String] ?? []
            self.currentUser?.likedRecipes = data?["likedRecipes"] as? [String] ?? []
            self.currentUser?.savedRecipes = data?["savedRecipes"] as? [String] ?? []
            self.currentUser?.badges = data?["badges"] as? [String] ?? []
            self.currentUser?.suggestionProfile = data?["suggestionProfile"] as? [String: Double] ?? [:]
        } catch {
            print("Can't find user")
        }
    }
}
