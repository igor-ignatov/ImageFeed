//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Igor Ignatov on 08.05.2023.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private init() {}
    
    private func prepareRequest(username: String) -> URLRequest? {
        guard let token = oAuth2TokenStorage.token,
              var url = URL(string: BaseURLString)
        else { return nil }
        
        if #available(iOS 16.0, *) {
            url.append(path: "/users/\(username)")
        } else {
            url.appendPathComponent("/users/\(username)")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = prepareRequest(username: username) else { return }
        
        let сompletionOnMainQueue: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .failure(let error):
                print(error)
                сompletionOnMainQueue(.failure(error))
                break
            case .success(let model):
                сompletionOnMainQueue(.success(model.profileImage.medium))
                self.avatarURL = model.profileImage.medium
                self.task = nil
                let avatarURL = model.profileImage.medium
                
                DispatchQueue.main.async {
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL])
                }
            }
        }
        
        self.task = task
        
        task.resume()
    }
}
