//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Igor Ignatov on 05.04.2023.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
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
        
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        let exitButton = UIButton()
        let exitButtonImage = UIImage(named: "logout_button")
        exitButton.setImage(exitButtonImage, for: .normal)
        
        topContainer.addArrangedSubview(imageView)
        topContainer.addArrangedSubview(exitButton)
        
        // Name label
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(named: "ypWhite")
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        
        // Nickname
        let nicknameLabel = UILabel()
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.text = "@ekaterina_nov"
        nicknameLabel.textColor = UIColor(named: "ypGray")
        
        // Text
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "Hello, world!"
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
    }
}
