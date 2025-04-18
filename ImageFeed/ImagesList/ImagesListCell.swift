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
    weak var delegate: ImagesListCellDelegate?
    
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
        
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = gradientView.bounds
        
        let maskPath = UIBezierPath(roundedRect: gradientView.bounds, byRoundingCorners: [ .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        
        gradientView.layer.mask = maskLayer
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cardImage.kf.cancelDownloadTask()
        cardImage.image = nil
    }
    
    // MARK: - Public methods
    
    public func setIsLiked(_ isLiked: Bool) {
        let likeImageName = isLiked ? "Favorites-Active" : "Favorites-No Active"
        if let likeImage = UIImage(named: likeImageName) {
            likeButton.setImage(likeImage, for: .normal)
        } else {
            print("Ошибка: Изображение \(likeImageName) не найдено")
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Private Methods
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.ypBackground.withAlphaComponent(0).cgColor,
            UIColor.ypBackground.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        gradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
