import Foundation


final class OAuth2Service {
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents?.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                completion(.failure(NSError(domain: "NetworkError", code: response.statusCode, userInfo: nil)))

                return
            }
            
            do {
                let responseBody = try JSONDecoder().decode(OAuth2TokenResponseBody.self, from: data)
                
                completion(.success(responseBody.accessToken))
            } catch let error {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
