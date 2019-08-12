//
//  ResetPasswordVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/20.
//

import UIKit
import Alamofire
import KRProgressHUD

class ResetPasswordVC: UIViewController {

    public var strEmail = ""
    //public var _strToken = ""
    
    @IBOutlet weak var tfCode: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirm: UITextField!
    
    @IBOutlet weak var ivCode: UIImageView!
    @IBOutlet weak var ivPassword: UIImageView!
    @IBOutlet weak var ivConfirm: UIImageView!
    
    @IBOutlet weak var btnReset: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBAction func onReset(_ sender: UIButton) {
        self.view.endEditing(true)
        
        var code = tfCode.text
        var pw = tfPassword.text
        var confirm = tfConfirm.text
        
        // ignore warning string !!!
        if ivCode.isHidden == false { code = "" }
        if ivPassword.isHidden == false { pw = "" }
        if ivConfirm.isHidden == false { confirm = "" }
        
        var bInvalid = false
        if code == "" {
            tfCode.text = "Code is empty"
            tfCode.textColor = UIColor.error
            ivCode.isHidden = false
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
        if confirm != pw {
            tfConfirm.text = "Password is not matching"
            tfConfirm.isSecureTextEntry = false
            tfConfirm.textColor = UIColor.error
            ivConfirm.isHidden = false
            bInvalid = true
        }
        
        if bInvalid {
            return
        }
        
        let url = "https://flashhop.com/api/password/resetpassword"
        let params:Parameters = ["email":strEmail, "token":code!, "password":pw!]
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let error = value["error"] {
                        print(error["msg"]!!)
                        let code = error["code"] as! Int
                        switch code {
                        case 113:   // invaild code
                            self.tfCode.text = "Code invalid"
                            self.tfCode.textColor = UIColor.error
                            self.ivCode.isHidden = false
                            break;
                        default:
                            print("Invalid error code...")
                        }
                    }else{
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                    }
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

extension ResetPasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfCode {
            tfPassword.becomeFirstResponder()
        }else if textField == tfPassword {
            tfConfirm.becomeFirstResponder()
        }else if textField == tfConfirm {
            self.view.endEditing(true)
            onReset(btnReset)
        }
        return true
    }
}
