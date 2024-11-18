//
//  KeychainHelper.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import Foundation
import Security

struct KeychainHelper {
    static let shared = KeychainHelper()

    func save(_ token: String, forKey key: String) {
        guard let tokenData = token.data(using: .utf8) else { return }

        // Delete any existing item
        delete(forKey: key)

        // Create a query for storing the token
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData
        ]

        // Add the token to the Keychain
        SecItemAdd(query as CFDictionary, nil)
    }

    func retrieve(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        if let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }

    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
