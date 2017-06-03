//
//  FKLGiftChannelView.swift
//  FKLTV
//
//  Created by kun on 2017/5/25.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

enum FKLGiftChannelViewState {
    case idle
    case animating
    case willEnd
    case endAnimating
}

class FKLGiftChannelView: UIView {

    fileprivate var bgView: UIView!
    fileprivate var iconImageView: UIImageView!
    fileprivate var senderLabel: UILabel!
    fileprivate var giftDescLabel: UILabel!
    fileprivate var giftImageView: UIImageView!
    fileprivate var digitLabel: FKLGiftDigitLabel!
    
    fileprivate var cacheNumber: Int = 0
    fileprivate var currentNumber: Int = 0
    var state: FKLGiftChannelViewState = .idle
    
    var complectionCallback: ((FKLGiftChannelView) -> Void)?
    
    var giftModel: FKLGiftModel? {
        didSet {
            guard let giftModel = giftModel else {
                return
            }
            
            iconImageView.image = UIImage(named: giftModel.senderURL)
            senderLabel.text = giftModel.senderName
            giftDescLabel.text = "送出礼物：[\(giftModel.giftName)]"
            giftImageView.image = UIImage(named: giftModel.giftURL)
            
            state = .animating
            performAnimation()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- 设置UI界面

extension FKLGiftChannelView {
    fileprivate func setupUI() {
        bgView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width * 0.5, height: bounds.height))
        bgView.backgroundColor = UIColor(r: 0, g: 0, b: 0, alpha: 0.5)
        addSubview(bgView)
        
        let iconX: CGFloat = 0
        let iconY: CGFloat = 0
        let iconH: CGFloat = bounds.height
        let iconW: CGFloat = iconH
        iconImageView = UIImageView(frame: CGRect(x: iconX, y: iconY, width: iconW, height: iconH))
        bgView.addSubview(iconImageView)
        
        let senderX: CGFloat = iconW + 10
        let senderY: CGFloat = 5
        let senderW: CGFloat = bounds.width - iconW * 2
        let senderH: CGFloat = 15
        senderLabel = UILabel(frame: CGRect(x: senderX, y: senderY, width: senderW, height: senderH))
        senderLabel.font = UIFont.systemFont(ofSize: 11)
        senderLabel.textColor = UIColor.white
        senderLabel.textAlignment = .left
        bgView.addSubview(senderLabel)
        
        let giftLabelX: CGFloat = senderX
        let giftLabelH: CGFloat = 16
        let giftLabelW: CGFloat = senderW
        let giftLabelY: CGFloat = iconH - 2 - giftLabelH
        giftDescLabel = UILabel(frame: CGRect(x: giftLabelX, y: giftLabelY, width: giftLabelW, height: giftLabelH))
        giftDescLabel.textAlignment = .left
        giftDescLabel.textColor = UIColor.orange
        giftDescLabel.font = UIFont.systemFont(ofSize: 12)
        bgView.addSubview(giftDescLabel)
        
        let giftIconW: CGFloat = iconW
        let giftIconH: CGFloat = giftIconW
        let giftIconY: CGFloat = 0
        let giftIconX: CGFloat = bounds.width - giftIconW
        giftImageView = UIImageView(frame: CGRect(x: giftIconX, y: giftIconY, width: giftIconW, height: giftIconH))
        bgView.addSubview(giftImageView)
        
        let digitW: CGFloat = bounds.width * 0.5 - 15
        let digitH: CGFloat = 24
        let digitY: CGFloat = 0
        let digitX: CGFloat = bounds.width - digitW
        digitLabel = FKLGiftDigitLabel(frame: CGRect(x: digitX, y: digitY, width: digitW, height: digitH))
        digitLabel.font = UIFont.systemFont(ofSize: 20)
        digitLabel.textAlignment = .left
        addSubview(digitLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.layer.cornerRadius = frame.height * 0.5
        iconImageView.layer.cornerRadius = frame.height * 0.5
        bgView.layer.masksToBounds = true
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = UIColor.green.cgColor
    }
}

// MARK:- 对外提供的函数

extension FKLGiftChannelView {
    func addOnceToCache() {
        if state == .willEnd {
            performDigitAnimation()
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        } else {
            cacheNumber += 1
        }
    }
}

// MARK:- 执行动画代码

extension FKLGiftChannelView {
    fileprivate func performAnimation() {
        digitLabel.alpha = 1.0
        digitLabel.text = "x1"
        UIView.animate(withDuration: 0.25, animations: { 
            self.alpha = 1.0
            self.frame.origin.x = 0
        }) { (isFinish) in
            self.performDigitAnimation()
        }
    }
    
    fileprivate func performDigitAnimation() {
        currentNumber += 1
        digitLabel.text = "x\(currentNumber)"
        digitLabel.showDigitAnimation {
            if self.cacheNumber > 0 {
                self.cacheNumber -= 1
                self.performDigitAnimation()
            } else {
                self.state = .willEnd
                self.perform(#selector(self.performEndAnimation), with: nil, afterDelay: 3.0)
            }
        }
    }
    
    @objc fileprivate func performEndAnimation() {
        state = .endAnimating
        UIView.animate(withDuration: 0.25, animations: { 
            self.frame.origin.x = kScreenW
            self.alpha = 0.0
        }) { (isFinish) in
            self.currentNumber = 0
            self.cacheNumber = 0
            self.giftModel = nil
            self.frame.origin.x = -self.frame.origin.x
            self.state = .idle
            self.digitLabel.alpha = 0.0
            
            if let complectionCallback = self.complectionCallback {
                complectionCallback(self)
            }
        }
    }
}
