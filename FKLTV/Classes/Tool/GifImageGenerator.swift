//
//  GifImageGenerator.swift
//  FKLTV
//
//  Created by kun on 2017/5/26.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit
import ImageIO

class GifImageGenerator {
    fileprivate var imageView: UIImageView!
}

extension GifImageGenerator {
    class func temp() {
        // 加载Gif图片，并且转成Data类型
        guard let path = Bundle.main.path(forResource: "", ofType: nil) else { return }
        guard let data = NSData(contentsOfFile: path) else { return }
        
        // 从Data中读取数据：将Data转成CGImageSource对象
        guard let imageSource = CGImageSourceCreateWithData(data, nil) else { return }
        let imageCount = CGImageSourceGetCount(imageSource)
        
        // 遍历所有的图片
        var images = [UIImage]()
        var totalDuration: TimeInterval = 0
        for i in 0..<imageCount {
            // 取出图片
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else { continue }
            let image = UIImage(cgImage: cgImage)
            if i == 0 {
//                imageView.image = image
            }
            images.append(image)
            
            // 取出持续的时间
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) as? NSDictionary else { continue }
            guard let gifDict = properties[kCGImagePropertyGIFDictionary] as? NSDictionary else { continue }
            guard let frameDuration = gifDict[kCGImagePropertyGIFDelayTime] as? NSNumber else { continue }
            totalDuration += frameDuration.doubleValue
        }
        
        // 设置imageView的属性
//        imageView.animationImages = images
//        imageView.animationDuration = totalDuration
//        imageView.animationRepeatCount = 1
        
        // 开始播放动画
//        imageView.startAnimation()
    }
}
