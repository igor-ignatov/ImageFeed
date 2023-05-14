import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let key = "bearerToken"
    private let keychain = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychain.string(forKey: key)
        }
        set {
            guard let newValue = newValue else { return }
            keychain.set(newValue, forKey: key)
        }
    }
}
