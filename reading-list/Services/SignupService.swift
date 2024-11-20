//
//  SignupService.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//
import SwiftUI

struct SignupService {
    
    public func createAccount(username: String, email: String, password: String) async throws -> String {
        guard let url = URL(string: "https://reading-list-backend.fly.dev/api/users/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 201:
                if let responseString = String(data: data, encoding: .utf8) {
                    return responseString
                } else {
                    throw URLError(.cannotDecodeRawData)
                }
                
            case 400:
                if let errorResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = errorResponse["error"] as? String {
                    throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                } else {
                    throw URLError(.badServerResponse)
                }
                
            default:
                throw URLError(.badServerResponse)
            }
        } else {
            throw URLError(.badServerResponse)
        }
    }
}
