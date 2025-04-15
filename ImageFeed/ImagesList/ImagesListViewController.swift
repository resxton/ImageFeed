import UIKit
import Kingfisher

public protocol ImagesListViewInput: AnyObject {
    func updateTableView(oldCount: Int, newPhotos: [Photo])
    func reloadCell(at indexPath: IndexPath, isLiked: Bool)
}

final class ImagesListViewController: UIViewController {
    // MARK: - Properties
    var presenter: ImagesListViewOutput!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath else {
                assertionFailure("Invalid segue destination")
                return
            }
            let photo = presenter.photo(at: indexPath)
            viewController.image = photo
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - Private Methods
    private func setupTableView() {
        tableView.rowHeight = 300
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    private func configureCell(
        _ cell: ImagesListCell,
        with photo: Photo,
        at indexPath: IndexPath
    ) {
        cell.delegate = self
        
        guard let url = URL(string: photo.thumbImageURL),
              let stub = UIImage(named: "Stub") else { return }

        cell.cardImage.kf.setImage(with: url, placeholder: stub)
        cell.cardImage.kf.indicatorType = .activity

        cell.label.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? "Дата не указана"

        let likeImageName = photo.isLiked ? "Favorites-Active" : "Favorites-No Active"
        cell.likeButton.accessibilityIdentifier = photo.isLiked ? "like button on" : "like button off"

        let likeImage = UIImage(named: likeImageName)
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

// MARK: - ImagesListViewInput
extension ImagesListViewController: ImagesListViewInput {
    func updateTableView(oldCount: Int, newPhotos: [Photo]) {
        let indexPaths = (oldCount..<oldCount + newPhotos.count).map { IndexPath(row: $0, section: 0) }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadCell(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked)
        UIBlockingProgressHUD.dismiss()
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photosCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imagesListCell = cell as? ImagesListCell else { return UITableViewCell() }

        let photo = presenter.photo(at: indexPath)
        configureCell(imagesListCell, with: photo, at: indexPath)

        return imagesListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath)
        let width = tableView.bounds.width - 32
        return width * (photo.size.height / photo.size.width)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
        presenter.didTapLike(at: indexPath)
    }
}
