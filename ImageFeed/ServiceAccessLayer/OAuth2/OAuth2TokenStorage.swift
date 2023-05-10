import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private enum Keys: String {
        case bearerToken1
    }
    
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.bearerToken1.rawValue)
        }
        set {
            guard let newValue = newValue else { return }
            KeychainWrapper.standard.set(newValue, forKey: Keys.bearerToken1.rawValue)
        }
    }
}
