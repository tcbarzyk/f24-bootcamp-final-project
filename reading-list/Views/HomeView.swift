//
//  HomeView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var user: User?
    @Binding var path: NavigationPath
    var refreshUser: () async -> Void
    
    var body: some View {
        ZStack {
            TabView {
                SearchView(user: $user, refreshUser: refreshUser)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                ListView(user: $user, refreshUser: refreshUser)
                    .tabItem {
                        Label("List", systemImage: "text.book.closed")
                    }
                AccountView(path: $path, user: $user)
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
