//
//  BaseModel.swift
//  FKLTV
//
//  Created by kun on 2017/5/14.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class BaseModel: NSObject {
    
    override init() {
        
    }

    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
