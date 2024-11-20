//
//  ListView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import SwiftUI

struct ListView: View {
    @Binding var user: User?
    var refreshUser: () async -> Void
    
    var body: some View {
        ZStack {
            VStack (spacing: 25) {
                Text("List Sections")
                    .font(.system(size: 48, weight: .bold))
                    .padding(.top, 80)
                if let unwrappedUser = user {
                    NavigationLink(destination: {
                        ListSectionView(
                            books: Binding(
                                get: { unwrappedUser.books.filter { $0.userInfo.status == "to read" } },
                                set: { _ in }
                            ),
                            title: "To Read",
                            refreshUser: refreshUser
                        )
                    }
                    ) {
                        Text("To Read")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                    }
                    .buttonStyle(.bordered)
                    NavigationLink(destination: {
                        ListSectionView(
                            books: Binding(
                                get: { unwrappedUser.books.filter { $0.userInfo.status == "reading" } },
                                set: { _ in }
                            ),
                            title: "Reading",
                            refreshUser: refreshUser
                        )
                    }
                    ) {
                        Text("Reading")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                    }
                    .buttonStyle(.bordered)
                    NavigationLink(destination: {
                        ListSectionView(
                            books: Binding(
                                get: { unwrappedUser.books.filter { $0.userInfo.status == "has read" } },
                                set: { _ in }
                            ),
                            title: "Has Read",
                            refreshUser: refreshUser
                        )
                    } ) {
                        Text("Has Read")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                    }
                    .buttonStyle(.bordered)
                }
                else {
                    Text("Error getting user data")
                }
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}

