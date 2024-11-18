//
//  LoginViewModel.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var loginStatus: String?
    @Published var loginSuccess: Bool = false
    @Published var currentlyLoggingIn: Bool = false
    private var jwtToken: String?
    
    func login() async {
        let loginService = LoginService()
        self.currentlyLoggingIn = true
        do {
            let token = try await loginService.login(username: username, password: password)
            jwtToken = token
            loginSuccess = true
            self.currentlyLoggingIn = false
            loginStatus = ""
            KeychainHelper.shared.save(token, forKey: "jwtToken")
        } catch {
            loginSuccess = false
            self.currentlyLoggingIn = false
            loginStatus = "Login Failed: \(error.localizedDescription)"
        }
    }
}
