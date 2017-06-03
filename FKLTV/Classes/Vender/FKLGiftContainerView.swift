//
//  FKLGiftContainerView.swift
//  FKLTV
//
//  Created by kun on 2017/5/25.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

private let kChannelCount = 2
private let kChannelViewH: CGFloat = 40
private let kChannelMargin: CGFloat = 10

class FKLGiftContainerView: UIView {

    // MARK:- 内部属性
    fileprivate lazy var channelViews: [FKLGiftChannelView] = [FKLGiftChannelView]()
    fileprivate lazy var giftCaches: [FKLGiftModel] = [FKLGiftModel]()
    
    
    // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK:- 设置UI界面

extension FKLGiftContainerView {
    fileprivate func setupUI() {
        let w: CGFloat = frame.width
        let h: CGFloat = kChannelViewH
        let x: CGFloat = 0
        for i in 0..<kChannelCount {
            let y: CGFloat = (h * kChannelMargin) * CGFloat(i)
            let channelView = FKLGiftChannelView(frame: CGRect(x: x, y: y, width: w, height: h))
            channelView.alpha = 0.0
            addSubview(channelView)
            channelViews.append(channelView)
            channelView.complectionCallback = { channelView in
                guard self.giftCaches.count != 0 else {
                    return
                }
                
                let firstGiftModel = self.giftCaches.first!
                self.giftCaches.removeFirst()
                
                channelView.giftModel = firstGiftModel
                
                for i in (0..<self.giftCaches.count).reversed() {
                    let giftModel = self.giftCaches[i]
                    if giftModel.isEqual(firstGiftModel) {
                        channelView.addOnceToCache()
                        self.giftCaches.remove(at: i)
                    }
                }
            }
        }
    }
}

extension FKLGiftContainerView {
    func showGiftModel(_ giftModel: FKLGiftModel) {
        if let channelView = checkChannelView(giftModel) {
            channelView.addOnceToCache()
            return
        }
        
        if let channelView = checkIdleChannelView() {
            channelView.giftModel = giftModel
            return
        }
        
        giftCaches.append(giftModel)
    }
    
    private func checkChannelView(_ giftMoeld: FKLGiftModel) -> FKLGiftChannelView? {
        for channelView in channelViews {
            if giftMoeld.isEqual(channelView.giftModel) && channelView.state != .endAnimating {
                return channelView
            }
        }
        return nil
    }
    
    private func checkIdleChannelView() -> FKLGiftChannelView? {
        for channelView in channelViews {
            if channelView.state == .idle {
                return channelView
            }
        }
        return nil
    }
}
