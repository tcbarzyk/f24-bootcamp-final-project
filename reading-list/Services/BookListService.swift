//
//  BookListService.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import SwiftUI

class BookListService {
    public func addNewBook(token: String, key: String, notes: String, status: String, coverKey: String) async throws -> String {
        guard let url = URL(string: "https://reading-list-backend.fly.dev/api/books/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "key": key,
            "userInfo": [
                "notes": notes,
                "status": status
            ],
            "coverKey": coverKey
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
    
    public func editBook(token: String, id: String, notes: String, status: String) async throws -> String {
        guard let url = URL(string: "https://reading-list-backend.fly.dev/api/books/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "userInfo": [
                "notes": notes,
                "status": status
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
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
    
    public func deleteBook(token: String, id: String) async throws -> String {
        guard let url = URL(string: "https://reading-list-backend.fly.dev/api/books/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 204:
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
