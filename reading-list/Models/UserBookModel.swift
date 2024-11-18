//
//  UserBookModel.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//
/*
struct UsersSearchResponse: Codable {
    let books: [UserBook]
}*/

struct UserBook: Codable, Identifiable {
    let id: String
    let key: String
    let userInfo: UserInfo
    let bookInfo: BookInfo
    /*
    private enum CodingKeys: String, CodingKey {
        case id = "key"
        case userInfo
        case bookInfo
    }*/
}

struct UserInfo: Codable {
    let notes: String
    let status: String
}

struct BookInfo: Codable {
    let title: String
    let description: String?
    let coverKey: String
    let author: AuthorInfo
}

struct AuthorInfo: Codable {
    let key: String
    let name: String
    let bio: String?
}
