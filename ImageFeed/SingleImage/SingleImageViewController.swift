//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 31.01.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var favoritesButton: UIButton!
    @IBOutlet private var shareButton: UIButton!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Public Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }

            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Private Properties
    private var isFavorite = false

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - IB Actions
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        let text = "Смотри, какую красоту нашел!"
        guard let sharingImage = image else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [text, sharingImage], applicationActivities: nil)
        
        present(activityViewController, animated: true)
    }
    
    @IBAction func didTapFavoritesButton(_ sender: Any) {
        if isFavorite {
            favoritesButton.setImage(UIImage(named: "Favorites-Big No Active"), for: .normal)
        } else {
            favoritesButton.setImage(UIImage(named: "Favorites-Big Active"), for: .normal)
        }
        
        isFavorite.toggle()
        
        print("tapped favorites button")
    }
    
    // MARK: - Private Methods
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        imageView.frame.size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        imageView.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
    }
    
    private func centerImageInScrollView(image: UIImage) {
        let boundsSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let dx = max(0, floor((boundsSize.width - contentSize.width) / 2))
        let dy = max(0, floor((boundsSize.height - contentSize.height) / 2))

        scrollView.contentInset = UIEdgeInsets(top: dy, left: dx, bottom: dy, right: dx)
        scrollView.layoutIfNeeded()
    }
}

// MARK: - ScrollView Delegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let image else { return }
        centerImageInScrollView(image: image)
    }
}
