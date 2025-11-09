//
//  HeaderTabsView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/2/25.
//
import SwiftUI
import FirebaseFirestore

struct AddRecipeMain: View {
    @State private var selectedInternalTab: Int = 0
    @State private var recipeVM: CreateRecipeVM
    @State private var submitToWeeklyChallenge: Bool = false
    @State private var weeklyPrompt: String = "Loading prompt..."
    @State private var showSuccessMessage: Bool = false
    @State private var showCancelMessage: Bool = false
    @State private var isProcessing: Bool = false
    @State private var showValidationAlert = false
    @State private var validationErrorMessage = ""
    @Binding var selectedTab: TabSelection
    @Binding var navigationRecipe: Recipe?

    var comeFromRemix: Bool = false
    var remixParentID: String = ""

    init(selectedTab: Binding<TabSelection> = .constant(.post), navigationRecipe: Binding<Recipe?> = .constant(nil), remixRecipe: Recipe? = nil, submitToWeeklyChallenge: Bool = false) {
        _selectedTab = selectedTab
        _navigationRecipe = navigationRecipe
        if let recipe = remixRecipe {
            _recipeVM = State(initialValue: CreateRecipeVM(fromRecipe: recipe))
            self.comeFromRemix = true
            self.remixParentID = recipe.id
        } else {
            _recipeVM = State(initialValue: CreateRecipeVM())
        }
        _submitToWeeklyChallenge = State(initialValue: submitToWeeklyChallenge)
    }

    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
            VStack(spacing: 0){
                headerView
                
                tabSelectionView
                if selectedInternalTab == 0 {
                    CreateRecipe(recipeVM: recipeVM)
                } else {
                    AIChefBaseView(recipeVM: recipeVM) {
                        withAnimation {
                            selectedInternalTab = 0
                        }
                    }
                }

                // Weekly Challenge Toggle Section
                VStack(spacing: 12) {
                    Toggle(isOn: $submitToWeeklyChallenge) {
                        Text("Submit to Weekly Challenge?")
                            .font(.headline)
                            .foregroundStyle(Color(hex: "#453736"))
                    }
                    .padding(.horizontal)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#404741")))

                    if submitToWeeklyChallenge {
                        VStack(spacing: 8) {
                            Text("This Week's Challenge")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(weeklyPrompt)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
            }
            .background(Color(hex: "#fffffc"))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .task {
                await fetchWeeklyPrompt()
            }
            .overlay(successOverlay)
            .overlay(cancelOverlay)
            .overlay(approveDenyOverlay)
            .alert("Validation Error", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationErrorMessage)
            }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack{
            Button {
                guard !isProcessing else { return }
                isProcessing = true

                withAnimation(.easeInOut(duration: 0.3)) {
                    showCancelMessage = true
                }
                // Auto-dismiss popup after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showCancelMessage = false
                    }
                }
                // Navigate back to home tab
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selectedTab = .home
                    }
                }
                // Re-enable buttons after navigation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isProcessing = false
                }
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isProcessing ? Color.gray : Color.black)
            }
            .disabled(isProcessing)
            Spacer()

            Text("Add Recipe")
                .font(.custom("Georgia", size: 30))
                .foregroundStyle(Color(hex: "#453736"))
                .fontWeight(.bold)

            Spacer()

            Button {
                guard !isProcessing else { return }
                
                let validation = recipeVM.validate()
                
                if !validation.isValid {
                    validationErrorMessage = validation.errorMessage ?? "Please fill in all required fields"
                    showValidationAlert = true
                    return
                }
                
                isProcessing = true

                Task {
                    print("📝 Creating recipe...")
                    let recipeID = await recipeVM.createRecipe(
                        userId: authVM.currentUser?.userId ?? "",
                        name: recipeVM.name,
                        ingredients: recipeVM.ingredients,
                        allergens: recipeVM.allergens,
                        tags: recipeVM.tags,
                        steps: recipeVM.steps,
                        description: recipeVM.description,
                        prepTime: recipeVM.prepTime,
                        difficulty: recipeVM.difficulty,
                        servingSize: recipeVM.servingSize,
                        media: recipeVM.mediaItems,
                        chefsNotes: recipeVM.chefsNotes,
                        submitToWeeklyChallenge: submitToWeeklyChallenge
                    )
                    print("✅ Recipe created with ID: \(recipeID)")

                    // Add to remix tree - either as root OR as child, never both
                    if comeFromRemix {
                        print("🌳 Adding as CHILD node (remix) with parent: \(remixParentID)")
                        let remixDescription = recipeVM.chefsNotes.isEmpty ? "Remixed version" : recipeVM.chefsNotes
                        await recipeVM.addRecipeToRemixTreeAsNode(
                            postName: recipeVM.name,
                            recipeID: recipeID,
                            description: remixDescription,
                            parentID: remixParentID
                        )
                    } else {
                        print("🌳 Adding as ROOT node (new recipe)")
                        await recipeVM.addRecipeToRemixTreeAsRoot(
                            recipeID: recipeID,
                            postName: recipeVM.name,
                            description: "Original recipe"
                        )
                    }

                    if let recipe = await Recipe.fetchById(recipeID) {
                        await MainActor.run {
                            self.showSuccessMessage = true
                        }

                        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

                        await MainActor.run {
                            withAnimation(.easeOut(duration: 0.3)) {
                                self.showSuccessMessage = false
                            }
                        }

                        await MainActor.run {
                            // Reset form fields only if not coming from remix
                            if !comeFromRemix {
                                self.recipeVM.reset()
                            }
                            self.selectedInternalTab = 0
                            self.submitToWeeklyChallenge = false
                            self.isProcessing = false
                        }

                        await MainActor.run {
                            self.navigationRecipe = recipe
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.selectedTab = .home
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isProcessing ? Color.gray : Color.black)
            }
            .disabled(isProcessing)
        }
        .padding(.horizontal, 10)
        .padding()
    }

    // MARK: - Success Overlay
    private var successOverlay: some View {
        Group {
            if showSuccessMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        Text("Recipe added!")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .padding(.bottom, 50)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: showSuccessMessage)
            }
        }
    }

    // MARK: - Cancel Overlay
    private var cancelOverlay: some View {
        Group {
            if showCancelMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        Text("Recipe add canceled")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .padding(.bottom, 50)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: showCancelMessage)
            }
        }
    }
    
    // MARK: - Approve/Deny Overlay
    private var approveDenyOverlay: some View {
        Group {
            if recipeVM.toolcall != nil {
                VStack {
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: {
                            recipeVM.approve()
                        }) {
                            Text("Approve")
                                .foregroundColor(.white)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 60)
                                .background(Color(hex: "#FFA947"))
                                .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            recipeVM.deny()
                        }) {
                            Text("Deny")
                                .foregroundColor(Color(hex: "#404741"))
                                .padding(.vertical, 15)
                                .padding(.horizontal, 60)
                                .background(Color(hex: "#FFEABC"))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .center, vertical: .center))
                    .padding(.top)
                    .background(
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 1)
                            Color(hex: "#fffffc")
                        }
                        .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
        }
    }

    private var tabSelectionView: some View {
        ZStack(alignment: .bottomLeading){
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#fffffc"))
                .frame(height: 56)
            
            HStack(spacing: 0) {

                Button(action: { selectedInternalTab = 0 }) {
                    VStack(spacing: 8) {
                        Text("Edit Details")
                            .font(.body)
                            .foregroundColor(selectedInternalTab == 0 ? Color(hex: "#404741") : Color(hex: "#7C887DF2"))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .zIndex(selectedInternalTab == 0 ? 1 : 0)
                .background(
                    RoundedCorner(radius: 25, corners: selectedInternalTab == 0 ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                        .fill(selectedInternalTab == 0 ? Color(hex: "#fffffc") : Color(hex: "#F9F5F2"))
                        .frame(width: (UIScreen.main.bounds.width)/2, height: 50)
                        .background(
                            RoundedCorner(radius: 25, corners: selectedInternalTab == 0 ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: (UIScreen.main.bounds.width)/2 + 1, height: 50)
                                .padding(selectedInternalTab == 0 ? .bottom : .top, 3)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(hex: "#fffffc"))
                                        .padding(selectedInternalTab == 0 ? .top : .bottom, 35)
                                )
                        )
                )

                Button(action: { selectedInternalTab = 1 }) {
                    VStack(spacing: 8) {
                        Text("AI Chef")
                            .font(.body)
                            .foregroundColor(selectedInternalTab == 1 ? Color(hex: "#404741") : Color(hex: "#7C887DF2"))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .frame(maxWidth: .infinity)
                .zIndex(selectedInternalTab == 1 ? 2 : 0)
                .background(
                    RoundedCorner(radius: 25, corners: selectedInternalTab == 1 ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft,.topRight,.topLeft])
                        .fill(selectedInternalTab == 1 ? Color(hex: "#fffffc") : Color(hex: "#F9F5F2"))
                        .frame(width: (UIScreen.main.bounds.width)/2, height: 50)
                        .background(
                            //Border over top of tab
                            RoundedCorner(radius: 25, corners: selectedInternalTab == 1 ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft, .topRight,.topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: (UIScreen.main.bounds.width)/2 + 1, height: 50)
                                .padding(selectedInternalTab == 1 ? .bottom : .top, 3)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(hex: "#fffffc"))
                                        .padding(selectedInternalTab == 1 ? .top : .bottom, 35)
                                )
                        )
                )
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
            .padding(.horizontal, 0)
        }
    }

    // Fetch the current weekly challenge prompt
    private func fetchWeeklyPrompt() async {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if document.exists, let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run {
                    self.weeklyPrompt = prompt
                }
            } else {
                // Document doesn't exist, show default message
                await MainActor.run {
                    self.weeklyPrompt = "No weekly challenge active"
                }
            }
        } catch {
            print("Error fetching weekly prompt: \(error.localizedDescription)")
            await MainActor.run {
                self.weeklyPrompt = "Could not load challenge prompt"
            }
        }
    }
}

#Preview {
    AddRecipeMain()
        .environment(AuthenticationVM())
}

// MARK: - Custom Shapes
fileprivate struct RoundedCorner: Shape {
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
