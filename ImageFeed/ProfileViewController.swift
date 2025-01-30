//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 30.01.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IB Actions
    @IBAction func exitTapped() {
        // Actions when exit tapped
    }
}
