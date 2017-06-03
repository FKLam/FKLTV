//
//  FKLNavigationController.swift
//  FKLTV
//
//  Created by kun on 2017/5/7.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

class FKLNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 使用运行时
        guard let targets = interactivePopGestureRecognizer!.value(forKey: "_targets") as? [NSObject] else {
            return
        }
        let targetObjc = targets.first
        let target = targetObjc?.value(forKey: "target")
        let action = Selector(("handleNavigationTransition:"))
        let panGes = UIPanGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(panGes)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if childViewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

}
