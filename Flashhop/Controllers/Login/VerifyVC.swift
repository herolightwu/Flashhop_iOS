//
//  VerifyVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/10.
//

import UIKit
import Alamofire
import KRProgressHUD
import FasterVerificationCode

class VerifyVC: UIViewController {
    private var _strCode = ""
    
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var vCode: VerificationCodeView!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var lbResent: UILabel!
    @IBOutlet weak var btnVerify: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lbDesc.text = "Please enter the 6 digit number that we sent to \(me.email)"
        
        vCode.setLabelNumber(6)
        vCode.delegate = self
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
    @IBAction func onVerify(_ sender: Any) {
        if _strCode.count != 6 {
            btnVerify.shake()
            return
        }
        APIManager.verifyEmail(code: _strCode, result: { (value) in
            let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WelcomeVC")
            self.navigationController?.setViewControllers([vc], animated: false)
        }) { (error) in
            print(error)
            //let code = error["code"] as! Int
            self.lbDesc.text = "We could not verify your code."
        }
    }
    @IBAction func onResend(_ sender: Any) {
        APIManager.sendVerifyCode(result: { (value) in
            self.lbDesc.text = "Please enter the 6 digit number that we sent to \(me.email)"
            self.btnResend.isHidden = true
            self.lbResent.isHidden = false
        }) { (error) in
            print(error)
            //let code = error["code"] as! Int
            self.lbDesc.text = "We could not verify your code."
        }
    }
}

extension VerifyVC: VerificationCodeViewDelegate {
    func verificationCodeInserted(_ text: String, isComplete: Bool) {
        _strCode = text
    }
}
