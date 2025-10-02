//
//  HeaderTabsView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/2/25.
//
import SwiftUI

struct HeaderTabsView: View {
    @State private var selectedTab: String? = nil
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0){
                HStack{
                    Image(systemName: "xmark").font(.title2)
                        .foregroundStyle(.red)
                        .bold()
                    Spacer()
                    Text("Add Recipe").font(.title).fontWeight(.bold)
                    Spacer()
                    Image(systemName: "checkmark").font(.title2)
                        .foregroundStyle(.gray)
                        .bold()
                }.padding(.horizontal)
                HStack{
                    Spacer()
                    Button("Edit Details") {
                        selectedTab = "EditDetails"
                    }.padding()
                    Spacer()
                    Button("AI Chef"){
                        selectedTab = "AIChef"
                    }
                    Spacer()
                }
            }
            Divider()
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
}
struct HeaderTabsView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderTabsView()
    }
}
