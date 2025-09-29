//
//  HistoryTab.swift
//  Yes Chef
//
//  Created by Nidhi Krishna on 9/20/25.
//

import SwiftUI

struct HistoryTab: View {
    @State private var showPopup = false
    @StateObject private var viewModel = HistoryViewModel()
    @State private var searchEntry: String = ""
    @State private var thisWeekPrompt: String = "This week's prompt"
    @State private var selectedYear: String = ""
    @State private var years: [String] = ["2025", "2024", "2023"]
    @State private var isExpanded: Bool = false
    
    
    var body: some View {
        
        VStack(spacing: 10) {
            Text("History")
                .font(.largeTitle)
                .frame(alignment: .center)
            
            
            VStack(spacing: 20) {
                Text("This week:")
                    .foregroundStyle(Color(.systemGray))
                //need to update: space holder
                Text(thisWeekPrompt)
            }
                .frame(maxWidth: 328, maxHeight: 99)
                .background(Color(.systemGray4))
                .cornerRadius(10)
            
            //Space holder
            TextField(" Search", text: $searchEntry)
                .frame(maxWidth: 328, maxHeight: 57)
                .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
            
            //Space Holder
            TextField(" Select Year", text: $searchEntry)
                .frame(maxWidth: 328, maxHeight: 57)
                .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                )
            
            ScrollView {
                if viewModel.history.isEmpty {
                        Text("No history yet")
                            .foregroundColor(.gray)
                } else {
                    VStack (spacing: 20){
                        ForEach(viewModel.history) { history in
                            NavigationLink {
                                //to leaderboard with data from that week
                            } label: {
                                Text(history.challengeName).frame(maxWidth: 328, maxHeight: 99)
                                    .background(Color(.systemGray4))
                                    .cornerRadius(10)
                            }
                            
                            
                        }
                    }
                }
            }
            .frame(maxWidth: 328, maxHeight: 400)
            
        }
        .onAppear {
            viewModel.fetchHistory()
        }
    }
}

#Preview {
    HistoryTab()
}
