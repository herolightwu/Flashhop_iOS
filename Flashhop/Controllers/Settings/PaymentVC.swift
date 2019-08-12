//
//  PaymentVC.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/11/3.
//

import UIKit
import TextFieldEffects

class PaymentVC: UIViewController {

    @IBOutlet weak var imgChecked: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var constTableHeight: NSLayoutConstraint!
    @IBOutlet weak var constScrollHeight: NSLayoutConstraint!
    @IBOutlet weak var viewCardNumber: SettingTextField!
    @IBOutlet weak var viewCardholderName: SettingTextField!
    @IBOutlet weak var viewExpiration: SettingTextField!
    @IBOutlet weak var viewCVV: SettingTextField!
    @IBOutlet weak var viewStreetName: SettingTextField!
    @IBOutlet weak var viewCity: SettingTextField!
    @IBOutlet weak var viewProvince: SettingTextField!
    @IBOutlet weak var viewPostCode: SettingTextField!
    
    var cards:[Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isHidden = false
        viewEdit.isHidden = true
        constTableHeight.constant = 0
        constScrollHeight.constant = 0
        
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
        
        loadData()
    }
    
    func loadData() {
        APIManager.getDebitCardData(user_id: me.id, callback: { cards in
            if cards.count > 0 {
                me.is_debit = 1
                self.tableView.reloadData()
                self.constTableHeight.constant = 50
                self.constScrollHeight.constant = 600
                
                if cards[0].last4 != "" {
                    self.viewCardholderName.textMain.text = cards[0].holder_name
                    self.viewExpiration.textMain.text = cards[0].exp_month + "/" + cards[0].exp_year.suffix(2)
                    self.viewStreetName.textMain.text = cards[0].address_line1
                    self.viewCity.textMain.text = cards[0].address_city
                    self.viewProvince.textMain.text = cards[0].address_state
                    self.viewPostCode.textMain.text = cards[0].address_postal_code
                    if cards[0].card_cvc == "123" {
                        self.imgChecked.isHidden = false
                    } else {
                        self.imgChecked.isHidden = true
                    }
                } else {
                    self.tableView.isHidden = true
                    self.viewEdit.isHidden = false
                    self.constTableHeight.constant = 0
                    self.constScrollHeight.constant = 550
                }
            } else {
                self.imgChecked.isHidden = true
                self.tableView.isHidden = true
                self.constTableHeight.constant = 0
                self.viewEdit.isHidden = false
                self.constScrollHeight.constant = 550
            }
        })
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
            let card = Card()
            card.card_number = viewCardNumber.textMain.text!
            card.holder_name = viewCardholderName.textMain.text!
            let date = viewExpiration.textMain.text?.split(separator: "/")
            card.exp_month = String(date![0])
            card.exp_year = "20" + String(date![1])
            card.card_cvc = viewCVV.textMain.text!
            card.address_line1 = viewStreetName.textMain.text!
            card.address_city = viewCity.textMain.text!
            card.address_state = viewProvince.textMain.text!
            card.address_postal_code = viewPostCode.textMain.text!
            
            Card.saveMyCard(card: card)
            
            APIManager.updateCustomAccount(user_id: "\(me.id)", card: card, result: { result in
                if result {
                    me.is_debit = 1
                    self.viewEdit.isHidden = true
                    self.tableView.isHidden = false
                    self.constTableHeight.constant = 0
                    self.constScrollHeight.constant = 100
                    self.loadData()
                }
            }, error: { error in
            })
        }
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onActionEdit(_ sender: UIButton) {
        self.viewCardholderName.textMain.text = cards[0].holder_name
        self.viewExpiration.textMain.text = cards[0].exp_month + "/" + cards[0].exp_year.suffix(2)
        self.viewStreetName.textMain.text = cards[0].address_line1
        self.viewCity.textMain.text = cards[0].address_city
        self.viewProvince.textMain.text = cards[0].address_state
        self.viewPostCode.textMain.text = cards[0].address_postal_code
        
        self.tableView.isHidden = true
        self.constTableHeight.constant = 0
        self.viewEdit.isHidden = false
        self.constScrollHeight.constant = 550
    }
}

extension PaymentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell")!
        let lblCardNumber: UILabel = cell.viewWithTag(10) as! UILabel
        let lblExpire: UILabel = cell.viewWithTag(20) as! UILabel
        let btnEdit: RoundButton = cell.viewWithTag(30) as! RoundButton
        
        lblCardNumber.text = "xxxx xxxx xxxx " + cards[indexPath.row].last4
        lblExpire.text = cards[indexPath.row].exp_month + "/" + cards[indexPath.row].exp_year.suffix(2)
        
        btnEdit.tag2 = indexPath.row
        btnEdit.addTarget(self, action:#selector(onActionEdit(_:)), for: .touchUpInside)
        
        return cell
    }
}

extension PaymentVC: UITextFieldDelegate {
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
