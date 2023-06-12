//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Igor Ignatov on 05.04.2023.
//

import Foundation
import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    private var oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Top container
        let topContainer = UIStackView()
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        topContainer.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        topContainer.isLayoutMarginsRelativeArrangement = true
        topContainer.axis = .horizontal
        topContainer.alignment = .fill
        topContainer.spacing = 0
        topContainer.contentMode = .scaleToFill
        topContainer.distribution = .equalSpacing
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        let exitButton = UIButton()
        let exitButtonImage = UIImage(named: "logout_button")
        exitButton.setImage(exitButtonImage, for: .normal)
        exitButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        exitButton.accessibilityIdentifier = "LogOutButton"

        topContainer.addArrangedSubview(imageView)
        topContainer.addArrangedSubview(exitButton)
        
        // Name label
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor(named: "ypWhite")
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        
        // Nickname
        let nicknameLabel = UILabel()
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.textColor = UIColor(named: "ypGray")
        
        // Bio
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor(named: "ypWhite")
        
        // >>> Render main container
        let container = UIStackView(arrangedSubviews: [topContainer, nameLabel, nicknameLabel, textLabel])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.alignment = .fill
        container.contentMode = .scaleToFill
        container.distribution = .fill
        container.spacing = 8
        
        view.backgroundColor = UIColor(named: "ypBlack")
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            topContainer.topAnchor.constraint(equalTo: container.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 70),
            
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            exitButton.widthAnchor.constraint(equalToConstant: 22),
            
            nameLabel.heightAnchor.constraint(equalToConstant: 22),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
        
        addProfileAvatarObserver()
        
        guard let token = oAuth2TokenStorage.token else { return UIBlockingProgressHUD.dismiss() }
        
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case let .success(profile):
                self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                nameLabel.text = profile.name
                nicknameLabel.text = "@\(profile.username)"
                textLabel.text = profile.bio
                break
            case .failure:
                self.showErrorAlert()
                break
            }
            
        }
    }
    
    @objc private func didTapLogoutButton() {
            let alert = UIAlertController(title: "Выход", message: "Вы желаете выйти?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.logOut()
            }))
            
            alert.addAction(UIAlertAction(title: "Нет", style: .default))
            self.present(alert, animated: true)
        }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    
    private func addProfileAvatarObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35, backgroundColor: UIColor(named: "ypBlack"))
        
        self.imageView.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    private func logOut() {
        WebViewViewController.cleanCookies()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Error")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}
