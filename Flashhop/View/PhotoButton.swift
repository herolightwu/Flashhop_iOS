//
//  PhotoButton.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/2.
//

import UIKit

@IBDesignable open class PhotoButton: MyButton {
    @IBInspectable public var borderColor: UIColor = UIColor(rgb: 0xFFFFFF) {
        didSet { refresh() }
    }
    @IBInspectable public var borderWidth: CGFloat = 1 {
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
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 0//borderWidth
        self.contentMode = .scaleAspectFill
        
        self.clipsToBounds = true
        //self.setImage(photo, for: .normal)
        /*self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = true*/
        /*let shadowSize : CGFloat = 1.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize/2, y: -shadowSize/2, width: self.frame.size.width + shadowSize, height: self.frame.size.height + shadowSize))
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = shadowPath.cgPath*/
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        refresh()
    }
}
