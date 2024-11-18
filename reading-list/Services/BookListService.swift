//
//  BookListService.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import SwiftUI

class BookListService {
    public func addNewBook(token: String, key: String, notes: String, status: String, coverKey: String) async throws -> String {
        // 1. Define the URL
        guard let url = URL(string: "https://reading-list-backend.fly.dev/api/books/") else {
            throw URLError(.badURL)
        }
        
        // 2. Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 3. Create the JSON body
        let body: [String: Any] = [
            "key": key,
            "userInfo": [
                "notes": notes,
                "status": status
            ],
            "coverKey": coverKey
        ]
        
        // Convert the body to JSON data
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        // 4. Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 5. Check for a valid response
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
                case 201:
                    if let responseString = String(data: data, encoding: .utf8) {
                        return responseString
                    } else {
                        throw URLError(.cannotDecodeRawData)
                    }
                        
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
    
    public func editBook(token: String, id: String, notes: String, status: String) async throws -> String {
        // 1. Define the URL
        guard let url = URL(string: "https://reading-list-backend.fly.dev/api/books/\(id)") else {
            throw URLError(.badURL)
        }
        
        // 2. Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 3. Create the JSON body
        let body: [String: Any] = [
            "userInfo": [
                "notes": notes,
                "status": status
            ]
        ]
        
        // Convert the body to JSON data
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        // 4. Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 5. Check for a valid response
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
                case 200:
                    if let responseString = String(data: data, encoding: .utf8) {
                        return responseString
                    } else {
                        throw URLError(.cannotDecodeRawData)
                    }
                        
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
    
    public func deleteBook(token: String, id: String) async throws -> String {
        // 1. Define the URL
        guard let url = URL(string: "https://reading-list-backend.fly.dev/api/books/\(id)") else {
            throw URLError(.badURL)
        }
        
        // 2. Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 4. Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 5. Check for a valid response
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
                case 204:
                    if let responseString = String(data: data, encoding: .utf8) {
                        return responseString
                    } else {
                        throw URLError(.cannotDecodeRawData)
                    }
                        
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
