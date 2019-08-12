//
//  ChangePasswordVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/3.
//

import UIKit

class ChangePasswordVC: UIViewController {

    let valid_color = UIColor(rgb: 0x363C5A)
    
    @IBOutlet weak var tfCurrent: UITextField!
    @IBOutlet weak var tfNew: UITextField!
    @IBOutlet weak var tfConfirm: UITextField!
    @IBOutlet weak var lbStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tfCurrent.layer.borderWidth = 1
        tfCurrent.layer.cornerRadius = 2
        tfCurrent.layer.borderColor = valid_color.cgColor
        tfCurrent.setPaddingPoints(8)
        
        tfNew.layer.borderWidth = 1
        tfNew.layer.cornerRadius = 2
        tfNew.layer.borderColor = valid_color.cgColor
        tfNew.setPaddingPoints(8)
        
        tfConfirm.layer.borderWidth = 1
        tfConfirm.layer.cornerRadius = 2
        tfConfirm.layer.borderColor = UIColor.gray.cgColor
        tfConfirm.setPaddingPoints(8)
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onSave(_ sender: Any) {
        var current = tfCurrent.text!
        var new = tfNew.text!
        var confirm = tfConfirm.text!
        
        if !tfCurrent.isSecureTextEntry { current = "" }
        if !tfNew.isSecureTextEntry { new = "" }
        if !tfConfirm.isSecureTextEntry { confirm = "" }
        
        var bInvalid = false
        if new.count < 6 {
            tfNew.text = "Minimum 6 characters"
            tfNew.isSecureTextEntry = false
            tfNew.textColor = .red
            tfNew.layer.borderColor = UIColor.red.cgColor
            bInvalid = true
        }
        if confirm != new || confirm == "" {
            tfConfirm.text = "Password is not matching"
            tfConfirm.isSecureTextEntry = false
            tfConfirm.textColor = .red
            tfConfirm.layer.borderColor = UIColor.red.cgColor
            bInvalid = true
        }
        if bInvalid { return }
        
        APIManager.changePassword(pw: current, new_pw: new, result: { (value) in
            self.lbStatus.isHidden = false
        }) { (error) in
            print(error)
            let code = error["code"] as! Int
            switch code {
            case 116:   // wrong password
                self.tfCurrent.textColor = .red
                self.tfCurrent.isSecureTextEntry = false
                self.tfCurrent.text = "Wrong password"
                self.tfCurrent.layer.borderColor = UIColor.red.cgColor
                break;
            default:
                print("Invalid error code...")
            }
        }
    }
    @IBAction func onEditingDidBegin(_ sender: UITextField) {
        if !sender.isSecureTextEntry {
            sender.isSecureTextEntry = true
            sender.textColor = valid_color
            sender.layer.borderColor = valid_color.cgColor
            sender.text = ""
        }
        lbStatus.isHidden = true
    }    
}
extension ChangePasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfCurrent {
            tfNew.becomeFirstResponder()
        }else if textField == tfNew {
            tfConfirm.becomeFirstResponder()
        }else if textField == tfConfirm {
            self.view.endEditing(true)
            onSave(textField)
        }
        return true
    }
}
