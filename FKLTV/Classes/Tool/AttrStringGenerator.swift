//
//  AttrStringGenerator.swift
//  FKLTV
//
//  Created by kun on 2017/5/24.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit
import Kingfisher

class AttrStringGenerator {

}

extension AttrStringGenerator {
    class func generateJoinLeaveRoom(_ username: String, _ isJoin: Bool) -> NSMutableAttributedString {
        let roomString = "\(username)" + (isJoin ? " 进入房间" : " 离开房间")
        let roomMAttr = NSMutableAttributedString(string: roomString)
        roomMAttr.addAttributes([NSForegroundColorAttributeName : UIColor.orange], range: NSRange(location: 0, length: username.characters.count))
        return roomMAttr
    }
    
    class func generateTextMessage(_ username: String, _ message: String) -> NSMutableAttributedString {
        let textMessage = "\(username): \(message)"
        let textMessageMAttr = NSMutableAttributedString(string: textMessage)
        textMessageMAttr.addAttributes([NSForegroundColorAttributeName : UIColor.orange], range: NSRange(location: 0, length: username.characters.count))
        // 任意多个字符
        let pattern = "\\[.*?\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return textMessageMAttr
        }
        let results = regex.matches(in: textMessage, options: [], range: NSRange(location: 0, length: textMessage.characters.count))
        for i in (0..<results.count).reversed() {
            let result = results[i]
            let emoticonName = (textMessage as NSString).substring(with: result.range)
            guard let image = UIImage(named: emoticonName) else {
                continue
            }
            let attachment = NSTextAttachment()
            let font = UIFont.systemFont(ofSize: 15)
            attachment.bounds = CGRect(x: 0, y: -3, width: font.lineHeight, height: font.lineHeight)
            attachment.image = image
            let imageAttrStr = NSAttributedString(attachment: attachment)
            textMessageMAttr.replaceCharacters(in: result.range, with: imageAttrStr)
        }
        return textMessageMAttr
    }
    
    class func generateGiftMessage(_ username: String, _ giftName: String, _ giftURL: String) -> NSMutableAttributedString {
        let sendGiftMsg = "\(username) 赠送 \(giftName)"
        let sendGiftMAttrMsg = NSMutableAttributedString(string: sendGiftMsg)
        sendGiftMAttrMsg.addAttributes([NSForegroundColorAttributeName : UIColor.orange], range: NSRange(location: 0, length: username.characters.count))
        let range = (sendGiftMsg as NSString).range(of: giftName)
        sendGiftMAttrMsg.addAttributes([NSForegroundColorAttributeName: UIColor.red], range: range)
        guard let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: giftURL) else {
            return sendGiftMAttrMsg
        }
        let attacment = NSTextAttachment()
        let font = UIFont.systemFont(ofSize: 15)
        attacment.image = image
        attacment.bounds = CGRect(x: 0, y: -3, width: font.lineHeight, height: font.lineHeight)
        let imageAttStr = NSAttributedString(attachment: attacment);
        sendGiftMAttrMsg.append(imageAttStr)
        return sendGiftMAttrMsg
    }
}
