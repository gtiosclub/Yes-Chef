//
//  HistoryTab.swift
//  Yes Chef
//
//  Created by Nidhi Krishna on 9/20/25.
//

import SwiftUI

struct HistoryTab: View {
    @State private var showPopup = false
    @State private var viewModel = HistoryViewModel()
    
    
    var body: some View {
        Button("HistoryTab", systemImage: "timer.circle.fill") {
            withAnimation { showPopup.toggle() }
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 25))
        
        
        if showPopup {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.history) { history in
                        NavigationLink {
                            //
                        } label: {
                            HStack {
                                Text(history.title)
                                    .frame(alignment: .leading)
                                Spacer()
                                Text(history.challengeName)
                                    .frame(alignment: .leading)
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                        
                    }
                }
                .frame(maxWidth: 300)
                .onAppear {
                        viewModel.fetchHistory()
                }
            }
        }
    }
}

#Preview {
    HistoryTab()
}
