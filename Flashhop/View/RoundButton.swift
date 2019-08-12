//
//  RoundButton.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/31.
//

import UIKit

@IBDesignable open class MyButton: UIButton  {
    public var tag2 = 0
}

@IBDesignable open class RoundButton: MyButton {
    public var action: (()->Void)? = nil
    @IBInspectable public var fontSize: CGFloat = 18 {
        didSet { refresh() }
    }
    @IBInspectable public var fontColor: UIColor = UIColor(rgb: 0x363C5A) {
        didSet { refresh() }
    }
    @IBInspectable public var bgColor: UIColor = UIColor(rgb: 0xFFD200) {
        didSet { refresh() }
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
        super.touchesEnded(touches, with: event)
        action?()
    }
    func refresh() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.setTitleColor(fontColor, for: .normal)
        self.titleLabel?.font = UIFont(name: "SourceSansPro-Bold", size: fontSize)
        self.backgroundColor = bgColor
        
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        refresh()
    }
}
