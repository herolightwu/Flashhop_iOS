//
//  SettingTextField.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/11/4.
//

import UIKit

class SettingTextField: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var textMain: UITextField!
    @IBOutlet weak var viewUnderLine: UIView!

    @IBInspectable public var label: String = "" {
        didSet {
            lblTitle.text = label
        }
    }
    @IBInspectable public var placeholderText: String = "" {
        didSet {
            textMain.placeholder = placeholderText
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SettingTextField", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        ])
    }
    
    public func setError(error: Bool = true) {
        if error == true {
            viewUnderLine.backgroundColor = UIColor.red
            textMain.textColor = UIColor.red
            lblTitle.text = "*" + label
            lblTitle.textColor = UIColor.red
        } else {
            viewUnderLine.backgroundColor = UIColor.init(rgb: 0x808080)
            textMain.textColor = UIColor.init(rgb: 0x363C5A)
            lblTitle.text = label
            lblTitle.textColor = UIColor.init(rgb: 0x808080)
        }
    }
    public func setErrorPlaceholder(error: Bool = true) {
        if error == true {
            textMain.attributedPlaceholder = NSAttributedString(
                string: textMain.placeholder!,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            viewUnderLine.backgroundColor = UIColor.red
        } else {
            textMain.attributedPlaceholder = NSAttributedString(
                string: textMain.placeholder!,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(rgb: 0x808080)])
            viewUnderLine.backgroundColor = UIColor.init(rgb: 0x808080)
        }
    }
}
