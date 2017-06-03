//
//  EmoticonPackage.swift
//  FKLTV
//
//  Created by kun on 2017/5/20.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class EmoticonPackage {
    lazy var emoticons: [Emoticon] = [Emoticon]()
    
    init(plistName: String) {
        guard let path = Bundle.main.path(forResource: plistName, ofType: nil) else {
            return
        }
        guard let emoticonArray = NSArray(contentsOfFile: path) as? [String] else {
            return
        }
        for str in emoticonArray {
            emoticons.append(Emoticon(emoticonName: str))
        }
    }
}
