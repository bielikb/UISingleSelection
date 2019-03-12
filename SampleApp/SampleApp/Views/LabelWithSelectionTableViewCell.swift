//
//  LabelWithSelectionTableViewCell.swift
//  SampleApp
//
//  Created by Boris Bielik on 12/03/2019.
//  Copyright © 2019 Appsode, s.r.o. All rights reserved.
//

import Foundation
import UIKit
import UISingleSelection

final class LabelWithSelectionTableViewCell: UITableViewCell, UISingleSelectionTouchDown {

    // views
    private(set) var selectionView = ThreeCirclesView()
    let selectionButton = UIButton(type: .custom)

    // colors
    let selectionHighlightedColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04)
    let selectionBackgroundColor = UIColor.rgbColor(239, 239, 239)

    // selection
    var isSelectionSelected: Bool = false {
        didSet {
            selectionButton.isSelected = isSelectionSelected
            selectSelectionView(isSelectionSelected, animated: false)
        }
    }
    var onSelectionButtonTap: ((UIButton, Bool) -> Bool)?

    // inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSelectionView()
        setupTouchButton()
        self.backgroundView = UIView(frame: self.bounds)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSelectionView()
        setupTouchButton()
    }

    // setup
    private func setupSelectionView() {
        let size: CGFloat = 29
        selectionView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        selectionView.centerCircleVisibleOnlyWhenSelected = true
        selectionView.backgroundColor = UIColor.rgbColor(239, 239, 239)
        selectionView.outerCircleColor = UIColor.rgbColor(164, 175, 186)
        selectionView.innerCircleColor = UIColor.rgbColor(239, 239, 239)
        selectionView.centerCircleColor = UIColor.rgbColor(255, 188, 0)
        contentView.addSubview(selectionView)
    }

    private func setupTouchButton() {
        addSubview(selectionButton)
        bringSubviewToFront(selectionButton)
        selectionButton.addTarget(self, action: #selector(touchDown), for: .touchDown)
        selectionButton.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        selectionButton.addTarget(self, action: #selector(touched), for: .touchCancel)
        selectionButton.addTarget(self, action: #selector(touched), for: .touchUpOutside)
    }

    // MARK: Actions

    @objc private func touchDown(_ button: UIButton) {
        selectionButtonTouchDown(button: button)
    }

    @objc private func touchUpInside(_ button: UIButton) {
        selectionButtonTouchUpInside(button: button)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    @objc private func touched(_ button: UIButton) {
        selectionButtonWasTouched(button: button)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectionView.center.y = bounds.midY
        selectionView.frame.origin.x = bounds.width - 50

        selectionButton.frame = bounds
        backgroundView?.frame = self.bounds
        backgroundView?.backgroundColor = selectionBackgroundColor
    }

    func shake() {
        let animation = Animations.wiggle(aroundPoint: self.contentView.center)
        self.contentView.layer.add(animation, forKey: "shake")
    }
}

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
