import UIKit
import Kingfisher

public protocol ProfileViewInput: AnyObject {
    func updateProfileDetails(name: String, login: String, bio: String)
    func updateAvatar(with url: URL)
}

final class ProfileViewController: UIViewController, ProfileViewInput {
    // MARK: - Private Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private var presenter: ProfileViewOutput!

    // MARK: - UI Elements
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Avatar"))
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Logout"), for: .normal)
        button.tintColor = .ypRed
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Bold", size: 23) ?? .boldSystemFont(ofSize: 23)
        label.textColor = .ypWhite
        return label
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Regular", size: 13) ?? .systemFont(ofSize: 13)
        label.textColor = .ypGray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Regular", size: 13) ?? .systemFont(ofSize: 13)
        label.textColor = .ypWhite
        return label
    }()
    
    private let favoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "Избранное"
        label.font = UIFont(name: "YSDisplay-Bold", size: 23) ?? .boldSystemFont(ofSize: 23)
        label.textColor = .ypWhite
        return label
    }()
    
    private let noPhotoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Favorites-No Photo"))
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupUI()
        presenter.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            presenter.didReceiveAvatarUpdate()
        }
    }

    // MARK: - Public Methods
    func inject(presenter: ProfileViewOutput) {
        self.presenter = presenter
    }

    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        tagLabel.text = login
        descriptionLabel.text = bio
    }
    
    func updateAvatar(with url: URL) {
        avatarImageView.kf.setImage(with: url)
    }

    // MARK: - Setup
    private func setupVC() {
        view.backgroundColor = .ypBlack
    }

    private func setupUI() {
        [avatarImageView, logoutButton, nameLabel, tagLabel, descriptionLabel, favoritesLabel, noPhotoImageView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),

            tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            tagLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: tagLabel.leadingAnchor),

            favoritesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            favoritesLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),

            noPhotoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPhotoImageView.topAnchor.constraint(equalTo: favoritesLabel.bottomAnchor, constant: 110),
            noPhotoImageView.widthAnchor.constraint(equalToConstant: 115),
            noPhotoImageView.heightAnchor.constraint(equalToConstant: 115)
        ])
    }

    // MARK: - Actions
    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        alert.addAction(.init(title: "Нет", style: .cancel))
        alert.addAction(.init(title: "Да", style: .default, handler: { [weak self] _ in
            self?.presenter.didTapLogout()
        }))
        present(alert, animated: true)
    }
}
