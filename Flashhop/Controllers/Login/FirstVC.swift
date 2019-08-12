//
//  FirstVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/9.
//

import UIKit
import FBSDKLoginKit
import Alamofire
import KRProgressHUD
import GoogleSignIn
import OneSignal

class FirstVC: UIViewController {

    @IBOutlet weak var btnFacebook: UIButton!
    var push_id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        checkToken()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onRegister(_ sender: Any) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onFacebook(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print(error)
            }else {
                APIManager.loginWithFacebook(self, push_id: self.push_id)
            }
        }
    }
    @IBAction func onGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    func checkToken() {
        push_id = OneSignal.getPermissionSubscriptionState()?.subscriptionStatus.userId ?? ""
        
        APIManager.checkToken(push_id: self.push_id, result: { (value) in
            let dic = value["data"] as! [String : AnyObject]
            me = FUser(dic: dic)
            APIManager.didAuth(self)
        }) { (error) in
            print(error)
            let code = error["code"] as! Int
            switch code {
            case 107:   // invaild token
                break;
            case 103:   // unverified email
                //let str = error["token"] as! String
                //APIManager.set_token(str)
                //current_user.email_verified = false
                //APIManager.didAuth(self)
                break;
            default:
                print("Invalid error code...")
            }
        }
    }
        
}

extension FirstVC: GIDSignInDelegate {
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
