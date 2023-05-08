//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Igor Ignatov on 08.05.2023.
//
import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private init() {}
    
    private func prepareRequest() -> URLRequest? {
        guard let token = OAuth2TokenStorage().token,
        var url = URL(string: baseURLString)
        else { return nil }

        
        if #available(iOS 16.0, *) {
            url.append(path: "/me")
        } else {
            url.appendPathComponent("/me")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = prepareRequest() else { return }
       
        let сompletionOnMainQueue: (Result<Profile, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let model):
                let profile = Profile(username: model.username,
                                      firstName: model.firstName,
                                      lastName: model.lastName ?? "",
                                      bio: model.bio ?? "")
                
                self?.profile = profile
                сompletionOnMainQueue(.success(profile))
            case .failure(let error):
                сompletionOnMainQueue(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func clean() {
        task = nil
        profile = nil
    }
}
