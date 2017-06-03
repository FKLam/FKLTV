//
//  FKLPageView.swift
//  FKLTV
//
//  Created by kun on 2017/5/7.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class FKLPageView: UIView {

    fileprivate var titles: [String]
    fileprivate var childVcs: [UIViewController]
    fileprivate var parentVc: UIViewController
    fileprivate var style: FKLTitleStyle
    
    fileprivate var titleView: FKLTitleView!
    fileprivate var contentView : FKLContentView!
    
    init(frame: CGRect, titles: [String], childVcs: [UIViewController], parentVc: UIViewController, style: FKLTitleStyle) {
        assert(titles.count == childVcs.count, "标题&控制器个数不同，请检查！")
        self.titles = titles
        self.childVcs = childVcs
        self.parentVc = parentVc
        self.style = style
        parentVc.automaticallyAdjustsScrollViewInsets = false
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK:- 设置UI界面

extension FKLPageView {
    fileprivate func setupUI() {
        setupTitleView()
        setupContentView()
    }
    
    private func setupTitleView() {
        let titleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: style.titleHeight)
        titleView = FKLTitleView(frame: titleFrame, titles: titles, style: style)
        addSubview(titleView)
        titleView.delegate = self
    }
    
    private func setupContentView() {
        let contentFrame = CGRect(x: 0, y: style.titleHeight, width: bounds.width, height: bounds.height - style.titleHeight)
        contentView = FKLContentView(frame: contentFrame, childVcs: childVcs, parentVc: parentVc)
        addSubview(contentView)
        contentView.delegate = self
    }
}

// MARK:- 设置HYContentView的代理
extension FKLPageView : FKLContentViewDelegate {
    
    func contentView(_ contentView: FKLContentView, targetIndex: Int) {
        titleView.adjustTitleLabel(targetIndex: targetIndex)
    }
    
    func contentView(_ contentView: FKLContentView, targetIndex: Int, progress: CGFloat) {
        titleView.setTitleWithProgress(contentView, targetIndex: targetIndex, progress: progress)
    }
}


// MARK:- 设置HYTitleView的代理
extension FKLPageView : FKLTitleViewDelegate {
    func titleView(_ titleView: FKLTitleView, targetIndex: Int) {
        contentView.setCurrentIndex(targetIndex)
    }
}
