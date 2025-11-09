//
//  ContentView.swift
//  Yes Chef
//
//  Created by Nitya Potti on 8/30/25.
//

import SwiftUI

struct ContentView: View {
    //@State var authVM = AuthenticationVM()
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        if let user = authVM.currentUser {
            Home()
                .environment(authVM)
        } else {
            AccountCreationView()
                .environment(authVM)
        }
    }
}
