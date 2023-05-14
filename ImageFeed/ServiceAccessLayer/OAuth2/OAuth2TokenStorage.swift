import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private enum Keys: String {
        case bearerToken
    }
    
    private let keychain = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychain.string(forKey: Keys.bearerToken.rawValue)
        }
        set {
            guard let newValue = newValue else { return }
            keychain.set(newValue, forKey: Keys.bearerToken.rawValue)
        }
    }
}
