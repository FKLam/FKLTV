//
//  FKLContentView.swift
//  FKLTV
//
//  Created by kun on 2017/5/7.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

private let kContentCellID = "kContentCellID"

protocol FKLContentViewDelegate: class {
    func contentView(_ contentView: FKLContentView, targetIndex: Int)
    func contentView(_ contentView: FKLContentView, targetIndex: Int, progress: CGFloat)
}

class FKLContentView: UIView {

    weak var delegate: FKLContentViewDelegate?
    
    fileprivate var childVcs: [UIViewController]
    fileprivate var parentVc: UIViewController
    
    fileprivate var startOffsetX: CGFloat = 0.0
    fileprivate var isForbidScroll: Bool = false
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kContentCellID)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    init(frame: CGRect, childVcs: [UIViewController], parentVc: UIViewController) {
        self.childVcs = childVcs
        self.parentVc = parentVc
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK:- 设置UI界面

extension FKLContentView {
    fileprivate func setupUI() {
        for childVc in childVcs {
            parentVc.addChildViewController(childVc)
        }
        addSubview(collectionView)
    }
}

extension FKLContentView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: kContentCellID, for: indexPath)
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        let childVc = childVcs[indexPath.item]
        childVc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVc.view)
        return cell
    }
}

// MARK:- UICollectionViewDelegate

extension FKLContentView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentEndScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            contentEndScroll()
        }
    }
    
    private func contentEndScroll() {
        // 0.判断是否禁止状态
//        guard !isForbidScroll else { return }
        
        // 1.获取滚动的位置
        let currentIndex = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        // 2.通知titleView做相应的滚动
        delegate?.contentView(self, targetIndex: currentIndex)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidScroll = false
        startOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard startOffsetX != scrollView.contentOffset.x, !isForbidScroll else {
            return
        }
        var targetIndex = 0
        var progress: CGFloat = 0.0
        
        let currentIndex = Int(startOffsetX / scrollView.bounds.width)
        if startOffsetX < scrollView.contentOffset.x { // 左滑动
            targetIndex = currentIndex + 1
            if targetIndex > childVcs.count - 1 {
                targetIndex = childVcs.count - 1
            }
            progress = (scrollView.contentOffset.x - startOffsetX) / scrollView.bounds.width
        } else { // 右滑动
            targetIndex = currentIndex - 1
            if targetIndex < 0 {
                targetIndex = 0
            }
            progress = (startOffsetX - scrollView.contentOffset.x) / scrollView.bounds.width
        }
        
        delegate?.contentView(self, targetIndex: targetIndex, progress: progress)
    }
}

// MARK:- 对外暴露的方法

extension FKLContentView {
    func setCurrentIndex(_ currentIndex: Int) {
        isForbidScroll = true
        let offsetX = CGFloat(currentIndex) * collectionView.frame.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
}
