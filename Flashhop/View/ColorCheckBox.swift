//
//  CheckBox.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/30.
//

import UIKit

@IBDesignable open class ColorCheckBox: UIButton {
    @IBInspectable public var fontSize: CGFloat = 14 {
        didSet { refresh() }
    }
    
    @IBInspectable public var isChecked: Bool = false {
        didSet {
            refresh()
        }
    }
    @IBInspectable public var isBorderEnabled: Bool = true {
        didSet {
            refresh()
        }
    }
    @IBInspectable public var checked_color: UIColor = UIColor(rgb: 0x363C5A) {
        didSet {
            refresh()
        }
    }
    @IBInspectable public var unchecked_color: UIColor = UIColor.white {
        didSet {
            refresh()
        }
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        refresh()
    }
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        refresh()
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isChecked = !isChecked
        refresh()
        super.touchesEnded(touches, with: event)
        //self.sendActions(for: UIControl.Event.touchUpInside)
    }
    func refresh() {
        self.layer.cornerRadius = 2
        self.titleLabel?.font = UIFont(name: "SourceSansPro-SemiBold", size: fontSize)
        
        if isBorderEnabled {
            self.layer.borderWidth = 1
            self.layer.borderColor = checked_color.cgColor
        }else{
            self.layer.borderWidth = 0
        }
        
        if isChecked {
            self.backgroundColor = checked_color
            self.setTitleColor(unchecked_color, for: .normal)
        }else{
            self.backgroundColor = unchecked_color
            self.setTitleColor(checked_color, for: .normal)
        }
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        refresh()
    }
}
