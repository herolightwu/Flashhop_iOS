//
//  PaymentDetailVC.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/11/7.
//

import UIKit

protocol PaymentDetailDelegate {
    func onTapNext(card:Card)
}

class PaymentDetailVC: UIViewController {

    @IBOutlet weak var viewDialog: UIView!
    @IBOutlet weak var viewCardNumber: SettingTextField!
    @IBOutlet weak var viewCVV: SettingTextField!
    @IBOutlet weak var viewExpiration: SettingTextField!
    @IBOutlet weak var viewCardholderName: SettingTextField!
    @IBOutlet weak var chkSave: ImageCheckBox!
    @IBOutlet weak var btnNext: RoundButton!
    
    var delegate: PaymentDetailDelegate!
    var myCard:Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Popup
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        viewDialog.layer.cornerRadius = 10
        viewDialog.clipsToBounds = true
       
        viewCardNumber.textMain.delegate = self
        viewCardholderName.textMain.delegate = self
        viewExpiration.textMain.delegate = self
        viewCVV.textMain.delegate = self
       
        viewCardNumber.textMain.keyboardType = .numberPad
        viewCardholderName.textMain.keyboardType = .default
        viewExpiration.textMain.keyboardType = .numberPad
        viewCVV.textMain.keyboardType = .numberPad
        
        myCard = Card.getMyCard()
        if myCard.last4 != "" {
            viewCardNumber.textMain.text = myCard.card_number
            viewCardholderName.textMain.text = myCard.holder_name
            viewExpiration.textMain.text = myCard.exp_month + "/" + myCard.exp_year.suffix(2)
            viewCVV.textMain.text = myCard.card_cvc
        }
    }
    
    func checkValidFields()->Bool {
        var result = true
        if viewCardNumber.textMain.text?.count != 19 {
            viewCardNumber.setError()
            result = false
        }
        if viewCardholderName.textMain.text == "" {
            viewCardholderName.setError()
            result = false
        }
        if viewExpiration.textMain.text?.count == 5 {
            let date = viewExpiration.textMain.text?.split(separator: "/")
            let month = Int(date![0])!
            let year = Int(date![1])!
            if month <= 0 || month > 12 || year < 18 {
                viewExpiration.setError()
                result = false
            }
        } else {
            viewExpiration.setError()
            result = false
        }
        if viewCVV.textMain.text?.count != 3 {
            viewCVV.setError()
            result = false
        }
        return result
    }
    
    @IBAction func onTapNext(_ sender: Any) {
        if checkValidFields() {
            myCard.card_number = viewCardNumber.textMain.text!
            myCard.holder_name = viewCardholderName.textMain.text!
            let date = viewExpiration.textMain.text?.split(separator: "/")
            myCard.exp_month = String(date![0])
            myCard.exp_year = "20" + String(date![1])
            myCard.card_cvc = viewCVV.textMain.text!
            myCard.last4 = String(myCard.card_number.suffix(4))
            if chkSave.isChecked {
                Card.saveMyCard(card: myCard)
            }
            dismiss(animated: true, completion: nil)
            if delegate != nil {
                delegate.onTapNext(card: self.myCard)
                //dismiss(animated: true, completion: nil)
            }
        } else{
            btnNext.shake()
        }
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PaymentDetailVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var updatedText : String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
        if textField == viewCardNumber.textMain {
            if updatedText.count > 19 {
                return false
            }
            if updatedText == "" {
                viewCardNumber.setError()
            } else {
                viewCardNumber.setError(error: false)
            }
            if updatedText.last == " " {
                updatedText.removeLast()
                updatedText.removeLast()
            } else if updatedText.count < textField.text!.count && textField.text?.last == " " {
                updatedText.removeLast()
            } else {
                if updatedText.count == 4 || updatedText.count == 9 || updatedText.count == 14 {
                    updatedText = updatedText + " "
                }
            }
        }
        if textField == viewCardholderName.textMain {
            if updatedText == "" {
                viewCardholderName.setError()
            } else {
                viewCardholderName.setError(error: false)
            }
        }
        if textField == viewExpiration.textMain {
            if updatedText.count > 5 {
                return false
            }
            if updatedText == "" {
                viewExpiration.setError()
            } else {
                viewExpiration.setError(error: false)
            }
            if updatedText.last == "/" {
                updatedText.removeLast()
                updatedText.removeLast()
            } else if updatedText.count < textField.text!.count && textField.text?.last == "/" {
                updatedText.removeLast()
            } else {
                if updatedText.count == 2 {
                    updatedText = updatedText + "/"
                }
            }
        }
        if textField == viewCVV.textMain {
            if updatedText.count > 3 {
                return false
            }
            if updatedText == "" {
                viewCVV.setError()
            } else {
                viewCVV.setError(error: false)
            }
        }
        textField.text = updatedText
        return false
    }
}
