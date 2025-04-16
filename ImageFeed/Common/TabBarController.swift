//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 14.03.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            assertionFailure("ImagesListViewController not found")
            return
        }
        
        let service = ImagesListService.shared
        let imagesListPresenter = ImagesListPresenter(view: imagesListViewController, service: service)
        imagesListViewController.presenter = imagesListPresenter
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter(view: profileViewController)
        profileViewController.inject(presenter: profilePresenter)

        profileViewController.tabBarItem = UITabBarItem(title: "",
                                                        image: UIImage(named: "tab_profile_active"),
                                                        selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
