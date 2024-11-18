//
//  SearchViewModel.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var books: [Book] = []
    
    private let searchService = BookSearchService()
    
    func performSearch() async {
        guard !searchQuery.isEmpty else { return }
        
        do {
            books = try await searchService.searchBooks(query: searchQuery)
        } catch {
            print("Search failed: \(error)")
            books = []
        }
    }
}
