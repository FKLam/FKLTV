//
//  MainViewViewController.swift
//  FKLTV
//
//  Created by kun on 2017/5/7.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class MainViewViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = HomeViewController()
        addChildViewController(home, title: "首页", image: "live-n", selectedImage: "live-p")
        
        let rank = RankViewController()
        addChildViewController(rank, title: "分类", image: "ranking-n", selectedImage: "ranking-p")
        
        let discover = DiscoverViewController()
        addChildViewController(discover, title: "发现", image: "found-n", selectedImage: "found-p")
        
        let profile = ProfileViewController()
        addChildViewController(profile, title: "我的", image: "mine-n", selectedImage: "mine-p")
        
    }

    fileprivate func addChildViewController(_ childController: UIViewController, title: String, image: String, selectedImage: String) {
        let tabbarItem = UITabBarItem(title: title, image: UIImage(named: image), selectedImage: UIImage(named: selectedImage))
        childController.tabBarItem = tabbarItem
        let nav = FKLNavigationController.init(rootViewController: childController)
        addChildViewController(nav)
    }
}
