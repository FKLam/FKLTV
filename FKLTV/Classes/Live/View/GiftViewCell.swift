//
//  GiftViewCell.swift
//  FKLTV
//
//  Created by kun on 2017/5/20.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class GiftViewCell: UICollectionViewCell {
    fileprivate lazy var iconImageView: UIImageView = {
        let iconW: CGFloat = 40
        let iconH: CGFloat = 40
        let iconY: CGFloat = 3
        let iconX: CGFloat = (self.bounds.width - iconW) / 2.0
        let iconImageView = UIImageView(frame: CGRect(x: iconX, y: iconY, width: iconW, height: iconH))
        iconImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(iconImageView)
        return iconImageView
    }()
    fileprivate lazy var subjectLabel: UILabel = {
        let subjectY: CGFloat = self.iconImageView.frame.maxY + 5
        let subjectLabel = UILabel(frame: CGRect(x: 0, y: subjectY, width: self.bounds.width, height: 10))
        subjectLabel.font = UIFont.systemFont(ofSize: 10)
        subjectLabel.textAlignment = .center
        subjectLabel.textColor = UIColor.white
        self.contentView.addSubview(subjectLabel)
        return subjectLabel
    }()
    fileprivate lazy var priceLabel: UILabel = {
        let priceY: CGFloat = self.subjectLabel.frame.maxY + 3
        let priceLabel = UILabel(frame: CGRect(x: 0, y: priceY, width: self.bounds.width, height: 10))
        priceLabel.font = UIFont.systemFont(ofSize: 10)
        priceLabel.textAlignment = .center
        priceLabel.textColor = UIColor.white
        self.contentView.addSubview(priceLabel)
        return priceLabel
    }()
    
    var giftModel: GiftModel? {
        didSet {
            iconImageView.setImage(giftModel?.img2, "room_btn_gift")
            subjectLabel.text = giftModel?.subject
            priceLabel.text = "\(giftModel?.coin ?? 0)"
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

extension GiftViewCell {
    fileprivate func setupUI() {
        let selectedView = UIView()
        selectedView.layer.cornerRadius = 5
        selectedView.layer.masksToBounds = true
        selectedView.layer.borderWidth = 1
        selectedView.layer.borderColor = UIColor.orange.cgColor
        selectedView.backgroundColor = UIColor.black
        selectedBackgroundView = selectedView
    }
}
