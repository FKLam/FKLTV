//
//  FKLGiftModel.swift
//  FKLTV
//
//  Created by kun on 2017/5/25.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class FKLGiftModel: NSObject {
    var senderName: String = ""
    var senderURL: String = ""
    var giftName: String = ""
    var giftURL: String = ""
    
    init(senderName: String, senderURL: String, giftName: String, giftURL: String) {
        self.senderName = senderName
        self.senderURL = senderURL
        self.giftName = giftName
        self.giftURL = giftURL
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FKLGiftModel else {
            return false
        }
        
        guard object.giftName == giftName && object.senderName == senderName else {
            return false
        }
        
        return true
    }
}
