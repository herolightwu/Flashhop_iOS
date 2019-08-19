//
//  File.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/19.
//

import UIKit
import Photos
import AMPopTip
import CoreLocation

let GOOGLE_API_KEY = "AIzaSyCHzKyjpTvTfAKdC6_CyA03ZqIcfMMyGHg"
let DEBUG_MODE = false

var me = FUser()
var myCard = Card()

func isValidEmail(_ emailStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let trimmedString = emailStr.trimmingCharacters(in: .whitespacesAndNewlines)
    return emailPred.evaluate(with: trimmedString)
}
func showAlert (parent:UIViewController, title:String, msg:String) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    parent.present(alert, animated: true, completion: nil)
}

func getImage(asset: PHAsset) -> UIImage {
    var image = UIImage()
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.isSynchronous = true
    options.resizeMode = PHImageRequestOptionsResizeMode.exact
    let targetSize = CGSize(width:1200, height:1200)
    PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (receivedImage, info) in
        if let formAnImage = receivedImage
        {
            image = formAnImage
        }
    }
    return image
}

func showTip(text:String, parent:UIView) {
    if parent.superview!.viewWithTag(39278) == nil {    // only once
        let v = PopTip()
        v.font = UIFont(name: "SourceSansPro-Regular", size: 14)!
        v.textColor = .white
        v.bubbleColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        v.padding = 20
        v.cornerRadius = 10
        v.tag = 39278
        v.show(text: text, direction: .down, maxWidth: 230, in: parent.superview!, from: parent.frame, duration: 3)
    }
}

func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let rc = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
    let label:UILabel = UILabel(frame: rc)
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text

    label.sizeToFit()
    return label.frame.height
}

func showLinkTip(text:String, parent:UIView) {
    if parent.superview!.viewWithTag(39278) == nil {// only once
        let title_range = NSMakeRange(0, text.count)
        let Attr_text = NSMutableAttributedString(string: text)
        Attr_text.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: title_range)
        Attr_text.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], range: title_range)
        let myfont = UIFont(name: "SourceSansPro-Regular", size: 14)!
        Attr_text.addAttribute(NSAttributedString.Key.font, value: myfont, range: title_range)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        Attr_text.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: title_range)
        
        let v = PopTip()
        //v.font = UIFont(name: "SourceSansPro-Regular", size: 14)!
        //v.textColor = .white
        v.bubbleColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        v.padding = 20
        v.cornerRadius = 10
        v.tag = 39278
        //v.show(text: text, direction: .down, maxWidth: 230, in: parent.superview!, from: parent.frame, duration: 3)
        v.show(attributedText: Attr_text, direction: .down, maxWidth: 230, in: parent.superview!, from: parent.frame, duration: 3)
        v.tapHandler = { popTip in
            guard let site_url = URL(string: "https://www.16personalities.com/free-personality-test") else {
                return
            }
            UIApplication.shared.open(site_url)
        }
    }
}

func makeShadowView(_ view:UIView) {
    view.layer.shadowColor = UIColor.darkGray.cgColor
    view.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    view.layer.shadowRadius = 0.0
    view.layer.shadowOpacity = 0.3
    view.layer.masksToBounds = false
}

func makeShadow(_ view:UIView) {
    //view.clipsToBounds = false
    //self.setImage(photo, for: .normal)
    view.layer.shadowColor = UIColor.darkGray.cgColor
    view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    view.layer.shadowRadius = 0.0
    view.layer.shadowOpacity = 1.0
    view.layer.masksToBounds = false
    /*let shadow = UIView(frame: view.frame)
    shadow.backgroundColor = .clear
    shadow.layer.shadowColor = UIColor.darkGray.cgColor
    shadow.layer.shadowPath = UIBezierPath(roundedRect: shadow.bounds, cornerRadius: view.layer.cornerRadius).cgPath
    shadow.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
    shadow.layer.shadowOpacity = 0.5
    shadow.layer.shadowRadius = 1
    shadow.layer.masksToBounds = true
    shadow.clipsToBounds = false
    view.superview?.addSubview(shadow)
    view.superview?.bringSubviewToFront(view)*/
    
    /*shadow.translatesAutoresizingMaskIntoConstraints = false
    let leading = NSLayoutConstraint(item: shadow, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
    let trailing = NSLayoutConstraint(item: shadow, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
    let top = NSLayoutConstraint(item: shadow, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
    let bottom = NSLayoutConstraint(item: shadow, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
    view.superview?.addConstraints([leading, trailing, top, bottom])*/
}

//https://stackoverflow.com/questions/46556422/how-to-make-uibutton-shake-on-tap
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-12.0, 12.0, -12.0, 12.0, -6.0, 6.0, -3.0, 3.0, 0.0]
        self.layer.add(animation, forKey: "shake")
    }
}
//https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    static let yellow = UIColor(rgb:0xFFD200)
    static let dark = UIColor(rgb:0x363C5A)
    static let light = UIColor(rgb: 0xB1B1B1)
    static let error = UIColor(rgb: 0xFF2134)
    static let green = UIColor(rgb: 0x29B52E)
}
//https://stackoverflow.com/questions/25367502/create-space-at-the-beginning-of-a-uitextfield
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    func setPaddingPoints(_ amount: CGFloat) {
        setLeftPaddingPoints(amount)
        setRightPaddingPoints(amount)
    }
}
//https://stackoverflow.com/questions/26306326/swift-apply-uppercasestring-to-only-the-first-letter-of-a-string#targetText=A%20capitalized%20string%20is%20a,%2C%20tabs%2C%20or%20line%20terminators.
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    func toDouble() -> Double {
        return NumberFormatter().number(from: self)?.doubleValue ?? 0
    }
}
//https://stackoverflow.com/questions/24962151/hooking-up-uibutton-to-closure-swift-target-action
class ClosureSleeve {
    let closure: () -> ()
    
    init(attachTo: AnyObject, closure: @escaping () -> ()) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc func invoke() {
        closure()
    }
}
extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}
//https://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = resizedImage.pngData()
                else { return nil }
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }
        return resizingImage
    }
}
//https://stackoverflow.com/questions/37048759/swift-display-html-data-in-a-label-or-textview
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
