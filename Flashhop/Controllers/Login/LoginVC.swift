//
//  LoginVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/10.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import OneSignal
import GoogleSignIn

class LoginVC: UIViewController {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var lbWelcome: UILabel!
    
    @IBOutlet weak var ivEmail: UIImageView!
    @IBOutlet weak var ivPassword: UIImageView!
    @IBOutlet weak var btnLogin: UIButton!
    
    var push_id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self

        push_id = OneSignal.getPermissionSubscriptionState()?.subscriptionStatus.userId ?? ""
        if me.email != "" {
            lbWelcome.text = "You already have an account,\nWelcome back!"
            tfEmail.text = me.email
        }
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
    
    @IBAction func onForgot(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ResetPasswordRequestVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onFacebook(_ sender: Any) {
        if AccessToken.current == nil {
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
                if let error = error {
                    print(error)
                }else {
                    APIManager.loginWithFacebook(self, push_id: self.push_id)
                }
            }
        }else{
            APIManager.loginWithFacebook(self, push_id: self.push_id)
        }
    }
    
    @IBAction func onGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        
        var email = tfEmail.text
        var pw = tfPassword.text
        
        // ignore warning string
        if ivEmail.isHidden == false { email = "" }
        if ivPassword.isHidden == false { pw = "" }
        
        var bInvalid = false
        if let email = email {
            if !isValidEmail(email) {
                tfEmail.text = "Email invalid"
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
        
        if bInvalid == true { return }
        
        APIManager.login(email: email!, pw: pw!, push_id: self.push_id, result: { (value) in
            let str = value["token"] as! String
            APIManager.set_token(str)
            me = FUser(dic: value["user"] as! [String : AnyObject])            
            APIManager.didAuth(self)
        }) { (error) in
            let code = error["code"] as! Int
            switch code {
            case 101:   // invaild email
                self.tfEmail.text = "Email invalid"
                self.tfEmail.textColor = UIColor.error
                self.ivEmail.isHidden = false
                break;
            case 102:   // wrong password
                self.tfPassword.text = "Wrong password"
                self.tfPassword.isSecureTextEntry = false
                self.tfPassword.textColor = UIColor.error
                self.ivPassword.isHidden = false
                break;
            case 103:   // unverified email
                let str = error["token"] as! String
                APIManager.set_token(str)
                me.email_verified = false
                APIManager.didAuth(self)
                break;
            default:
                print("Invalid error code...")
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

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        }else if textField == tfPassword {
            self.view.endEditing(true)
            onLogin(btnLogin)
        }
        return true
    }
}

extension LoginVC: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
        } else {
            //let givenName = user.profile.givenName!
            //let familyName = user.profile.familyName!
            //let email = user.profile.email!
            //let photo = user.profile.hasImage ? user.profile.imageURL(withDimension: 100)?.absoluteString : ""
            APIManager.loginWithGoogle(user, push_id: self.push_id, self)
        }
    }
}
