//
//  AlertVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/3.
//

import UIKit
import iOSDropDown

class AlertVC: UIViewController {
    public var vBg: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Popup
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onClose))
        self.view.addGestureRecognizer(gesture)
    }
    @objc func onClose(sender : UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func addBg(_ w: CGFloat, _ h: CGFloat) {
        let ww = self.view.frame.width
        let hh = self.view.frame.height
        let x = (ww - w) / 2
        let y = (hh - h) / 2
        self.vBg = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
        self.vBg.backgroundColor = .white
        self.vBg.layer.cornerRadius = 20
        self.view.addSubview(vBg)
    }
    class func showMessage(parent: UIViewController?, text: String, cancel:(()->Void)?, sure: (()->Void)?) {
        showMessage(parent: parent, text: text, action1_title: "Cancel", action2_title: "Sure", action1: cancel, action2: sure)
        /*let vc = AlertVC()
        vc.addBg(280, 190)
        let view = vc.vBg!
        
        let lbTitle = UILabel(frame: CGRect(x: 20, y: 27, width: 240, height: 50))
        lbTitle.text = text
        lbTitle.textColor = .dark
        lbTitle.font = UIFont(name: "SourceSansPro-Regular", size: 20)
        lbTitle.textAlignment = .center
        view.addSubview(lbTitle)
        
        let btnCancel = RoundButton(frame: CGRect(x: 25, y: 115, width: 115, height: 40))
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.action = {
            vc.dismiss(animated: true, completion: nil)
            cancel?()
        }
        view.addSubview(btnCancel)
        
        let btnSure = RoundButton(frame: CGRect(x: 158, y: 115, width: 90, height: 40))
        btnSure.setTitle("Sure", for: .normal)
        btnSure.action = {
            vc.dismiss(animated: true, completion: nil)
            sure?()
        }
        view.addSubview(btnSure)
        
        parent?.present(vc, animated: true, completion: nil)*/
    }
    
    class func showMessage(parent: UIViewController?, text: String, action_title: String, action: (()->Void)?) {
        let vc = AlertVC()
        vc.addBg(280, 190)
        let view = vc.vBg!
        
        let lbTitle = UILabel(frame: CGRect(x: 20, y: 27, width: 240, height: 80))
        lbTitle.text = text
        lbTitle.textColor = .dark
        lbTitle.font = UIFont(name: "SourceSansPro-Regular", size: 17)
        lbTitle.textAlignment = .center
        lbTitle.numberOfLines = 4
        view.addSubview(lbTitle)
        
        let btnAction1 = RoundButton(frame: CGRect(x: 85, y: 125, width: 110, height: 40))
        btnAction1.setTitle(action_title, for: .normal)
        btnAction1.action = {
            vc.dismiss(animated: true, completion: nil)
            action?()
        }
        view.addSubview(btnAction1)
        parent?.present(vc, animated: true, completion: nil)
    }
    
    class func showMessage(parent: UIViewController?, text: String, action1_title: String, action2_title: String, action1: (()->Void)?, action2: (()->Void)?) {
        let vc = AlertVC()
        vc.addBg(280, 190)
        let view = vc.vBg!
        
        let lbTitle = UILabel(frame: CGRect(x: 20, y: 27, width: 240, height: 50))
        lbTitle.text = text
        lbTitle.textColor = .dark
        lbTitle.font = UIFont(name: "SourceSansPro-Regular", size: 17)
        lbTitle.textAlignment = .center
        lbTitle.numberOfLines = 2
        view.addSubview(lbTitle)
        
        let btnAction1 = RoundButton(frame: CGRect(x: 20, y: 115, width: 110, height: 40))
        btnAction1.setTitle(action1_title, for: .normal)
        btnAction1.action = {
            vc.dismiss(animated: true, completion: nil)
            action1?()
        }
        view.addSubview(btnAction1)
        
        let btnAction2 = RoundButton(frame: CGRect(x: 150, y: 115, width: 110, height: 40))
        btnAction2.setTitle(action2_title, for: .normal)
        btnAction2.action = {
            vc.dismiss(animated: true, completion: nil)
            action2?()
        }
        view.addSubview(btnAction2)
        
        parent?.present(vc, animated: true, completion: nil)
    }
    class func showLeaveEvent(parent: UIViewController?, leave:(()->Void)?) {
        let vc = AlertVC()
        let view = vc.view!
        
        // Not Joining button
        let btnLeave = UIButton(frame: CGRect(x: 0, y: view.frame.height - 70, width: view.frame.width/2-1, height: 70))
        btnLeave.backgroundColor = .dark
        btnLeave.setTitle("Not Joining", for: .normal)
        btnLeave.setTitleColor(.yellow, for: .normal)
        btnLeave.titleLabel?.font = UIFont(name: "SourceSansPro-Bold", size: 20)
        btnLeave.addAction {
            vc.dismiss(animated: false, completion: nil)
            leave?()
        }
        view.addSubview(btnLeave)
        
        // Cancel button
        let btnCancel = UIButton(frame: CGRect(x: view.frame.width/2, y: view.frame.height-70, width: view.frame.width/2, height: 70))
        btnCancel.backgroundColor = .dark
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(.yellow, for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "SourceSansPro-Bold", size: 20)
        btnCancel.addAction {
            vc.dismiss(animated: false, completion: nil)
        }
        view.addSubview(btnCancel)
        
        parent?.present(vc, animated: false, completion: nil)
    }
    class func chooseEventDuration(parent:UIViewController?, callback: ((Int)->Void)? ) {
        let vc = AlertVC()
        vc.addBg(280, 250)
        vc.view.removeGestureRecognizer((vc.view.gestureRecognizers?[0])!)
        let view = vc.vBg!
        
        let lbTitle = UILabel(frame: CGRect(x: 20, y: 27, width: 240, height: 50))
        lbTitle.text = "Please choose event duration"
        lbTitle.textColor = .dark
        lbTitle.font = UIFont(name: "SourceSansPro-Bold", size: 17)
        lbTitle.textAlignment = .center
        view.addSubview(lbTitle)
        
        let ddDur = DropDown(frame: CGRect(x: 20, y: 100, width: 240, height: 40))
        ddDur.optionArray = ["None", "15 mins", "30 mins", "1 hour", "2 hour"]
        //ddDur.borderWidth = 1
        //ddDur.borderColor = UIColor.light
        //ddDur.borderStyle = .line
        ddDur.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        ddDur.textColor = .dark
        ddDur.selectedIndex = 0
        ddDur.text = "None"
        ddDur.isSearchEnable = false
        ddDur.checkMarkEnabled = false
        ddDur.selectedRowColor = .light
        view.addSubview(ddDur)
        
        // underline
        let underline = UIView(frame: CGRect(x: 20, y: 141, width: 240, height: 1))
        underline.backgroundColor = .light
        view.addSubview(underline)
        
        let dur = [0,15,30,60,120]
        let btnNext = RoundButton(frame: CGRect(x: 90, y: 180, width: 100, height: 40))
        btnNext.setTitle("Next", for: .normal)
        btnNext.action = {
            vc.dismiss(animated: true, completion: nil)
            callback?(dur[ddDur.selectedIndex ?? 0])
        }
        view.addSubview(btnNext)
        
        parent?.present(vc, animated: true, completion: nil)
    }
    class func addTag(parent:UIViewController?, callback: ((String)->Void)? ) {
        let vc = AlertVC()
        vc.addBg(280, 250)
        vc.view.removeGestureRecognizer((vc.view.gestureRecognizers?[0])!)
        let view = vc.vBg!
        
        let lbTitle = UILabel(frame: CGRect(x: 20, y: 27, width: 240, height: 50))
        lbTitle.text = "Please choose a tag to add."
        lbTitle.textColor = .dark
        lbTitle.font = UIFont(name: "SourceSansPro-Bold", size: 17)
        lbTitle.textAlignment = .center
        view.addSubview(lbTitle)
        
        let ddDur = DropDown(frame: CGRect(x: 20, y: 100, width: 240, height: 40))
        ddDur.optionArray = [
            "Salty",
            "Foodie",
            "Nutty",
            "Jock",
            "Flakey",
            "Reliable",
            "Adventurous",
            "Outgoing",
            "Witty",
            "Gamer",
            "Geek",
            "Leader",
            "Quiet",
            "Low key",
            "Basic"

        ]
        //ddDur.borderWidth = 1
        //ddDur.borderColor = UIColor.light
        //ddDur.borderStyle = .line
        ddDur.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        ddDur.textColor = .dark
        ddDur.selectedIndex = 0
        ddDur.text = "Salty"
        ddDur.isSearchEnable = false
        ddDur.checkMarkEnabled = false
        ddDur.selectedRowColor = .light
        view.addSubview(ddDur)
        
        // underline
        let underline = UIView(frame: CGRect(x: 20, y: 141, width: 240, height: 1))
        underline.backgroundColor = .light
        view.addSubview(underline)
        
        // Cancel
        let btnCancel = RoundButton(frame: CGRect(x: 30, y: 180, width: 100, height: 40))
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.action = {
            vc.dismiss(animated: true, completion: nil)
        }
        view.addSubview(btnCancel)
        
        // Add
        let btnAdd = RoundButton(frame: CGRect(x: 150, y: 180, width: 100, height: 40))
        btnAdd.setTitle("Next", for: .normal)
        btnAdd.action = {
            vc.dismiss(animated: true, completion: nil)
            callback?(ddDur.text ?? "")
        }
        view.addSubview(btnAdd)
        
        parent?.present(vc, animated: true, completion: nil)
    }
    class func dotMenu(parent:UIViewController?, unfriend: (()->Void)?, report: (()->Void)?) {
        let vc = AlertVC()
        
        // background view
        let w = vc.view.frame.width
        //let h = vc.view.frame.height
        let view = UIView(frame: CGRect(x: w-120, y: 86, width: 100, height: 80))
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        vc.view.addSubview(view)
        
        // seperator
        let sep = UIView(frame: CGRect(x: 0, y: 40, width: 100, height: 1))
        sep.backgroundColor = .light
        view.addSubview(sep)
        
        // friend button
        let btnFriend = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        btnFriend.setTitle("Unfriend", for: .normal)
        btnFriend.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        btnFriend.setTitleColor(.white, for: .normal)
        btnFriend.addAction {
            vc.dismiss(animated: true, completion: nil)
            unfriend?()
        }
        view.addSubview(btnFriend)
        
        // report button
        let btnReport = UIButton(frame: CGRect(x: 0, y: 40, width: 100, height: 40))
        btnReport.setTitle("Report", for: .normal)
        btnReport.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        btnReport.setTitleColor(.white, for: .normal)
        btnReport.addAction {
            vc.dismiss(animated: true, completion: nil)
            report?()
        }
        view.addSubview(btnReport)
        
        parent?.present(vc, animated: true, completion: nil)
    }
}
