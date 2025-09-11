//
//  ContentView.swift
//  Yes Chef
//
//  Created by Nitya Potti on 8/30/25.
//

import SwiftUI

struct ContentView: View {
    @State var authVM = AuthenticationVM()
    
    var body: some View {
        if authVM.isLoggedIn {
            Home()
                .environment(authVM)
        } else {
            Login()
                .environment(authVM)
        }
    }
}
