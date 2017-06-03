//
//  FKLTitleView.swift
//  FKLTV
//
//  Created by kun on 2017/5/7.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

protocol FKLTitleViewDelegate: class {
    func titleView(_ titleView: FKLTitleView, targetIndex: Int)
}

class FKLTitleView: UIView {

    weak var delegate: FKLTitleViewDelegate?
    fileprivate var titles: [String]
    fileprivate var style: FKLTitleStyle
    
    fileprivate lazy var currentIndex: Int = 0
    fileprivate lazy var titleLabels: [UILabel] = [UILabel]()
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        return scrollView
    }()
    fileprivate lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.scrollLineColor
        bottomLine.frame.size.height = self.style.scrollLineHeight
        bottomLine.frame.origin.y = self.bounds.height - self.style.scrollLineHeight
        return bottomLine
    }()
    
    init(frame: CGRect, titles: [String], style: FKLTitleStyle) {
        self.titles = titles
        self.style = style
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- 设置UI界面

extension FKLTitleView {
    fileprivate func setupUI() {
        // 1.将UIScrollView添加到View中
        addSubview(scrollView)
        
        // 2.将titleLabel添加到UIScrooView中
        setupTitleLabels()
        
        // 3.设置titleLabel的frame
        setupTitleLabelsFrame()
        
        // 4.添加滚动条
        if style.isShowScrollLine {
            addSubview(bottomLine)
        }
    }
    
    private func setupTitleLabels() {
        for (i, title) in titles.enumerated() {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: style.fontSize)
            titleLabel.tag = i
            titleLabel.textAlignment = .center
            titleLabel.textColor = i == 0 ? style.selectColor : style.normalColor
            
            scrollView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(titleLableClick(_:)))
            titleLabel.addGestureRecognizer(tap)
            titleLabel.isUserInteractionEnabled = true
        }
    }
    
    private func setupTitleLabelsFrame() {
        let count = titleLabels.count
        let y: CGFloat = 0
        let h: CGFloat = bounds.height
        for (i, label) in titleLabels.enumerated() {
            var w: CGFloat = 0
            var x: CGFloat = 0
            
            if style.isScrollEable { // 可以滚动
                w = (titles[i] as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil).width
                if i == 0 {
                    x = style.itemMargin * 0.5
                    if style.isShowScrollLine {
                        bottomLine.frame.origin.x = x
                        bottomLine.frame.size.width = w
                    }
                } else {
                    let preLabel = titleLabels[i - 1]
                    x = preLabel.frame.maxX + style.itemMargin
                }
            } else { // 不可以滚动
                w = bounds.width / CGFloat(count)
                x = w * CGFloat( i )
                if i == 0 && style.isShowScrollLine {
                    bottomLine.frame.origin.x = 0
                    bottomLine.frame.size.width = w
                }
            }
            label.frame = CGRect(x: x, y: y, width: w, height: h)
        }
        scrollView.contentSize = !style.isScrollEable ? CGSize.zero : CGSize(width: titleLabels.last!.frame.maxX + style.itemMargin * 0.5, height: 0)
    }
}

// MARK:- 监听事件

extension FKLTitleView {
    @objc fileprivate func titleLableClick(_ tap: UITapGestureRecognizer) {
        // 1.取出用户点击的View
        let targetLabel = tap.view as! UILabel
        // 2.调整title
        adjustTitleLabel(targetIndex: targetLabel.tag)
        // 3.调整bottomLine
        if style.isShowScrollLine {
            UIView.animate(withDuration: 0.25) {
                self.bottomLine.frame.origin.x = targetLabel.frame.origin.x
                self.bottomLine.frame.size.width = targetLabel.frame.width
            }
        }
        // 4.通知代理
        delegate?.titleView(self, targetIndex: currentIndex)
    }
    
}

// MARK:- FKLContentViewDelegate

extension FKLTitleView {
    func adjustTitleLabel(targetIndex: Int) {
        
        if targetIndex == currentIndex {
            return
        }
        
        // 1.取出Label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        
        // 2.切换文字的颜色
        targetLabel.textColor = style.selectColor
        sourceLabel.textColor = style.normalColor
        
        // 3.记录下标值
        currentIndex = targetIndex
        
        // 4.调整位置
        if style.isScrollEable {
            var offsetX = targetLabel.center.x - scrollView.bounds.width * 0.5
            if offsetX < 0 {
                offsetX = 0
            }
            if offsetX > (scrollView.contentSize.width - scrollView.bounds.width) {
                offsetX = scrollView.contentSize.width - scrollView.bounds.width
            }
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        }
    }
    
    func setTitleWithProgress(_ contentView: FKLContentView, targetIndex: Int, progress: CGFloat) {
        // 1.取出Label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        
        // 2.颜色渐变
        let detailRGB = UIColor.getRGBDetail(firstColor: style.selectColor, secondColor: style.normalColor)
        let selectedRGB = style.selectColor.getRGB()
        let normalRGB = style.normalColor.getRGB()
        targetLabel.textColor = UIColor(r: normalRGB.0 + detailRGB.0 * progress, g: normalRGB.1 + detailRGB.1 * progress, b: normalRGB.2 + detailRGB.2 * progress)
        sourceLabel.textColor = UIColor(r: selectedRGB.0 - detailRGB.0 * progress, g: selectedRGB.1 - detailRGB.1 * progress, b: selectedRGB.2 - detailRGB.2 * progress)
        
        // 3.bottom
        if style.isShowScrollLine {
            let deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
            let deltaW = targetLabel.frame.width - sourceLabel.frame.width
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + deltaX * progress
            bottomLine.frame.size.width = sourceLabel.frame.width + deltaW * progress
        }
    }
    
    func setTitleWithProgress(_ progress: CGFloat, courceIndex: Int, targetIndex: Int) {
        // 1.取出Label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[courceIndex]
        
        // 2.颜色渐变
        let detailRGB = UIColor.getRGBDetail(firstColor: style.selectColor, secondColor: style.normalColor)
        let selectedRGB = style.selectColor.getRGB()
        let normalRGB = style.normalColor.getRGB()
        targetLabel.textColor = UIColor(r: normalRGB.0 + detailRGB.0 * progress, g: normalRGB.1 + detailRGB.1 * progress, b: normalRGB.2 + detailRGB.2 * progress)
        sourceLabel.textColor = UIColor(r: selectedRGB.0 - detailRGB.0 * progress, g: selectedRGB.1 - detailRGB.1 * progress, b: selectedRGB.2 - detailRGB.2 * progress)
        
        // 3.bottom
        if style.isShowScrollLine {
            let deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
            let deltaW = targetLabel.frame.width - sourceLabel.frame.width
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + deltaX * progress
            bottomLine.frame.size.width = sourceLabel.frame.width + deltaW * progress
        }
    }
}
