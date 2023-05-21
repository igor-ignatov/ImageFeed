import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let key = "bearerToken"
    private let keychain = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychain.string(forKey: OAuth2TokenStorage.key)
        }
        set {
            guard let newValue = newValue else { return }
            keychain.set(newValue, forKey: OAuth2TokenStorage.key)
        }
    }
}
