//
//  Yes_ChefApp.swift
//  Yes Chef
//
//  Created by Nitya Potti on 8/30/25.
//
import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      if let app = FirebaseApp.app() {
          print("Firebase configured with name: \(app.name)")
      } else {
          print("❌ Firebase configuration failed")
      }
    return true
  }
}

@main
struct Yes_ChefApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}

