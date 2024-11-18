//
//  BookSearchService.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//
import SwiftUI

class BookSearchService {
    func searchBooks(query: String) async throws -> [Book] {
        guard let url = URL(string: "https://openlibrary.org/search.json?q=\(query)&lang=ene") else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            // Decode to SearchResponse, then access the docs array
            let response = try JSONDecoder().decode(SearchResponse.self, from: data)
            let books = response.docs
            //print(books) // Array of Book instances populated with JSON data
            return books
        } catch {
            print("Failed to decode JSON: \(error)")
            throw URLError(.cannotDecodeRawData)
        }
    }
}
