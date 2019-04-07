//
//  UIColor.swift
//  SampleApp
//
//  Created by Boris Bielik on 07/04/2019.
//  Copyright © 2019 Appsode, s.r.o. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func rgbColor(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> UIColor {
        return UIColor(
            red:    CGFloat(r)/255.0,
            green:  CGFloat(g)/255.0,
            blue:   CGFloat(b)/255.0,
            alpha: a
        )
    }
}
