//
//  Utils.swift
//  VideoRecord
//
//  Created by n3deep on 24.11.16.
//  Copyright © 2016 n3deep. All rights reserved.
//

import Foundation
import KeychainSwift

class Utils {

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    static func getTokenFromKeychain() -> String {
        let keychain = KeychainSwift()
        return keychain.get("AuthToken")!
    }
    static func setTokenFromKeychain(token: String) {
        let keychain = KeychainSwift()
        keychain.set(token, forKey: "AuthToken")
    }
    static func setDateOfTokenExpiration(seconds: Int) {
        let keychain = KeychainSwift()
        keychain.delete("AuthToken")
        let currentDateTime = Date()
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .second, value: seconds, to: currentDateTime)
        UserDefaults.standard.setValue(date, forKey: "ExpirationTokenDate")
    }
    static func isTokenTimeout() -> Bool {
        if (UserDefaults.standard.object(forKey: "ExpirationTokenDate") == nil) {
            return true
        }
        let currentDateTime = Date()
        let expirationTokenDate = UserDefaults.standard.value(forKey: "ExpirationTokenDate") as! Date
        if currentDateTime >= expirationTokenDate {
            return true
        } else {
            return false
        }
    }
}
