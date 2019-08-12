//
//  RoundShadowView.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/25.
//

import UIKit

class RoundShadowView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 2) {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 4.0 {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            self.updateProperties()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.masksToBounds = false

        self.updateProperties()
        self.updateShadowPath()
    }

    fileprivate func updateProperties() {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.shadowColor = self.shadowColor.cgColor
        self.layer.shadowOffset = self.shadowOffset
        self.layer.shadowRadius = self.shadowRadius
        self.layer.shadowOpacity = self.shadowOpacity
    }

    fileprivate func updateShadowPath() {
        self.layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.updateShadowPath()
    }
}
