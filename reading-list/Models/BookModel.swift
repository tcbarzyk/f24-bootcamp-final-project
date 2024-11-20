//
//  BookModel.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

struct SearchResponse: Codable {
    let docs: [Book]
}

struct Book: Identifiable, Codable {
    let id: String
    let title: String
    let authors: [String]?
    let coverKey: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "key"
        case title = "title"
        case authors = "author_name"
        case coverKey = "cover_edition_key"
    }
}

extension Book {
    var author: String {
        authors?.first ?? "Unknown Author"
    }
}
