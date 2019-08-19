//
//  CardDetailVC.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/11/9.
//

import UIKit

protocol CardDetailDelegate {
    func onTapPay()
}

class CardDetailVC: UIViewController {
    
    @IBOutlet weak var lblMon: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblWeekday: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var photoImg: UIImageView!
    @IBOutlet weak var viewCardNumber: SettingTextField!
    @IBOutlet weak var viewCardholder: SettingTextField!
    @IBOutlet weak var viewExpiration: SettingTextField!
    @IBOutlet weak var viewCVV: SettingTextField!
    @IBOutlet weak var chkSave: ImageCheckBox!
    @IBOutlet weak var btnPay: RoundButton!
   
    
    var event: Event!
    var delegate: CardDetailDelegate!
    public var myCard: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Popup
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        viewCardNumber.textMain.isEnabled = false
        viewCardholder.textMain.isEnabled = false
        viewExpiration.textMain.isEnabled = false
        viewCVV.textMain.isEnabled = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        lblMon.text = formatter.string(from: event.time())
        formatter.dateFormat = "dd"
        lblDay.text = formatter.string(from: event.time())
        formatter.dateFormat = "E"
        lblWeekday.text = formatter.string(from: event.time())
        
        // Title
        lblTitle.text = event.title
        
        // time
        lblTime.text = event.start_end()
        
        //myCard = Card.getMyCard()
        if myCard.last4 != "" {
            viewCardNumber.textMain.text = "xxxx xxxx xxxx " + myCard.last4
            viewCardholder.textMain.text = myCard.holder_name
            viewExpiration.textMain.text = myCard.exp_month + "/" + myCard.exp_year.suffix(2)
            viewCVV.textMain.text = myCard.card_cvc
        }
        
        lblAmount.text = "$\(event.price) \(event.currency.str)"
        if event.cover_photo == "" { photoImg.image = event.category.cover_image }
        else { photoImg.sd_setImage(with: URL(string: event.cover_photo), completed: nil) }
    }
    
    @IBAction func onTapNext(_ sender: Any) {
        APIManager.payWithStripeAPI(event: event, card: myCard, result: { result in
            //if self.chkSave.isChecked {
            //    Card.saveMyCard(card: self.myCard)
            //}
            if result {
                if self.delegate != nil {
                    self.delegate.onTapPay()
                }
                self.dismiss(animated: true, completion: nil)
            }
        }, error: { error in
            print(error)
            self.btnPay.shake()
        })
    }
    
    @IBAction func onTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
