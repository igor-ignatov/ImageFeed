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
    
    private func prepareRequest() -> URLRequest? {
        let nextPage = lastLoadedPage + 1
        lastLoadedPage = nextPage
        let path = "/photos"
        let queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let token = oAuth2TokenStorage.token, var urlComponents = URLComponents(string: BaseURLString)
        else { return nil }
        
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        
        guard let request = prepareRequest() else { return }
        
        if photos.count == 0 { UIBlockingProgressHUD.show() }
        
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
                print(error)
            }
            
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
}
