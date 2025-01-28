//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 26.01.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - Private Properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
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
    }
    
    // MARK: - Public Methods
    func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // Получаем имя изображения для картинки
        let imageName = String(indexPath.row)
        guard let cardImage = UIImage(named: imageName) else {
            print("Ошибка: Изображение \(imageName) не найдено")
            return
        }
        
        cell.cardImage.image = cardImage // Устанавливаем изображение в UIImageView
        
        // Устанавливаем текст с текущей датой
        cell.label.text = dateFormatter.string(from: Date())
        
        // Устанавливаем иконку лайка
        let likeImageName = indexPath.row % 2 == 0 ? "Active" : "No Active"
        if let likeImage = UIImage(named: likeImageName) {
            cell.likeButton.setImage(likeImage, for: .normal)
        } else {
            print("Ошибка: Изображение \(likeImageName) не найдено")
        }
    }

    
    // MARK: - Private Methods
    private func setupTableView() {
        tableView.rowHeight = 300
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(for: imagesListCell, with: indexPath)
        
        return imagesListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Получаем размер изображения
        guard let rawImageSize = UIImage(named: photosName[indexPath.row])?.size else {
            return 300
        }
        
        let imageViewWidth = self.tableView.bounds.size.width - 32

        let resultHeight = imageViewWidth * (rawImageSize.height / rawImageSize.width)
        
        return resultHeight
    }
}


