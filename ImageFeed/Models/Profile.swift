import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(username: String, firstName: String, lastName: String, bio: String) {
        self.username = username
        self.name = "\(firstName) \(lastName)"
        self.loginName = "@\(username)"
        self.bio = bio
    }
}

struct UserResult: Decodable {
    let profile_image: ProfileImage
}

struct ProfileImage: Decodable {
    let small: String
    let medium: String
}
