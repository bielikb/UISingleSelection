//
//  ThreeCirclesView.swift
//  UISingleSelection
//
//  Created by Boris Bielik on 11/03/2019.
//  Copyright © 2019 Appsode, s.r.o. All rights reserved.
//

import Foundation
import UIKit

public struct CirclesRadiuses {
    public let outer: CGFloat
    public let inner: CGFloat
    public let center: CGFloat

    static func defaultOuterRadius(in bounds: CGRect) -> CGFloat {
        return ceil(bounds.width / 2) - 1
    }

    static func defaultCenterRadius(in bounds: CGRect) -> CGFloat {
        return CirclesRadiuses.defaultOuterRadius(in: bounds) * 0.43
    }

    static var zero: CirclesRadiuses {
        return CirclesRadiuses(0, 0, 0)
    }

    public init(_ outer: CGFloat, _ inner: CGFloat, _ center: CGFloat) {
        self.outer = outer
        self.inner = inner
        self.center = center
    }
}

public enum CirclesState {
    case highlighted
    case selected
    case normal
    case none
}

public final class ThreeCirclesView: UIView {

    public internal(set) var state : CirclesState = .none

    public var outerCircleColor: UIColor? {
        didSet {
            outerCircleLayer?.fillColor = outerCircleColor?.cgColor
        }
    }

    public var innerCircleColor: UIColor? {
        didSet {
            innerCircleLayer?.fillColor = innerCircleColor?.cgColor
        }
    }

    public var centerCircleColor: UIColor? {
        didSet {
            centerCircleLayer?.fillColor = centerCircleColor?.cgColor
        }
    }

    override public var frame: CGRect {
        didSet {
            let viewRadius = CirclesRadiuses.defaultOuterRadius(in: bounds)
            centerRadius = CirclesRadiuses.defaultCenterRadius(in: bounds)

            self.normal = CirclesRadiuses(viewRadius, viewRadius*0.90, centerRadius)
            self.highlighted = CirclesRadiuses(viewRadius, centerRadius, centerRadius)
            self.selected = CirclesRadiuses(viewRadius, viewRadius*0.78, centerRadius)
            self.highlightedAfterSelected = CirclesRadiuses(viewRadius, viewRadius*0.67, centerRadius)

            updateLayersCenter()
        }
    }

    private var normal: CirclesRadiuses = .zero
    private var highlighted: CirclesRadiuses = .zero
    private var highlightedAfterSelected: CirclesRadiuses = .zero
    private var selected: CirclesRadiuses = .zero

    private(set) var outerRadius: CGFloat = 0
    private(set) var innerRadius: CGFloat = 0
    private(set) var centerRadius: CGFloat = 0

    private var outerCircleLayer: CircleLayer?
    private var innerCircleLayer: CircleLayer?
    private var centerCircleLayer: CircleLayer?

    public var centerCircleVisibleOnlyWhenSelected: Bool = true

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        outerCircleLayer = createCircleLayer()
        innerCircleLayer = createCircleLayer()
        centerCircleLayer = createCircleLayer()

        self.clipsToBounds = true

        setState(state: .normal, animated: false)
    }

    private func createCircleLayer() -> CircleLayer {
        let circleLayer = CircleLayer(radius: bounds.size.width / 2, center: bounds.center)
        layer.addSublayer(circleLayer)
        return circleLayer
    }

    private func updateLayersCenter() {
        outerCircleLayer?.center = bounds.center
        innerCircleLayer?.center = bounds.center
        centerCircleLayer?.center = bounds.center
    }

    public func setState(state: CirclesState, animated: Bool) {
        guard self.state != state else {
            return
        }
        self.state = state

        // radiuses
        let radiuses = self.radiuses(for: state)
        self.outerRadius = radiuses.outer
        self.innerRadius = radiuses.inner
        self.centerRadius = radiuses.center

        // duration
        let duration = state == .highlighted ? 0.14 : 0.2

        // outer
        outerCircleLayer?.setRadius(radiuses.outer, animated: animated, duration: duration)

        // inner
        switch(state) {
        case .selected where innerCircleLayer?.isAnimating == true:
            self.innerCircleLayer?.setRadius((self.bounds.width/2)*0.705, animated: true, duration: 0.14)
            after(.milliseconds(1401)) { [weak self] in
                guard let self = self else { return }
                self.innerCircleLayer?.setRadius(self.innerRadius, animated: animated, duration: duration)
            }
        default:
            self.innerCircleLayer?.setRadius(radiuses.inner,
                                            animated: animated,
                                            duration: duration
            )
        }

        // center
        let shouldShowCenterCircleLayer = state == .selected && centerCircleVisibleOnlyWhenSelected ? false : true
        self.centerCircleLayer?.isHidden = shouldShowCenterCircleLayer
        self.centerCircleLayer?.setRadius(
            radiuses.center,
            animated: animated,
            duration: duration
        )
    }

    public func radiuses(for state: CirclesState) -> CirclesRadiuses {
        switch (state, self.state) {
        case (.normal, _):
            return normal
        case (.highlighted, .selected):
            return highlightedAfterSelected
        case (.highlighted, _):
            return highlighted
        default:
            return selected
        }
    }

    public func setRadiuses(_ radiuses: CirclesRadiuses, forState state: CirclesState) {
        switch (state) {
        case .normal:
            normal = radiuses
        case .highlighted:
            highlighted = radiuses
        default:
            selected = radiuses
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = round(bounds.size.height / 2)

        updateLayer(outerCircleLayer)
        updateLayer(innerCircleLayer)
        updateLayer(centerCircleLayer)
    }

    private func updateLayer(_ layer: CircleLayer?) {
        layer?.frame = bounds
        layer?.updateCircleLayerPath()
    }
}

/// Performs block of code after specified delay
func after(_ delay: DispatchTimeInterval, _ block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + delay,
        execute: block
    )
}
