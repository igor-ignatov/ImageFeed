//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Igor Ignatov on 20.05.2023.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let dateFormatter = ISO8601DateFormatter()
    private var task: URLSessionTask?
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    
    func fetchPhotosNextPage(_ completion:  @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        
        let nextPage = lastLoadedPage + 1
        lastLoadedPage = nextPage
        
        let queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard var request = makeRequest(path: "/photos", queryItems: queryItems) else { return assertionFailure("Error get images request")}
        request.httpMethod = "GET"
        
        task?.cancel()
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            if self?.photos.count == 0 { UIBlockingProgressHUD.dismiss() }
            
            switch result {
            case .success(let photoResult):
                photoResult.forEach { photoResult in
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self?.dateFormatter.date(from: photoResult.createdAt ?? ""),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        fullImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser)
                    
                    DispatchQueue.main.async {
                        self?.photos.append(photo)
                    }
                }
                
                if let photos = self?.photos {
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self, userInfo: ["photos": photos])
                }
            case .failure(let error):
                completion(.failure(error))
            }
            
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Photo, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard var request = makeRequest(path: "/photos/\(photoId)/like") else { return assertionFailure("Error like request")}
        
        if isLike {
            request.httpMethod = "POST"
        } else {
            request.httpMethod = "DELETE"
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        fullImageURL: photo.fullImageURL,
                        isLiked: !photo.isLiked)
                    
                    DispatchQueue.main.async {
                        self.photos[index] = newPhoto
                    }
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self, userInfo: ["photos": photos])
                    
                    completion(.success((newPhoto)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        
        self.task = task
        task.resume()
    }
    
    
    private func makeRequest(path: String, queryItems: [URLQueryItem]? = nil) -> URLRequest? {
        guard let token = oAuth2TokenStorage.token, var urlComponents = URLComponents(string: BaseURLString)
        else { return nil }
        
        urlComponents.path = path
        if queryItems != nil { urlComponents.queryItems = queryItems }
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
}
