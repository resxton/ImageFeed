//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 30.01.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    // MARK: - Private Properties
    private var avatarImageView: UIImageView?
    private var noPhotoImageView: UIImageView?
    
    private var logoutButton: UIButton?

    private var nameLabel: UILabel?
    private var tagLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var favoritesLabel: UILabel?
    
    private enum ImagesNames: String {
        case avatar = "Avatar"
        case noPhoto = "Favorites-No Photo"
        case logout = "Logout"
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupAvatarImageView() {
        guard let avatarImage = UIImage(named: ImagesNames.avatar.rawValue) else { return }
        
        avatarImageView = UIImageView(image: avatarImage)
        
        guard let avatarImageView else { return }
        
        // Basic setup
        avatarImageView.layer.cornerRadius = 35
        view.addSubview(avatarImageView)
        
        // Constraints
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupLogoutButton() {
        guard let logoutImage = UIImage(named: ImagesNames.logout.rawValue) else { return }
        
        logoutButton = UIButton.systemButton(with: logoutImage, target: nil, action: #selector(didTapLogoutButton))
        
        guard let logoutButton else { return }
        
        // Basic setup
        logoutButton.tintColor = UIColor.ypRed
        view.addSubview(logoutButton)
        
        // Constraints
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        guard let avatarImageView else { return }
        
        NSLayoutConstraint.activate([
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel = UILabel()
        
        guard let nameLabel else { return }
        
        // Basic setup
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        nameLabel.textColor = .ypWhite
        view.addSubview(nameLabel)
        
        // Constraints
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
         
        guard let avatarImageView else { return }
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor)
        ])
    }
    
    private func setupTagLabel() {
        tagLabel = UILabel()
        
        guard let tagLabel else { return }
        
        // Basic setup
        tagLabel.text = "@ekaterina_nov"
        tagLabel.font = UIFont(name: "YSDisplay-Regular", size: 13)
        tagLabel.textColor = .ypGray
        view.addSubview(tagLabel)
        
        // Constraints
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
         
        guard let nameLabel else { return }
        
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            tagLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        
        guard let descriptionLabel else { return }
        
        // Basic setup
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont(name: "YSDisplay-Regular", size: 13)
        descriptionLabel.textColor = .ypWhite
        view.addSubview(descriptionLabel)
        
        // Constraints
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
         
        guard let tagLabel else { return }
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: tagLabel.leadingAnchor)
        ])
    }
    
    private func setupFavoritesLabel() {
        favoritesLabel = UILabel()
        
        guard let favoritesLabel else { return }
        
        // Basic setup
        favoritesLabel.text = "Избранное"
        favoritesLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        favoritesLabel.textColor = .ypWhite
        view.addSubview(favoritesLabel)
        
        // Constraints
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        guard let descriptionLabel else { return }
        
        NSLayoutConstraint.activate([
            favoritesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            favoritesLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor)
        ])
    }
    
    private func setupNoPhotoImageView() {
        guard let noPhotoImage = UIImage(named: ImagesNames.noPhoto.rawValue) else { return }
        
        noPhotoImageView = UIImageView(image: noPhotoImage)
        
        guard let noPhotoImageView else { return }
        
        // Basic setup
        noPhotoImageView.layer.cornerRadius = 35
        view.addSubview(noPhotoImageView)
        
        // Constraints
        noPhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let favoritesLabel else { return }
        
        NSLayoutConstraint.activate([
            noPhotoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPhotoImageView.topAnchor.constraint(equalTo: favoritesLabel.bottomAnchor, constant: 110),
            noPhotoImageView.widthAnchor.constraint(equalToConstant: 115),
            noPhotoImageView.heightAnchor.constraint(equalToConstant: 115)
        ])
    }
    
    private func setupUI() {
        setupAvatarImageView()
        setupLogoutButton()
        setupNameLabel()
        setupTagLabel()
        setupDescriptionLabel()
        setupFavoritesLabel()
        setupNoPhotoImageView()
    }
    
    @objc
    private func didTapLogoutButton() {
        print("did tap logout button")
    }
}
