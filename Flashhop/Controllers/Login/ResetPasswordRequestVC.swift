//
//  ResetPasswordRequestVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/20.
//

import UIKit
import Alamofire
import KRProgressHUD

class ResetPasswordRequestVC: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var ivEmail: UIImageView!
    @IBOutlet weak var btnReset: UIButton!
    
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
    @IBAction func onReset(_ sender: UIButton) {
        self.view.endEditing(true)
        
        var email = tfEmail.text
        
        if ivEmail.isHidden == false { email = "" }
        
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
        
        if bInvalid {
            return
        }
        
        let url = "https://flashhop.com/api/password/request_reset"
        let params:Parameters = ["email":email!]
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
                        case 111:   // invaild email
                            self.tfEmail.text = "Email invalid"
                            self.tfEmail.textColor = UIColor.error
                            self.ivEmail.isHidden = false
                            break;
                        default:
                            print("Invalid error code...")
                        }
                    }else{
                        if let data = value["data"] {
                            print(data)
                            
                            let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
                            vc.strEmail = email!
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
        }
    }
    @IBAction func onEditingDidBegin(_ sender: UITextField) {
        if let color = sender.textColor {
            if color.isEqual(UIColor.error) {
                sender.text = ""
                sender.textColor = .white
                
                // x label
                let x = self.view.viewWithTag(sender.tag+10) as? UIImageView
                x?.isHidden = true
            }
        }
    }
}

extension ResetPasswordRequestVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            self.view.endEditing(true)
            onReset(btnReset)
        }
        return true
    }
}
