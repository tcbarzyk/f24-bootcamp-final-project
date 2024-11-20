//
//  UserService.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/14/24.
//
import SwiftUI

class UserService {
    func getUser(query: String) async throws -> User {
        guard let url = URL(string: "https://reading-list-backend.fly.dev/api/users/\(query)") else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let response = try JSONDecoder().decode(User.self, from: data)
            let user = response
            return user
        } catch {
            print("Failed to decode JSON: \(error)")
            throw URLError(.cannotDecodeRawData)
        }
    }
}
