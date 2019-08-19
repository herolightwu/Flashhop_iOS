//
//  ChangeEmailVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/2.
//

import UIKit

class ChangeEmailVC: UIViewController {
    
    let valid_color = UIColor(rgb: 0x363C5A)
    enum Status {
        case Send, Save
    }
    private var status:Status = .Send
    
    @IBOutlet weak var vEmail: UIView!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var vCode: UIView!
    @IBOutlet weak var lbCode: UILabel!
    @IBOutlet weak var tfCode: UITextField!
    
    @IBOutlet weak var btnSend: RoundButton!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var lbStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tfEmail.layer.borderWidth = 1
        tfEmail.layer.cornerRadius = 2
        tfEmail.layer.borderColor = valid_color.cgColor
        tfEmail.setPaddingPoints(8)
        
        tfCode.layer.borderWidth = 1
        tfCode.layer.cornerRadius = 2
        tfCode.layer.borderColor = valid_color.cgColor
        tfCode.setPaddingPoints(8)
        
        refresh()
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func refresh() {
        switch status {
        case .Send:
            vCode.isHidden = true
            btnSend.isHidden = false
            btnSave.isHidden = true
            lbStatus.isHidden = true
            break
        case .Save:
            vCode.isHidden = false
            btnSend.isHidden = true
            btnSave.isHidden = false
            lbStatus.isHidden = true
            break
        }
    }
    @IBAction func onSend(_ sender: Any) {
        let email = tfEmail.text ?? ""
        if isValidEmail(email) {
            APIManager.changeEmailRequest(email: email, result: { (result) in
                self.status = .Save
                self.refresh()
            }) { (error) in
                print(error)
                let code = error["code"] as! Int
                switch code {
                case 105:   // code
                    self.lbStatus.text = "Email exists already."
                    self.lbStatus.isHidden = false
                    break;
                default:
                    print("Invalid error code...")
                }
            }
        }else{
            lbEmail.textColor = UIColor.red
            tfEmail.layer.borderColor = UIColor.red.cgColor
        }
    }
    @IBAction func onSave(_ sender: Any) {
        let email = tfEmail.text ?? ""
        let code = tfCode.text ?? ""
        if isValidEmail(email) && code.count == 6 {
            APIManager.changeEmail(email: email, code: code, result: { (result) in
                me.email = email
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                print(error)
                let code = error["code"] as! Int
                switch code {
                case 109:   // code
                    self.lbCode.textColor = UIColor.red
                    self.tfCode.layer.borderColor = UIColor.red.cgColor
                    self.lbStatus.isHidden = false
                    self.lbStatus.text = "New Email address have been saved."
                    break;
                default:
                    print("Invalid error code...")
                }
            }
        }
    }
    @IBAction func onEditingDidBegin(_ sender: UITextField) {
        let color = UIColor(cgColor: sender.layer.borderColor!)
        if color.isEqual(UIColor.red) {
            if sender == tfEmail {
                lbEmail.textColor = valid_color
                tfEmail.layer.borderColor = valid_color.cgColor
            }else if sender == tfCode {
                lbCode.textColor = valid_color
                tfCode.layer.borderColor = valid_color.cgColor
            }
        }
        lbStatus.isHidden = true
    }
}
