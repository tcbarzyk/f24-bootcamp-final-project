//
//  ContentView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State var path = NavigationPath()
    @State var user: User?
    @State var isLoadingUser: Bool = true
    let userService = UserService()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack {
                    Text("Reading List")
                        .font(.system(size: 60, weight: .bold))
                        .padding(.top, 70)
                        .padding(.bottom, 30)
                    if (appState.isLoggedIn && !isLoadingUser) {
                        if let unwrappedUser = user {
                            Text("Logged in as \(unwrappedUser.username)")
                                .font(.title)
                            NavigationLink(value: "Home") {
                                Text("Go to Home")
                                    .bold()
                                    .font(.title2)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        else {
                            Text("Failed to get user")
                                .font(.title)
                            Button(action: {
                                Task {
                                    await fetchUser()
                                }
                            }) {
                                Text("Retry")
                                    .bold()
                                    .font(.title2)
                            }
                            .buttonStyle(.borderedProminent)
                            Button(action: {
                                appState.logout()
                            }) {
                                Text("Logout")
                                    .bold()
                                    .font(.title2)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    else if (appState.isLoggedIn && isLoadingUser) {
                        ProgressView("Loading User...")
                            .padding()
                    }
                    else {
                        Text("You are not currently logged in")
                            .font(.title)
                        NavigationLink(value: "Login") {
                            Text("Go to Login")
                                .bold()
                                .font(.title2)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "Home" {
                    HomeView(user: $user, path: $path, refreshUser: fetchUser)
                } else if value == "Login" {
                    LoginView(path: $path)
                }
            }
        }
        .onAppear {
            Task {
                if (appState.isLoggedIn) {
                    await fetchUser()
                }
            }
        }
        .onChange(of: appState.isLoggedIn) {
            if !appState.isLoggedIn {
                user = nil
            }
            if appState.isLoggedIn {
                Task {
                    await fetchUser()
                }
            }
        }
    }
    
    func fetchUser() async {
        do {
            if let token = KeychainHelper.shared.retrieve(forKey: "jwtToken") {
                if let decodedToken = decodeJWT(token) {
                    if let userId = decodedToken["id"] as? String {
                        user = try await userService.getUser(query: userId)
                        isLoadingUser = false
                    }
                    else {
                        print("Failed to get id from token")
                        isLoadingUser = false
                    }
                }
                else {
                    print("Failed to decode token")
                    isLoadingUser = false
                }
            }
            else {
                print("Failed to get user token")
                isLoadingUser = false
            }
        } catch {
            print("Failed to fetch user: \(error)")
            isLoadingUser = false
        }
    }
    
    func decodeJWT(_ jwt: String) -> [String: Any]? {
        let segments = jwt.split(separator: ".")
        guard segments.count == 3 else {
            print("Invalid JWT format")
            return nil
        }
        
        let payloadSegment = segments[1]
        
        var base64String = String(payloadSegment)
        
        base64String = base64String
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        while base64String.count % 4 != 0 {
            base64String.append("=")
        }
        
        guard let payloadData = Data(base64Encoded: base64String) else {
            print("Failed to base64-decode the payload")
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: payloadData, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
