//
//  EmoticonViewCell.swift
//  FKLTV
//
//  Created by kun on 2017/5/20.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class EmoticonViewCell: UICollectionViewCell {
    lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView(frame: self.bounds)
        iconImageView.contentMode = .center
        self.addSubview(iconImageView)
        return iconImageView
    }()
    var emoticon: Emoticon? {
        didSet {
            iconImageView.image = UIImage(named: emoticon!.emoticonName)
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

extension EmoticonViewCell {
    fileprivate func setupUI() {
        
    }
}
