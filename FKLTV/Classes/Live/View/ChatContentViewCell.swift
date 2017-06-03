//
//  ChatContentViewCell.swift
//  FKLTV
//
//  Created by kun on 2017/5/23.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class ChatContentViewCell: UITableViewCell {
    
    lazy var contentLabel: UILabel = {
        let x: CGFloat = 10
        let y: CGFloat = 0
        let w: CGFloat = self.contentView.bounds.width - 20
        let h: CGFloat = self.contentView.bounds.height;
        let contentLabel = UILabel(frame: CGRect(x: x, y: y, width: w, height: h))
        contentLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentLabel.textAlignment = .left
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textColor = UIColor.white
        contentLabel.numberOfLines = 0
        return contentLabel
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatContentViewCell {
    fileprivate func setupUI() {
        contentView.addSubview(contentLabel)
    }
}
