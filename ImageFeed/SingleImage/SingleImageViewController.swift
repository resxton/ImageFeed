import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var favoritesButton: UIButton!
    @IBOutlet private var shareButton: UIButton!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Public Properties
    
    var image: Photo? {
        didSet {
            guard isViewLoaded, let image, let imageURL = URL(string: image.fullImageURL) else { return }
            
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private Properties
    private var isFavorite = false

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        
        if let image, let imageURL = URL(string: image.fullImageURL) {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - IB Actions
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        let text = "Смотри, какую красоту нашел!"
        guard let sharingImage = imageView.image else { return }
        
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
        
        // TODO: - Добавить логику при нажатии на кнопку лайка
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
    
    private func loadImage(from url: URL) {
        UIBlockingProgressHUD.show()
        imageView.contentMode = .center
        imageView.kf.setImage(with: url, placeholder: UIImage(named: "SingleStub"), options: nil) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let value):
                self?.imageView.frame.size = value.image.size
                self?.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
            }
        }
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
        guard let image = imageView.image else { return }
        centerImageInScrollView(image: image)
    }
}
