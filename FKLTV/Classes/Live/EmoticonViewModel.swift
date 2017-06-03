//
//  EmoticonViewModel.swift
//  FKLTV
//
//  Created by kun on 2017/5/20.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class EmoticonViewModel {
    static let shareInstance: EmoticonViewModel = EmoticonViewModel()
    lazy var packages: [EmoticonPackage] = [EmoticonPackage]()
    
    init() {
        packages.append(EmoticonPackage(plistName: "QHNormalEmotionSort.plist"))
        packages.append(EmoticonPackage(plistName: "QHSohuGifSort.plist"))
    }
}
