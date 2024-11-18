//
//  LoginService.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//
import SwiftUI

struct LoginService {
    
    public func login(username: String, password: String) async throws -> String {
        // 1. Define the URL
        guard let url = URL(string: "https://reading-list-backend.fly.dev/login/") else {
            throw URLError(.badURL)
        }
        
        // 2. Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 3. Create the JSON body
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        // Convert the body to JSON data
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        // 4. Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 5. Check for a valid response
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
                case 200:
                    // Login successfully
                    let json = try JSONDecoder().decode([String: String].self, from: data)
                
                    guard let token = json["token"] else {
                        throw URLError(.cannotParseResponse)
                    }

                    return token
                        
                case 400:
                    // Bad request - likely validation error, parse the error message
                    if let errorResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let errorMessage = errorResponse["error"] as? String {
                        throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    } else {
                        throw URLError(.badServerResponse)
                    }
                        
                default:
                    // Other status codes
                    throw URLError(.badServerResponse)
            }
        } else {
            throw URLError(.badServerResponse)
        }
    }
}
