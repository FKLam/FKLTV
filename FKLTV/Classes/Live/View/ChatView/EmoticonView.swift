//
//  EmoticonView.swift
//  FKLTV
//
//  Created by kun on 2017/5/20.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

private let kEmoticonCellID = "kEmoticonCellID"

class EmoticonView: UIView {
    
    var emoticonClickCallback: ((Emoticon) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK:- 设置UI界面

extension EmoticonView {
    fileprivate func setupUI() {
        let style = FKLTitleStyle()
        style.isShowScrollLine = true
        let layout = FKLPageCollectionViewLayout()
        layout.cols = 7
        layout.rows = 3
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let pageCollectionView = FKLPageCollectionView(frame: bounds, titles: ["普通", "粉丝专属"], style: style, isTitleInTop: false, layout: layout)
        pageCollectionView.register(cell: EmoticonViewCell.self, identifier: kEmoticonCellID)
        addSubview(pageCollectionView)
        pageCollectionView.dataSource = self
        pageCollectionView.delegate = self
    }
}

// MARK:- FKLPageCollectionViewDataSource

extension EmoticonView: FKLPageCollectionViewDataSource {
    func numberOfSections(in pageCollectionView: FKLPageCollectionView) -> Int {
        return EmoticonViewModel.shareInstance.packages.count
    }
    
    func pageCollectionView(_ collectionView: FKLPageCollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmoticonViewModel.shareInstance.packages[section].emoticons.count
    }
    
    func pageCollectionView(_ pageCollectionView: FKLPageCollectionView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kEmoticonCellID, for: indexPath) as! EmoticonViewCell
        let emoticon = EmoticonViewModel.shareInstance.packages[indexPath.section].emoticons[indexPath.item]
        cell.emoticon = emoticon
        return cell
    }
}

// MARK:- FKLPageCollectionViewDelegate

extension EmoticonView: FKLPageCollectionViewDelegate {
    func pageCollectionView(_ collectionView: FKLPageCollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoticon = EmoticonViewModel.shareInstance.packages[indexPath.section].emoticons[indexPath.item]
        if let emoticonClickCallback = emoticonClickCallback {
            emoticonClickCallback(emoticon)
        }
    }
}
