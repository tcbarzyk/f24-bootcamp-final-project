//
//  UserModel.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/14/24.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let books: [UserBook]
    let dateCreated: String
}
