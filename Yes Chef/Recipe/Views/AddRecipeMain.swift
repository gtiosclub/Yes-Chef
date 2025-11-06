//
//  HeaderTabsView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/2/25.
//
import SwiftUI

struct AddRecipeMain: View {
    @State private var selectedTab: Int = 0
    @State private var recipeVM: CreateRecipeVM
    
    var comeFromRemix: Bool = false
    var remixParentID: String = ""
    
    init(remixRecipe: Recipe? = nil) {
        if let recipe = remixRecipe {
            _recipeVM = State(initialValue: CreateRecipeVM(fromRecipe: recipe))
            self.comeFromRemix = true
            self.remixParentID = recipe.id
        } else {
            _recipeVM = State(initialValue: CreateRecipeVM())
        }
    }

    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack{
            VStack(spacing: 0){
                HStack{
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    
                    Text("Add Recipe")
                        .font(.custom("Georgia", size: 30))
                        .foregroundStyle(Color(hex: "#453736"))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
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
                                chefsNotes: recipeVM.chefsNotes
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

                            
                            dismiss()

                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.black)
                    }
                }
                .padding(.horizontal, 10)
                .padding()
                
                tabSelectionView
                if selectedTab == 0 {
                    CreateRecipe(recipeVM: recipeVM)
                } else {
                    AIChefBaseView(recipeVM: recipeVM)
                }
            }
            .background(Color(hex: "#fffffc"))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    private var tabSelectionView: some View {
        ZStack(alignment: .bottomLeading){
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#fffffc"))
                .frame(height: 56)
            
            HStack(spacing: 0) {
                
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 8) {
                        Text("Edit Details")
                            .font(.body)
                            .foregroundColor(selectedTab == 0 ? Color(hex: "#404741") : Color(hex: "#7C887DF2"))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 0 ? 1 : 0)
                .background(
                    RoundedCorner(radius: 25, corners: selectedTab == 0 ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                        .fill(selectedTab == 0 ? Color(hex: "#fffffc") : Color(hex: "#F9F5F2"))
                        .frame(width: (UIScreen.main.bounds.width)/2, height: 50)
                        .background(
                            RoundedCorner(radius: 25, corners: selectedTab == 0 ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: (UIScreen.main.bounds.width)/2 + 1, height: 50)
                                .padding(selectedTab == 0 ? .bottom : .top, 3)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(hex: "#fffffc"))
                                        .padding(selectedTab == 0 ? .top : .bottom, 35)
                                )
                        )
                )
                
                Button(action: { selectedTab = 1 }) {
                    VStack(spacing: 8) {
                        Text("AI Chef")
                            .font(.body)
                            .foregroundColor(selectedTab == 1 ? Color(hex: "#404741") : Color(hex: "#7C887DF2"))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 1 ? 2 : 0)
                .background(
                    RoundedCorner(radius: 25, corners: selectedTab == 1 ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft,.topRight,.topLeft])
                        .fill(selectedTab == 1 ? Color(hex: "#fffffc") : Color(hex: "#F9F5F2"))
                        .frame(width: (UIScreen.main.bounds.width)/2, height: 50)
                        .background(
                            //Border over top of tab
                            RoundedCorner(radius: 25, corners: selectedTab == 1 ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft, .topRight,.topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: (UIScreen.main.bounds.width)/2 + 1, height: 50)
                                .padding(selectedTab == 1 ? .bottom : .top, 3)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(hex: "#fffffc"))
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
}

#Preview {
    AddRecipeMain()
        .environment(AuthenticationVM())
}
