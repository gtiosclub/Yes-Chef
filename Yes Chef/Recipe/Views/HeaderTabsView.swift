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
                    Image(systemName: "xmark").font(.title2)
                        .foregroundStyle(.red)
                        .bold()
                    Spacer()
                    Text("Add Recipe").font(.custom("Georgia", size: 32)).fontWeight(.bold)
                    Spacer()
                    Image(systemName: "checkmark").font(.title2)
                        .foregroundStyle(.gray)
                        .bold()
                }.padding(.horizontal)
                HStack{
                    curvedTab(title: "Edit Details", tag: "EditDetails", leftSide: true)
                    curvedTab(title: "AI Chef", tag: "AIChef", leftSide: false)
                }.frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
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
                Spacer() // pushes content to top
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    private func curvedTab(title: String, tag: String, leftSide: Bool) -> some View {
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
                                    Color(.systemBrown).opacity(0.25) // Tan-like
                                }
                            }
                        )
                        .foregroundColor(.black)
                        .clipShape(
                            RoundedCornerShape(
                                topLeft: 0,
                                topRight: 0,
                                bottomLeft: leftSide ? 16 : 0,
                                bottomRight: leftSide ? 0 : 16
                            )
                        )
                }
                .buttonStyle(.plain)
            }
}
// MARK: - Custom shape for selective corners
struct RoundedCornerShape: Shape {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addArc(center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
                    radius: bottomRight,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
                    radius: bottomLeft,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addArc(center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
                    radius: topLeft,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)

        return path
    }
}

struct HeaderTabsView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderTabsView()
    }
}
