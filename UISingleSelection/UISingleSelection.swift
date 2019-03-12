//
//  UISingleSelection.swift
//  UISingleSelection
//
//  Created by Boris Bielik on 11/03/2019.
//  Copyright © 2019 Appsode, s.r.o. All rights reserved.
//

import Foundation

public protocol UISingleSelection {

    var selectionView: ThreeCirclesView { get }
    var selectionHighlightedColor: UIColor { get }
    var selectionBackgroundColor: UIColor { get }
    var isSelectionSelected: Bool { get }

    func selectSelectionView(_ select: Bool, animated: Bool)
    func highlightSelectionView(highlight: Bool, animated: Bool)
}

extension UISingleSelection where Self: UIView {

    public func selectSelectionView(_ select: Bool, animated: Bool) {
        let state: CirclesState = select ? .selected : .normal
        selectionView.setState(state: state, animated: animated)
    }

    public func highlightSelectionView(highlight: Bool, animated: Bool) {
        let backgroundColor = highlight ? selectionHighlightedColor : selectionBackgroundColor

        let setSelectionColor: (UIColor) -> Void = { [weak self] backgroundColor in
            self?.selectionView.backgroundColor = backgroundColor
        }

        if animated {
            UIView.animate(withDuration: 0.2) {
                setSelectionColor(backgroundColor)
            }
        }
        else {
            setSelectionColor(backgroundColor)
        }
    }
}

public protocol UISingleSelectionTouchDown: UISingleSelection {

    var selectionButton: UIButton { get }
    var onSelectionButtonTap: ((_ button: UIButton, _ selected:Bool)-> Bool)? { get }

    func selectionButtonWasTouched(button: UIButton)
    func selectionButtonTouchUpInside(button: UIButton)
    func selectionButtonTouchDown(button: UIButton)
}

extension UISingleSelectionTouchDown where Self: UIView {

    public func selectionButtonWasTouched(button: UIButton) {
        defer {
            highlightSelectionView(highlight: false, animated: true)
        }

        let selectView: (UIButton) -> Void = { [weak self] button in
            self?.selectSelectionView(button.isSelected, animated: true)
        }

        guard onSelectionButtonTap != nil else {
            selectView(button)
            return
        }

        if onSelectionButtonTap?(button, button.isSelected) == true {
            selectView(button)
        }
    }

    public func selectionButtonTouchUpInside(button: UIButton) {
        selectionButton.isSelected.toggle()
        selectionButtonWasTouched(button: selectionButton)
    }

    public func selectionButtonTouchDown(button: UIButton) {
        selectionView.setState(state: .highlighted, animated: true)
        highlightSelectionView(highlight: true, animated: true)
    }

}

