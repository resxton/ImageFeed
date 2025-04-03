//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 26.01.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - Private Properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                print("🔄 Данные обновлены, вызываем updateTableViewAnimated()")
                self.updateTableViewAnimated()
            }
    }

    
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    
    // MARK: - Public Methods
    func configureCell(
        for cell: ImagesListCell,
        with indexPath: IndexPath,
        from photo: Photo
    ) {
        guard let url = URL(string: photo.thumbImageURL) else {
            print("Ошибка: URL некорректен")
            return
        }
        
        guard let stub = UIImage(named: "Stub") else {
            print("Ошибка: заглушка не найдена")
            return
        }

        cell.cardImage.kf.setImage(with: url, placeholder: stub, options: nil) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
            }
        }


        cell.cardImage.kf.indicatorType = .activity
        
        guard let createdAt = photo.createdAt else {
            print("Ошибка: Дата некорректна")
            return
        }
        
        cell.label.text = dateFormatter.string(from: createdAt)
        
        let likeImageName = photo.isLiked ? "Favorites-Active" : "Favorites-No Active"
        
        if let likeImage = UIImage(named: likeImageName) {
            cell.likeButton.setImage(likeImage, for: .normal)
        } else {
            print("Ошибка: Изображение \(likeImageName) не найдено")
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage { _ in }
        }
    }

    // MARK: - Private Methods
    private func setupTableView() {
        tableView.rowHeight = 300
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                tableView.insertRows(
                    at: (oldCount..<newCount)
                    .map({ IndexPath(row: $0, section: 0) }),
                    with: .automatic)
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return photos.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(for: imagesListCell, with: indexPath, from: photos[indexPath.row])
        
        return imagesListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let rawImageSize = photos[indexPath.row].size
        
        let imageViewWidth = self.tableView.bounds.size.width - 32
        let resultHeight = imageViewWidth * (rawImageSize.height / rawImageSize.width)
        
        return resultHeight
    }
}


