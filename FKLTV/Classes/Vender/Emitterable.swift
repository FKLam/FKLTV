//
//  Emitterable.swift
//  FKLTV
//
//  Created by kun on 2017/5/16.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

protocol Emitterable {
    
}

extension Emitterable where Self: UIViewController {
    func emitterableStart(_ point: CGPoint) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = point
        emitter.preservesDepth = true
        var cells = [CAEmitterCell]()
        for i in 0..<10 {
            let cell = CAEmitterCell()
            cell.velocity = 150
            cell.velocityRange = 100
            cell.scale = 0.7
            cell.scaleRange = 0.3
            cell.emissionLongitude = CGFloat(-Double.pi / 2.0)
            cell.emissionRange = CGFloat(Double.pi / 6.0)
            cell.lifetime = 3
            cell.lifetimeRange = 1.5
            cell.spin = CGFloat(Double.pi / 2.0)
            cell.spinRange = CGFloat(Double.pi / 4.0)
            cell.birthRate = 2
            cell.contents = UIImage(named: "good\(i)_30x30")?.cgImage
            cells.append(cell)
        }
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
    }
    
    func emitterableStop() {
        view.layer.sublayers?.filter({ (layer) -> Bool in
            return layer.isKind(of: CAEmitterLayer.self)
        }).first?.removeFromSuperlayer()
    }
}
