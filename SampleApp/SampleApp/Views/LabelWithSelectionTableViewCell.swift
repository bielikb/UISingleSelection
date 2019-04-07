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

final class LabelWithSelectionTableViewCell: UITableViewCell {

    struct Sizes {
        static let SelectionViewSize: CGSize = CGSize(width: 29, height: 29)
        static let SelectionViewHorizontalIndent: CGFloat = 50
    }

    // views
    private(set) var selectionView: ThreeCirclesView = {
        let selectionView = ThreeCirclesView()
        selectionView.frame = CGRect(origin: .zero, size: Sizes.SelectionViewSize)
        selectionView.centerCircleVisibleOnlyWhenSelected = true
        selectionView.backgroundColor = UIColor.rgbColor(239, 239, 239)
        selectionView.outerCircleColor = UIColor.rgbColor(164, 175, 186)
        selectionView.innerCircleColor = UIColor.rgbColor(239, 239, 239)
        selectionView.centerCircleColor = UIColor.rgbColor(255, 188, 0)

        return selectionView
    }()

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
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        //add subviews
        backgroundView = UIView()
        contentView.addSubview(selectionView)
        addSubview(selectionButton)
        bringSubviewToFront(selectionButton)

        selectionButton.addTarget(self, action: #selector(touchDown), for: .touchDown)
        selectionButton.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        selectionButton.addTarget(self, action: #selector(touched), for: .touchCancel)
        selectionButton.addTarget(self, action: #selector(touched), for: .touchUpOutside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectionView.center.y = bounds.midY
        selectionView.frame.origin.x = bounds.width - Sizes.SelectionViewHorizontalIndent

        selectionButton.frame = bounds
        backgroundView?.frame = bounds
        backgroundView?.backgroundColor = selectionBackgroundColor
    }

    func shake() {
        let animation = Animations.wiggle(aroundPoint: contentView.center)
        contentView.layer.add(animation, forKey: "shake")
    }
}

// MARK: Actions
extension LabelWithSelectionTableViewCell: UISingleSelectionTouchDown {

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
}
