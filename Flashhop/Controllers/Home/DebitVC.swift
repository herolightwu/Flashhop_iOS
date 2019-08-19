//
//  DebitVC.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/11/7.
//

import UIKit

class DebitVC: UIViewController {
    var mycard: Card!

    @IBOutlet weak var viewDialog: UIView!
    @IBOutlet weak var viewCardNumber: SettingTextField!
    @IBOutlet weak var viewExpiration: SettingTextField!
    @IBOutlet weak var viewCardholderName: SettingTextField!
    @IBOutlet weak var viewCVV: SettingTextField!
    @IBOutlet weak var viewStreetName: SettingTextField!
    @IBOutlet weak var viewCity: SettingTextField!
    @IBOutlet weak var viewProvince: SettingTextField!
    @IBOutlet weak var viewPostCode: SettingTextField!
    @IBOutlet weak var chkSave: ImageCheckBox!
    
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
        viewStreetName.textMain.delegate = self
        viewCity.textMain.delegate = self
        viewProvince.textMain.delegate = self
        viewPostCode.textMain.delegate = self
        
        viewCardNumber.textMain.keyboardType = .numberPad
        viewCardholderName.textMain.keyboardType = .default
        viewExpiration.textMain.keyboardType = .numberPad
        viewCVV.textMain.keyboardType = .numberPad
        viewStreetName.textMain.keyboardType = .default
        viewCity.textMain.keyboardType = .default
        viewProvince.textMain.keyboardType = .default
        viewPostCode.textMain.keyboardType = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mycard = Card.getMyCard()
        if mycard != nil {
            if mycard.card_number.count == 0 {
                return
            }
            viewCardNumber.textMain.text = mycard.card_number
            viewCardholderName.textMain.text = mycard.holder_name
            viewExpiration.textMain.text = mycard.exp_month + "/" + mycard.exp_year.suffix(2)
            viewCVV.textMain.text = mycard.card_cvc
            viewStreetName.textMain.text = mycard.address_line1
            viewCity.textMain.text = mycard.address_city
            viewProvince.textMain.text = mycard.address_state
            viewPostCode.textMain.text = mycard.address_postal_code
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
        /*if viewCVV.textMain.text?.count != 3 {
            viewCVV.setError()
            result = false
        }*/
        if viewStreetName.textMain.text == "" {
            viewStreetName.setErrorPlaceholder()
            result = false
        }
        if viewCity.textMain.text == "" {
            viewCity.setErrorPlaceholder()
            result = false
        }
        if viewProvince.textMain.text == "" {
            viewProvince.setErrorPlaceholder()
            result = false
        }
        if viewPostCode.textMain.text == "" {
            viewPostCode.setErrorPlaceholder()
            result = false
        }
        return result
    }
    
    
    @IBAction func onTapSave(_ sender: Any) {
        if checkValidFields() {
            mycard.card_number = viewCardNumber.textMain.text!
            mycard.holder_name = viewCardholderName.textMain.text!
            let date = viewExpiration.textMain.text?.split(separator: "/")
            mycard.exp_month = String(date![0])
            mycard.exp_year = "20" + String(date![1])
            mycard.card_cvc = viewCVV.textMain.text!
            mycard.address_line1 = viewStreetName.textMain.text!
            mycard.address_city = viewCity.textMain.text!
            mycard.address_state = viewProvince.textMain.text!
            mycard.address_postal_code = viewPostCode.textMain.text!
            
            if chkSave.isChecked {
                let start_ind = mycard.card_number.count - 4
                let end_ind = mycard.card_number.count
                let start = String.Index(utf16Offset: start_ind, in: mycard.card_number)
                let end = String.Index(utf16Offset: end_ind, in: mycard.card_number)
                mycard.last4 = String(mycard.card_number[start..<end])
                Card.saveMyCard(card: mycard)
            }
            
            APIManager.updateCustomAccount(user_id: "\(me.id)", card: mycard, result: { result in
                if result {
                    me.is_debit = 1
                }
            }, error: { error in
            })
        }
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension DebitVC: UITextFieldDelegate {
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
        if textField == viewStreetName.textMain {
            if updatedText == "" {
                viewStreetName.setErrorPlaceholder()
            } else {
                viewStreetName.setErrorPlaceholder(error: false)
            }
        }
        if textField == viewCity.textMain {
            if updatedText == "" {
                viewCity.setErrorPlaceholder()
            } else {
                viewCity.setErrorPlaceholder(error: false)
            }
        }
        if textField == viewProvince.textMain {
            if updatedText == "" {
                viewProvince.setErrorPlaceholder()
            } else {
                viewProvince.setErrorPlaceholder(error: false)
            }
        }
        if textField == viewPostCode.textMain {
            if updatedText == "" {
                viewPostCode.setErrorPlaceholder()
            } else {
                viewPostCode.setErrorPlaceholder(error: false)
            }
        }
        textField.text = updatedText
        return false
    }
}
