//
//  SignupViewModel.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import Foundation

class SignupViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var currentlySigningUp: Bool = false
    
    @Published var signupStatus: String?
    @Published var success: Bool = false
    
    private let signupService = SignupService()
    
    func signup() async {
        self.currentlySigningUp = true
        do {
            let _ = try await signupService.createAccount(username: username, email: email, password: password)
            DispatchQueue.main.async {
                self.signupStatus = "Signup successful!"
                self.success = true
                self.currentlySigningUp = false
            }
        } catch {
            DispatchQueue.main.async {
                self.signupStatus = "Signup failed: \(error.localizedDescription)"
                self.success = false
                self.currentlySigningUp = false
            }
        }
    }
}
