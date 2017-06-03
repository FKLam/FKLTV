//
//  FKLWaterFallLayout.swift
//  FKLTV
//
//  Created by kun on 2017/5/14.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

protocol FKLWaterFallLayoutDataSource: class {
    func numberOfCols(_ waterFallLayout: FKLWaterFallLayout) -> Int
    func waterFallLayout(_ waterFallLayout: FKLWaterFallLayout, indexPath: IndexPath) -> CGFloat
}

class FKLWaterFallLayout: UICollectionViewFlowLayout {
    
    weak var dataSource: FKLWaterFallLayoutDataSource?
    
    fileprivate lazy var cols: Int = {
        return self.dataSource?.numberOfCols(self) ?? 2
    }()
    fileprivate lazy var cellAttrs: [UICollectionViewLayoutAttributes] = {
        return [UICollectionViewLayoutAttributes]()
    }()
    fileprivate lazy var totalHeights: [CGFloat] = {
        Array(repeating: self.sectionInset.top, count: self.cols)
    }()
    fileprivate var maxH : CGFloat = 0
    fileprivate var startIndex = 0
}

// MARK:- 准备布局

extension FKLWaterFallLayout {
    override func prepare() {
        super.prepare()
        // Cell -> UICollectionViewLayoutAttributes
        // 1.获取cell的个数
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        // 2.给每个cell创建一个UICollectionViewLayoutAttributes
        let cellW: CGFloat = (collectionView!.bounds.width - sectionInset.left - sectionInset.right - CGFloat(cols - 1) * minimumInteritemSpacing) / CGFloat(cols)
        for i in startIndex..<itemCount {
            // 2.1 根据i创建indexPath
            let indexPath = IndexPath(item: i, section: 0)
            // 2.2 根据indexPath创建对应的UICollectionViewLayoutAttributes
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            // 2.3 设置attr中的frame
            let minH = totalHeights.min()!
            let minIndex = totalHeights.index(of: minH)!
            guard let cellH: CGFloat = dataSource?.waterFallLayout(self, indexPath: IndexPath(item: i, section: 0)) else {
                fatalError("请实现对应的数据源方法，并且返回cell高度")
            }
            let cellX: CGFloat = sectionInset.left + (minimumInteritemSpacing + cellW) * CGFloat(minIndex)
            let cellY: CGFloat = minH
            attr.frame = CGRect(x: cellX, y: cellY, width: cellW, height: cellH)
            // 2.4 保存attr
            cellAttrs.append(attr)
            // 2.5 添加当前的高度
            totalHeights[minIndex] = minH + minimumLineSpacing + cellH
        }
        maxH = totalHeights.max()!
        startIndex = itemCount
    }
}

// MARK:- 返回准备好所有布局

extension FKLWaterFallLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cellAttrs
    }
}

// MARK:- 设置contentSize

extension FKLWaterFallLayout {
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 0, height: totalHeights.max()! + sectionInset.bottom)
    }
}
