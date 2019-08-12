//
//  SideRoundButton.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/26.
//

import UIKit

@available(iOS 11.0, *)
class SideRoundButton: UIButton {
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
    func refresh() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        self.setTitleColor(fontColor, for: .normal)
        self.titleLabel?.font = UIFont(name: "SourceSansPro-Bold", size: fontSize)
        self.backgroundColor = bgColor
        
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        refresh()
    }
}
