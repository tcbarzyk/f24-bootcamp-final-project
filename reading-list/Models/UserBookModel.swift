//
//  UserBookModel.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

struct UserBook: Codable, Identifiable {
    let id: String
    let key: String
    let userInfo: UserInfo
    let bookInfo: BookInfo
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
