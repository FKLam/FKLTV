//
//  HomeViewController.swift
//  FKLTV
//
//  Created by kun on 2017/5/7.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
    }

}

// MARK:- 设置UI界面

extension HomeViewController {
    fileprivate func setupUI() {
        setupNavigationBar()
        
        setupContentView()
    }
    
    private func setupNavigationBar() {
        // 1.左侧logoItem
        let logoImage = UIImage(named: "home-logo")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: logoImage, style: .plain, target: nil, action: nil)
        
        // 2.设置右侧收藏的item
        let collectImage = UIImage(named: "search_btn_follow")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: collectImage, style: .plain, target: self, action: #selector(followItemClick))
        
        // 3.搜索框
        let searchFrame = CGRect(x: 0, y: 0, width: 200, height: 32)
        let searchBar = UISearchBar(frame: searchFrame)
        searchBar.placeholder = "主播昵称／房间号／链接"
        navigationItem.titleView = searchBar
        searchBar.searchBarStyle = .minimal
        
        let searchFiled = searchBar.value(forKey: "_searchField") as? UITextField
        searchFiled?.textColor = UIColor.white
    }
    private func setupContentView() {
        let homeTypes = loadTypesData()
        let style = FKLTitleStyle()
        style.isScrollEable = true
        let pageFrame = CGRect(x: 0, y: kNavigationBarH + kStatusBarH, width: kScreenW, height: kScreenH - kNavigationBarH - kStatusBarH - 44)
        let titles = homeTypes.map({$0.title})
        var childVcs = [AnchorViewController]()
        for type in homeTypes {
            let anchorVc = AnchorViewController()
            anchorVc.homeType = type
            childVcs.append(anchorVc)
        }
        let pageView = FKLPageView(frame: pageFrame, titles: titles, childVcs: childVcs, parentVc: self, style: style)
        view.addSubview(pageView)
    }
    
    fileprivate func loadTypesData() -> [HomeType] {
        let path = Bundle.main.path(forResource: "types.plist", ofType: nil)!
        let dataArray = NSArray(contentsOfFile: path) as! [[String: Any]]
        var tempArray = [HomeType]()
        for dict in dataArray {
            tempArray.append(HomeType(dict: dict))
        }
        return tempArray
    }
}

// MARK:- 事件监听函数

extension HomeViewController {
    @objc fileprivate func followItemClick() {
        
    }
}
