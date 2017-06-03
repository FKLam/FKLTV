//
//  FKLPageCollectionView.swift
//  FKLTV
//
//  Created by kun on 2017/5/16.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

protocol FKLPageCollectionViewDataSource: class {
    func numberOfSections(in pageCollectionView: FKLPageCollectionView) -> Int
    func pageCollectionView(_ collectionView: FKLPageCollectionView, numberOfItemsInSection section: Int) -> Int
    func pageCollectionView(_ pageCollectionView: FKLPageCollectionView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

protocol FKLPageCollectionViewDelegate: class {
    func pageCollectionView(_ collectionView: FKLPageCollectionView, didSelectItemAt indexPath: IndexPath)
}

class FKLPageCollectionView: UIView {
    
    weak var dataSource: FKLPageCollectionViewDataSource?
    weak var delegate: FKLPageCollectionViewDelegate?
    
    fileprivate var titles: [String]
    fileprivate var isTitleInTop: Bool
    fileprivate var layout: FKLPageCollectionViewLayout
    fileprivate var style: FKLTitleStyle
    fileprivate var collectionView: UICollectionView!
    fileprivate var pageControl: UIPageControl!
    fileprivate var sourceIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    fileprivate var titleView: FKLTitleView!

    init(frame: CGRect, titles: [String], style: FKLTitleStyle, isTitleInTop: Bool, layout: FKLPageCollectionViewLayout) {
        self.titles = titles
        self.isTitleInTop = isTitleInTop
        self.layout = layout
        self.style = style
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension FKLPageCollectionView {
    fileprivate func setupUI() {
        // 1.创建titleView
        let titleY = isTitleInTop ? 0 : bounds.height - style.titleHeight
        let titleFrame = CGRect(x: 0, y: titleY, width: bounds.width, height: style.titleHeight)
        titleView = FKLTitleView(frame: titleFrame, titles: titles, style: style)
        titleView.delegate = self
        addSubview(titleView)
        
        // 2.创建UIPageControl
        let pageControlHeight: CGFloat = 20
        let pageControlY = isTitleInTop ? (bounds.height - pageControlHeight) : (bounds.height - pageControlHeight - style.titleHeight)
        let pageControlFrame = CGRect(x: 0, y: pageControlY, width: bounds.width, height: pageControlHeight)
        pageControl = UIPageControl(frame: pageControlFrame)
        pageControl.numberOfPages = 4
        pageControl.isEnabled = false
        addSubview(pageControl)
        
        // 3.创建UICollectionView
        let collectionViewY = isTitleInTop ? style.titleHeight : 0
        let collectionViewFrame = CGRect(x: 0, y: collectionViewY, width: bounds.width, height: bounds.height - style.titleHeight - pageControlHeight)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        pageControl.backgroundColor = collectionView.backgroundColor
    }
}

// MARK:- 对外暴露的方法

extension FKLPageCollectionView {
    func register(cell: AnyClass?, identifier: String) {
        collectionView.register(cell, forCellWithReuseIdentifier: identifier)
    }
    
    func register(nib: UINib, identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK:- UICollectionViewDataSource

extension FKLPageCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = dataSource?.pageCollectionView(self, numberOfItemsInSection: section) ?? 0
        
        if section == 0 {
            pageControl.numberOfPages = (itemCount - 1) / (layout.cols * layout.rows) + 1
        }
        
        return itemCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource!.pageCollectionView(self, collectionView: collectionView, cellForItemAt: indexPath)
    }
}

// MARK:- UICollectionViewDelegate

extension FKLPageCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pageCollectionView(self, didSelectItemAt: indexPath)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewEndScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewEndScroll()
    }
    
    fileprivate func scrollViewEndScroll() {
        let point = CGPoint(x: layout.sectionInset.left + collectionView.contentOffset.x + 1, y: layout.sectionInset.top + 1)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
        if sourceIndexPath.section != indexPath.section {
            let itemCount = dataSource?.pageCollectionView(self, numberOfItemsInSection: indexPath.section) ?? 0
            pageControl.numberOfPages = (itemCount - 1) / (layout.rows * layout.cols) + 1
            titleView.setTitleWithProgress(1.0, courceIndex: sourceIndexPath.section, targetIndex: indexPath.section)
            sourceIndexPath = indexPath
        }
        pageControl.currentPage = indexPath.item / (layout.cols * layout.rows)
    }
}

// MARK:- FKLTitleViewdelegate

extension FKLPageCollectionView: FKLTitleViewDelegate {
    func titleView(_ titleView: FKLTitleView, targetIndex: Int) {
        let indexPath = IndexPath(item: 0, section: targetIndex)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        collectionView.contentOffset.x -= layout.sectionInset.left
        
        scrollViewEndScroll()
    }
}
