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
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.main.opacity(1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack (spacing: 25) {
                Text("List Sections")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 80)
                if let unwrappedUser = user {
                    NavigationLink(destination: {
                        ListSectionView(
                            books: Binding(
                                get: { unwrappedUser.books.filter { $0.userInfo.status == "reading" } },
                                set: { _ in } // This is just to satisfy the Binding requirement; modify if needed
                            ),
                            title: "Reading",
                            refreshUser: refreshUser
                        )
                    }
                    ) {
                        Text("Reading")
                            .padding()
                            .foregroundStyle(Color.textColor)
                            .bold()
                            .frame(maxWidth: 150)
                            .background(Color.accent)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .font(.title2)
                    }
                    NavigationLink(destination: {
                        ListSectionView(
                            books: Binding(
                                get: { unwrappedUser.books.filter { $0.userInfo.status == "to read" } },
                                set: { _ in } // This is just to satisfy the Binding requirement; modify if needed
                            ),
                            title: "To Read",
                            refreshUser: refreshUser
                        )
                    }
                    ) {
                        Text("To Read")
                            .padding()
                            .foregroundStyle(Color.textColor)
                            .bold()
                            .frame(maxWidth: 150)
                            .background(Color.accent)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .font(.title2)
                    }
                    NavigationLink(destination: {
                        ListSectionView(
                            books: Binding(
                                get: { unwrappedUser.books.filter { $0.userInfo.status == "has read" } },
                                set: { _ in } // This is just to satisfy the Binding requirement; modify if needed
                            ),
                            title: "Has Read",
                            refreshUser: refreshUser
                        )
                    } ) {
                        Text("Has Read")
                            .padding()
                            .foregroundStyle(Color.textColor)
                            .bold()
                            .frame(maxWidth: 150)
                            .background(Color.accent)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .font(.title2)
                    }
                }
                else {
                    Text("Error getting user data")
                        .foregroundColor(.textColor)
                }
                Spacer()
            }
        }
    }
}

