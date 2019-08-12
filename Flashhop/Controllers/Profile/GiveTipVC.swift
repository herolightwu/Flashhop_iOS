//
//  GiveTipVC.swift
//  Flashhop
//
//  Created by MeiXiang Wu on 11/11/19.
//

import UIKit

class GiveTipVC: UIViewController, UITextFieldDelegate {
    
    public var user : FUser!
    var btn_sel: Int = 0
    var amount : Int = 0

    @IBOutlet weak var avatarBtn: PhotoButton!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var oneBtn: RoundButton!
    @IBOutlet weak var twoBtn: RoundButton!
    @IBOutlet weak var fiveBtn: RoundButton!
    @IBOutlet weak var tenBtn: RoundButton!
    
    @IBOutlet weak var btnDone: RoundButton!
    @IBOutlet weak var customTxt: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btn_sel = 0
        customTxt.delegate = self
        avatarBtn.sd_setImage(with: URL(string: user.photo_url), for: .normal, completed: nil)
        refreshLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameLb.text = user.first_name
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil {
            return true
        } else{
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        btn_sel = 0
        refreshLayout()
    }
    
    func refreshLayout() {
        oneBtn.bgColor = .white
        oneBtn.layer.borderColor = UIColor(rgb: 0x29B52E).cgColor
        oneBtn.layer.borderWidth = 1
        oneBtn.setTitleColor(UIColor(rgb: 0x29B52E), for: .normal)
        twoBtn.bgColor = .white
        twoBtn.layer.borderColor = UIColor(rgb: 0x29B52E).cgColor
        twoBtn.layer.borderWidth = 1
        twoBtn.setTitleColor(UIColor(rgb: 0x29B52E), for: .normal)
        fiveBtn.bgColor = .white
        fiveBtn.layer.borderColor = UIColor(rgb: 0x29B52E).cgColor
        fiveBtn.layer.borderWidth = 1
        fiveBtn.setTitleColor(UIColor(rgb: 0x29B52E), for: .normal)
        tenBtn.bgColor = .white
        tenBtn.layer.borderColor = UIColor(rgb: 0x29B52E).cgColor
        tenBtn.layer.borderWidth = 1
        tenBtn.setTitleColor(UIColor(rgb: 0x29B52E), for: .normal)
        if btn_sel == 1 {
            oneBtn.bgColor = .green
            oneBtn.layer.borderColor = UIColor(rgb: 0x29B52E).cgColor
            oneBtn.layer.borderWidth = 1
            oneBtn.setTitleColor(UIColor.white, for: .normal)
        } else if btn_sel == 2 {
            twoBtn.bgColor = .green
            twoBtn.layer.borderColor = UIColor(rgb: 0x29B52E).cgColor
            twoBtn.layer.borderWidth = 1
            twoBtn.setTitleColor(UIColor.white, for: .normal)
        } else if btn_sel == 3 {
            fiveBtn.bgColor = .green
            fiveBtn.layer.borderColor = UIColor(rgb: 0x29B52E).cgColor
            fiveBtn.layer.borderWidth = 1
            fiveBtn.setTitleColor(UIColor.white, for: .normal)
        } else if btn_sel == 4 {
            tenBtn.bgColor = .green
            tenBtn.layer.borderColor = UIColor(rgb: 0x29B52E).cgColor
            tenBtn.layer.borderWidth = 1
            tenBtn.setTitleColor(UIColor.white, for: .normal)
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

    @IBAction func onTenTap(_ sender: Any) {
        customTxt.text = ""
        customTxt.endEditing(true)
        btn_sel = 4
        refreshLayout()
    }
    @IBAction func onFiveTap(_ sender: Any) {
        customTxt.text = ""
        customTxt.endEditing(true)
        btn_sel = 3
        refreshLayout()
    }
    @IBAction func onOneTap(_ sender: Any) {
        customTxt.text = ""
        customTxt.endEditing(true)
        btn_sel = 1
        refreshLayout()
    }
    @IBAction func onTwoTap(_ sender: Any) {
        customTxt.text = ""
        customTxt.endEditing(true)
        btn_sel = 2
        refreshLayout()
    }
    @IBAction func onDoneTap(_ sender: Any) {
        if btn_sel == 0 {
            let aaa = Int(customTxt.text ?? "0")
            amount = aaa ?? 0
        } else if btn_sel == 1 {
            amount = 1
        } else if btn_sel == 2 {
            amount = 2
        } else if btn_sel == 3 {
            amount = 5
        } else if btn_sel == 4 {
            amount = 10
        }
        if amount != 0 {
            showPaymentVC()
        }
    }
    func showPaymentVC() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentDetailVC") as! PaymentDetailVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
}

extension GiveTipVC: PaymentDetailDelegate {
    func onTapNext(card:Card) {
        let amount_str = String.init(format: "%.2f", amount)
        //let mCard = Card.getMyCard()
        APIManager.payTipWithStripeAPI(amount: amount_str, uid: "\(self.user.id)", card: card, result: { result in
            if result {
                self.navigationController?.popViewController(animated: true)
            }
        }, error: { error in
            print(error)
            self.btnDone.shake()
        })
    }
}
