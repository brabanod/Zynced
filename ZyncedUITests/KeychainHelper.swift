//
//  KeychainHelper.swift
//  ZyncedUITests
//
//  Created by Pascal Braband on 28.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation

public enum KeychainError: Error, Equatable {
    case itemNotFound
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}


public class KeychainHelper {
    
    public static func getItem(user: String, host: String) throws -> String?  {
        // Query with parameters for searching the item
        let searchQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                             kSecAttrServer as String: host,
                                             kSecAttrAccount as String: user,
                                             kSecMatchLimit as String: kSecMatchLimitOne,
                                             kSecReturnAttributes as String: true,
                                             kSecReturnData as String: true]

        // Get item from keychain
        var item: CFTypeRef?
        let searchStatus = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        guard searchStatus != errSecItemNotFound else { throw KeychainError.itemNotFound }
        guard searchStatus == errSecSuccess else { throw KeychainError.unhandledError(status: searchStatus) }

        // Extract password from item
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }
        return password
    }
}
