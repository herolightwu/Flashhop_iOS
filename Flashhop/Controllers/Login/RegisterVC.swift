//
//  RegisterVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/9.
//

import UIKit
import Alamofire
import KRProgressHUD
import OneSignal

class RegisterVC: UIViewController {
    
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirm: UITextField!
    
    @IBOutlet weak var ivFirstName: UIImageView!
    @IBOutlet weak var ivLastName: UIImageView!
    @IBOutlet weak var ivEmail: UIImageView!
    @IBOutlet weak var ivPassword: UIImageView!
    @IBOutlet weak var ivConfirm: UIImageView!
    
    @IBOutlet weak var btnSend: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSend(_ sender: UIButton) {
        self.view.endEditing(true)
        
        var first_name = tfFirstName.text
        var last_name = tfLastName.text
        var email = tfEmail.text
        var pw = tfPassword.text
        var confirm = tfConfirm.text
        
        // ignore warning string !!!
        if ivFirstName.isHidden == false { first_name = "" }
        if ivLastName.isHidden == false { last_name = "" }
        if ivEmail.isHidden == false { email = "" }
        if ivPassword.isHidden == false { pw = "" }
        if ivConfirm.isHidden == false { confirm = "" }
        
        var bInvalid = false
        if let email = email {
            if !isValidEmail(email) {
                tfEmail.text = "Email is invalid"
                tfEmail.textColor = UIColor.error
                ivEmail.isHidden = false
                bInvalid = true
            }
        }else{
            tfEmail.text = "Email is empty"
            tfEmail.textColor = UIColor.error
            ivEmail.isHidden = false
            bInvalid = true
        }
        if first_name == "" {
            tfFirstName.text = "First name is empty"
            tfFirstName.textColor = UIColor.error
            ivFirstName.isHidden = false
            bInvalid = true
        }
        if last_name == "" {
            tfLastName.text = "Last name is empty"
            tfLastName.textColor = UIColor.error
            ivLastName.isHidden = false
            bInvalid = true
        }
        if let pw = pw {
            if pw.count < 6 {
                tfPassword.text = "Minimum 6 characters"
                tfPassword.isSecureTextEntry = false
                tfPassword.textColor = UIColor.error
                ivPassword.isHidden = false
                bInvalid = true
            }
        }else{
            tfPassword.text = "Password is empty"
            tfPassword.isSecureTextEntry = false
            tfPassword.textColor = UIColor.error
            ivPassword.isHidden = false
            bInvalid = true
        }
        if confirm != pw || confirm == "" {
            tfConfirm.text = "Password is not matching"
            tfConfirm.isSecureTextEntry = false
            tfConfirm.textColor = UIColor.error
            ivConfirm.isHidden = false
            bInvalid = true
        }
        
        if bInvalid {
            return
        }
        
        let push_id = OneSignal.getPermissionSubscriptionState()?.subscriptionStatus.userId ?? ""
        APIManager.register(email: email!, pw: pw!, first_name: first_name!, last_name: last_name!, push_id: push_id, result: { (value) in
            let token = value["token"] as! String
            APIManager.set_token(token)
            me.email = email!
            APIManager.didAuth(self)
        }) { (error) in
            print(error)
            let code = error["code"] as! Int
            switch code {
            case 105:    // email already exist
                me.email = email!
                let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
                break
            default:
                break
            }
        }
    }
    @IBAction func onEditingDidBegin(_ sender: UITextField) {
        if let color = sender.textColor {
            if color.isEqual(UIColor.error) {
                sender.text = ""
                sender.textColor = .white
                
                if sender.tag == 3 || sender.tag == 4 { // password or confirm
                    sender.isSecureTextEntry = true
                }
                
                // x label
                let x = self.view.viewWithTag(sender.tag+10) as? UIImageView
                x?.isHidden = true
            }
        }
    }
    
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfFirstName {
            tfLastName.becomeFirstResponder()
        }else if textField == tfLastName {
            tfEmail.becomeFirstResponder()
        }else if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        }else if textField == tfPassword {
            tfConfirm.becomeFirstResponder()
        }else if textField == tfConfirm {
            self.view.endEditing(true)
            onSend(btnSend)
        }else{
            
        }
        return true
    }
}
