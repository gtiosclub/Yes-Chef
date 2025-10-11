//
//  HeaderTabsView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/2/25.
//
import SwiftUI

struct HeaderTabsView: View {
    @State private var selectedTab: String = "EditDetails"
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0){
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
                                media: recipeVM.mediaInputs
                            )
                            
//                            await FirebaseDemo.addRecipeToRemixTreeAsRoot(
//                                description: recipeVM.description,
//                            )
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .bold()
                    }
                }
                .padding(.horizontal, 10)
                .padding()
                
                HStack{
                    curvedTab(title: "Edit Details", tag: "EditDetails", leftSide: true)
                    curvedTab(title: "AI Chef", tag: "AIChef", leftSide: false)
                }.frame(height: 50)
            }
            VStack {
                if selectedTab == "EditDetails" {
                    CreateRecipe()
                } else if selectedTab == "AIChef" {
                    Text("Coming Soon")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }
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
                                Color.white
                            } else {
                                Color(.systemBrown).opacity(0.25)
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
        
        // Start at bottom left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Line up to top left corner curve
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // Top left corner arc
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        // Line across the top
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // Top right corner arc
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // Line down to bottom right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Line across the bottom (flat)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}

struct TabBorder: Shape {
    var cornerRadius: CGFloat = 12
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start at bottom left (don't draw bottom border)
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Line up the left side
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // Top left corner arc
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        // Line across the top
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // Top right corner arc
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // Line down the right side
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        return path
    }
}

struct HeaderTabsView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderTabsView()
    }
}
