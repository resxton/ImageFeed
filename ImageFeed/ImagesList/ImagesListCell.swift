//
//  ImagesListCellTableViewCell.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 28.01.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IB Outlets
    
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var label: UILabel!
    @IBOutlet var gradientView: UIView!
    
    // MARK: - Private Properties
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeButton.layer.shadowOpacity = 0.1
        likeButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        likeButton.layer.shadowColor = UIColor(named: "YP Black")?.cgColor
        likeButton.layer.shadowRadius = 4
        
        likeButton.setTitle("", for: .normal)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем frame градиента при изменении размеров
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - Private Methods
    private func setupGradient() {
        // Устанавливаем начальные параметры градиента
        guard let ypBlack = UIColor(named: "YP Black") else { return }
        
        gradientLayer.colors = [
            ypBlack.withAlphaComponent(0).cgColor,
            ypBlack.withAlphaComponent(0.2).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Удаляем предыдущие градиентные слои (если есть)
        gradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        // Добавляем градиентный слой
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
