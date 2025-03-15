//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 14.03.2025.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "",
                                                        image: UIImage(named: "tab_profile_active"),
                                                        selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
