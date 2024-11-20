//
//  LoginService.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//
import SwiftUI

struct LoginService {
    
    public func login(username: String, password: String) async throws -> String {
        guard let url = URL(string: "https://reading-list-backend.fly.dev/login/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                let json = try JSONDecoder().decode([String: String].self, from: data)
                
                guard let token = json["token"] else {
                    throw URLError(.cannotParseResponse)
                }
                
                return token
                
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
