//
//  UIColor+Extension.swift
//  FKLTV
//
//  Created by kun on 2017/5/7.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

extension UIColor {
    // 在extension中给系统的类扩充构造函数，只能扩充便利构造函数
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        // 0xFF0000
        // 1.判读字符串的长度是否符合
        guard hex.characters.count >= 6 else {
            return nil
        }
        
        // 2.将字符串转成大写
        var tempHex = hex.uppercased()
        
        // 3.判断开头：0x ／ # ／ ##
        if tempHex.hasPrefix("0x") || tempHex.hasPrefix("##") {
            tempHex = (tempHex as NSString).substring(from: 2)
        } else if tempHex.hasPrefix("#") {
            tempHex = (tempHex as NSString).substring(from: 1)
        }
        
        // 4.分别出去RGB
        var range = NSRange(location: 0, length: 2)
        let rHex = (tempHex as NSString).substring(with: range)
        range.location = 2
        let gHex = (tempHex as NSString).substring(with: range)
        range.location = 4
        let bHex = (tempHex as NSString).substring(with: range)
        
        // 5.将十六进制转成数字 emoji表情
        var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        
        self.init(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b), alpha: alpha)
    }
    
    class func randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
    
    class func getRGBDetail(firstColor: UIColor, secondColor: UIColor) -> (CGFloat, CGFloat, CGFloat) {
        let firstCpms = firstColor.getRGB()
        let secondCpms = secondColor.getRGB()
        return (firstCpms.0 - secondCpms.0, firstCpms.1 - secondCpms.1, firstCpms.2 - secondCpms.2)
    }
    
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        guard let cmps = cgColor.components else {
            fatalError("保证颜色是RGB方式传入")
        }
        return (cmps[0] * 255, cmps[1] * 255, cmps[2] * 255)
    }
}
