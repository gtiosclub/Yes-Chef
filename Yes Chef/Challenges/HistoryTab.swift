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
    @State private var history: [HistoryBlock] = [HistoryBlock(date: "January 1st-7th", challengeName: "Best 10 ingredient dish"), HistoryBlock(date: "January 1st-7th", challengeName: "Best 9 ingredient dish"), HistoryBlock(date: "January 1st-7th", challengeName: "Best 8 ingredient dish"), HistoryBlock(date: "January 1st-7th", challengeName: "Best 7 ingredient dish"),HistoryBlock(date: "January 1st-7th", challengeName: "Best 6 ingredient dish"),HistoryBlock(date: "January 1st-7th", challengeName: "Best 5 ingredient dish"), HistoryBlock(date: "January 1st-7th", challengeName: "Best 4 ingredient dish"), HistoryBlock(date: "January 1st-7th", challengeName: "Best 3 ingredient dish"), HistoryBlock(date: "January 1st-7th", challengeName: "Best 2 ingredient dish"),HistoryBlock(date: "January 1st-7th", challengeName: "Best 1 ingredient dish")]
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
                if history.isEmpty {
                        Text("No history yet")
                            .foregroundColor(.gray)
                } else {
                    VStack (spacing: 10){
                        ForEach(history) { week in
                            NavigationLink {
                                //to leaderboard with data from that week
                            } label: {
                                VStack () {
                                    Text(week.date)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.subheadline)
                                    
                                    Text(week.challengeName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.black)
                                        .font(.title3)
                                        

                                        
                                }
                                .padding(.horizontal,10) // ← left/right padding
                                .padding(.vertical, 3)
                                .frame(maxWidth: 328, maxHeight: 990)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                                                            .fill(Color(.systemGray4))
                                            
                                )

                            }
                            
                        }
                    }
                }
            }
            .frame(width: 328, height: 400)
            
        }
        /*
        .onAppear {
            viewModel.fetchHistory()
        }*/
    }
}

#Preview {
    HistoryTab()
}
