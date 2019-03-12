//
//  Animations.swift
//  SampleApp
//
//  Created by Boris Bielik on 12/03/2019.
//  Copyright © 2019 Appsode, s.r.o. All rights reserved.
//

import Foundation
import UIKit

final class Animations {
    class func wiggle(aroundPoint point: CGPoint) -> CAAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.beginTime = CACurrentMediaTime() + 0.01
        animation.duration = 0.45;
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = true
        animation.values = [point.x, point.x-8, point.x+6, point.x-4, point.x+3, point.x-2, point.x]

        return animation
    }
}
