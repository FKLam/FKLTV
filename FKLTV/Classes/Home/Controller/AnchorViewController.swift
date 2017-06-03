//
//  AnchorViewController.swift
//  FKLTV
//
//  Created by kun on 2017/5/14.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

private let kEdgeMargin: CGFloat = 8
private let kAnchorCellID = "kAnchorCellID"

class AnchorViewController: UIViewController {
    
    // MARK: 对外属性
    var homeType: HomeType!
    
    // MARK: 定义属性
    fileprivate lazy var homeVM: HomeViewModel = HomeViewModel()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = FKLWaterFallLayout()
        layout.dataSource = self
        layout.minimumLineSpacing = kEdgeMargin
        layout.minimumInteritemSpacing = kEdgeMargin
        layout.sectionInset = UIEdgeInsetsMake(0, kEdgeMargin, kEdgeMargin, kEdgeMargin)
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kAnchorCellID)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadData(index: 0)
    }
}

// MARK:- 设置UI界面内容

extension AnchorViewController {
    fileprivate func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(collectionView)
    }
}

extension AnchorViewController {
    fileprivate func loadData(index: Int) {
        homeVM.loadHomeData(type: homeType, index: index) { 
//            self.collectionView.reloadData()
        }
    }
}

// MARK:- UICollectionViewDataSource

extension AnchorViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return homeVM.anchorModels.count
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAnchorCellID, for: indexPath)
        
        cell.backgroundColor = UIColor.randomColor()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let roomVc = RoomViewController()
        roomVc.anchor = homeVM.anchorModels[indexPath.item]
        navigationController?.pushViewController(roomVc, animated: true)
    }
}

// MARK:- FKLWaterFallLayoutDataSource

extension AnchorViewController: FKLWaterFallLayoutDataSource {
    func numberOfCols(_ waterFallLayout: FKLWaterFallLayout) -> Int {
        return 2
    }
    
    func waterFallLayout(_ waterFallLayout: FKLWaterFallLayout, indexPath: IndexPath) -> CGFloat {
        return indexPath.item % 2 == 0 ? kScreenW * 2 / 3 : kScreenW * 0.5
    }
}
