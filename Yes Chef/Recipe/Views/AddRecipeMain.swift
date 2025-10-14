//
//  HeaderTabsView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/2/25.
//
import SwiftUI

struct AddRecipeMain: View {
    @State private var selectedTab: String = "EditDetails"
    @State private var recipeVM = CreateRecipeVM()
    
    var body: some View {
        NavigationStack{
            VStack(){
                HStack{
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width:20, height:20)
                        .foregroundStyle(.black)
                    Spacer()
                    
                    Text("Add Recipe")
                        .font(.custom("Georgia", size: 30))
                        .foregroundStyle(Color(hex: "#453736"))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await recipeVM.createRecipe(
                                userId: recipeVM.userIdInput,
                                name: recipeVM.name,
                                ingredients: recipeVM.ingredients,
                                allergens: recipeVM.allergens,
                                tags: recipeVM.tags,
                                steps: recipeVM.steps,
                                description: recipeVM.description,
                                prepTime: recipeVM.prepTime,
                                difficulty: recipeVM.difficulty,
                                servingSize: recipeVM.servingSize,
                                media: recipeVM.localMediaPaths,
                                chefsNotes: recipeVM.chefsNotes
                            )
                            
//                            await FirebaseDemo.addRecipeToRemixTreeAsRoot(
//                                description: recipeVM.description,
//                            )
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
                
                HStack{
                    curvedTab(title: "Edit Details", tag: "EditDetails", leftSide: true)
                    curvedTab(title: "AI Chef", tag: "AIChef", leftSide: false)
                }.frame(height: 50)
            }
            .background(Color(hex: "#fffdf5"))
            
            VStack {
                if selectedTab == "EditDetails" {
                    CreateRecipe(recipeVM: recipeVM)
                } else if selectedTab == "AIChef" {
                    Text("Coming Soon")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Spacer()
                }
            }
            .background(Color(hex: "#fffdf5"))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    private func curvedTab(title: String, tag: String, leftSide: Bool) -> some View {
        ZStack {
            Button(action: {
                selectedTab = tag
            }) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Group {
                            if selectedTab == tag {
                                Color(hex: "#fffdf5")
                            } else {
                                Color(hex: "#cdc2ba")
                            }
                        }
                    )
                    .foregroundColor(.black)
                    .clipShape(
                        TabShape()
                    )
                    .overlay(
                        TabBorder(cornerRadius: 16)
                                    .stroke(Color.gray, lineWidth: 1)
                    )
                
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Custom shape for selective corners
struct TabShape: Shape {
    var cornerRadius: CGFloat = 12
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}

struct TabBorder: Shape {
    var cornerRadius: CGFloat = 12
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        return path
    }
}

#Preview {
    AddRecipeMain()
}
