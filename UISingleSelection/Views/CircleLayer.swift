//
//  CircleLayer.swift
//  UISingleSelection
//
//  Created by Boris Bielik on 11/03/2019.
//  Copyright © 2019 Appsode, s.r.o. All rights reserved.
//

import Foundation

public final class CircleLayer : CAShapeLayer {

    var center: CGPoint = .zero {
        didSet {
            updateCircleLayerPath()
        }
    }

    private(set) var radius: CGFloat = 0.0
    private(set) var isAnimating = false

    private var currentPathAnimation: CABasicAnimation?
    private var currentAnimationKey = ""
    private var pathAnimationEndTime: CFTimeInterval = 0

    public convenience init(radius: CGFloat, center: CGPoint) {
        self.init()
        self.center = center
        self.radius = radius

        updateCircleLayerPath()
    }

    func updateCircleLayerPath() {
        path = ovalPath()
    }

    private func ovalPath() -> CGPath {
        return UIBezierPath(arcCenter: center,
                            radius: radius,
                            startAngle: 0,
                            endAngle: 2 * CGFloat.pi,
                            clockwise: true
            ).cgPath
    }

    private func animatePath(duration: CFTimeInterval) {
        isAnimating = true
        let beginTime = CACurrentMediaTime()
        if pathAnimationEndTime - beginTime > 0 {
            if let layer = self.presentation() {
                self.path = layer.path
            }

            self.removeAnimation(forKey: currentAnimationKey)
        }

        currentAnimationKey = "animation\(UUID().uuidString)"

        let animation: CABasicAnimation = CABasicAnimation()
        animation.keyPath = "path"
        animation.duration = duration
        animation.fromValue = path
        animation.toValue = ovalPath()
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = true
        animation.beginTime = beginTime

        self.add(animation, forKey: currentAnimationKey)

        currentPathAnimation = animation
        pathAnimationEndTime = animation.beginTime + duration
    }

    func setRadius(_ radius: CGFloat,
                   animated: Bool = false,
                   duration: CFTimeInterval = 0,
                   completion: (()->Void)? = nil) {
        self.radius = radius

        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock { [weak self] in
                self?.isAnimating = false
                completion?()
            }
            animatePath(duration: duration)
            CATransaction.commit()
        }

        CATransaction.pushTransaction(disableActions: true) { [weak self] in
            self?.updateCircleLayerPath()

        }
    }
}

public final class CircleView : UIView {

    private var circleLayer = CircleLayer()

    public override var backgroundColor: UIColor? {
        didSet {
            circleLayer.fillColor = backgroundColor?.cgColor
        }
    }

    private(set) var radius: CGFloat = 0.0

    public convenience init(radius: CGFloat, center: CGPoint) {
        self.init()
        self.radius = radius
        self.frame = newRect(radius: radius, center: center)
        setupCircleLayer()
    }

    private func setupCircleLayer() {
        let circleLayer = CircleLayer(radius: radius, center: self.bounds.center)
        circleLayer.fillColor = backgroundColor?.cgColor
        layer.addSublayer(circleLayer)
        self.circleLayer = circleLayer
    }

    private func newRect(radius: CGFloat, center: CGPoint) -> CGRect {
        let origin = CGPoint(x: center.x - radius/2, y: center.y - radius/2)
        let newRect = CGRect(origin: origin,
                             size: CGSize(width: radius, height: radius))
        return newRect.integral
    }

    public func setRadius(_ radius: CGFloat, animated: Bool = false, duration: CFTimeInterval = 0.0) {
        UIView.animate(withDuration: duration) { [weak self] in
            guard let self = self else { return }
            self.bounds = self.newRect(radius: radius, center: self.bounds.center)
        }

        circleLayer.setRadius(radius, animated: animated, duration: duration)
        self.radius = radius
    }

}

extension CATransaction {
    class func pushTransaction(disableActions: Bool = true, block: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(disableActions)
        block()
        CATransaction.commit()
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
