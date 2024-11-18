//
//  AppState.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn = false

    init() {
        if let _ = KeychainHelper.shared.retrieve(forKey: "jwtToken") {
            isLoggedIn = true
        }
    }
    
    func logout() {
        KeychainHelper.shared.delete(forKey: "jwtToken")
        isLoggedIn = false
    }
}
