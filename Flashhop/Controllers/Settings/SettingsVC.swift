//
//  SettingsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/2.
//

import UIKit
import Alamofire
import KRProgressHUD
import FBSDKLoginKit

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onAccounts(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AccountSettingsVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onNotifications(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationSettingsVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onPaymentMethods(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onPrivacy(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacySettingsVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onLogout(_ sender: Any) {
        AlertVC.showMessage(parent:self.navigationController?.parent, text:"Sign out of my account", cancel: nil) {
            /*let url = "https://flashhop.com/api/logout"
            let params:Parameters = [:]
            let headers: HTTPHeaders = ["Authorization":"Bearer \(token)"]
            KRProgressHUD.show()
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .responseJSON { (response) in
                    KRProgressHUD.dismiss()
                    if let value = response.result.value as? [String: AnyObject] {
                        if let error = value["error"] {
                            print(error)
                        }else{
                            let storyboard = UIStoryboard(name: "Login", bundle: nil)
                            let vc = storyboard.instantiateInitialViewController()
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }
                    }
            }*/
            UserDefaults.standard.removeObject(forKey: "TOKEN")
            
            let loginManager = LoginManager()
            loginManager.logOut()
            
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    }
    @IBAction func onInactive(_ sender: Any) {
        AlertVC.showMessage(parent: self.navigationController?.parent, text:"Inactive my account for now", cancel: nil) {
            
        }
    }
}
