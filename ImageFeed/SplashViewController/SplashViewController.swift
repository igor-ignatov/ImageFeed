import UIKit

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    private func initSplashImage() {
        let image = UIImage(named: "auth_screen_logo")
        let splashLogoImage = UIImageView(image: image)
        
        splashLogoImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(splashLogoImage)
        NSLayoutConstraint.activate([
            splashLogoImage.heightAnchor.constraint(equalToConstant: 78),
            splashLogoImage.widthAnchor.constraint(equalToConstant: 75),
            splashLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashLogoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "ypBlack")
        initSplashImage()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            UIBlockingProgressHUD.show()
            fetchProfile(token: token)
            switchToTabBarController()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            
            guard let authViewController =
                    storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                return
            }

            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            
            self.present(authViewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                self.oauth2TokenStorage.token = token
                self.fetchProfile(token: token)
                break
            case .failure:
                UIBlockingProgressHUD.dismiss()
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else {  return }

            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
                break
            case .failure:
                self.showErrorAlert()
                break
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
