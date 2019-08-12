//
//  ImageCheckBox.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/31.
//

import UIKit

@IBDesignable open class ImageCheckBox: UIButton {
    @IBInspectable public var isChecked: Bool = false {
        didSet { refresh() }
    }
    @IBInspectable public var image_space: CGFloat = 8 {
        didSet { refresh() }
    }
    @IBInspectable public var checked_image: UIImage? = UIImage(named: "checked") {
        didSet { refresh() }
    }
    @IBInspectable public var unchecked_image: UIImage? = UIImage(named: "unchecked") {
        didSet { refresh() }
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isChecked = !isChecked
        refresh()
        super.touchesEnded(touches, with: event)
        //self.sendActions(for: UIControl.Event.touchUpInside)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        refresh()
    }
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        refresh()
    }
    func refresh() {
        if isChecked { self.setImage(checked_image, for: .normal) }
        else { self.setImage(unchecked_image, for: .normal) }
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image_space)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: image_space, bottom: 0, right: 0)
        super.layoutSubviews()
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        refresh()
    }
}
