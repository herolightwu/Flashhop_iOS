//
//  PayConfirmVC.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/11/9.
//

import UIKit

protocol PayConfirmDelegate {
    func onTapLater()
    func onTapContinue()
}

class PayConfirmVC: UIViewController {

    @IBOutlet weak var lblAmount: UILabel!
    
    var event: Event!
    var delegate: PayConfirmDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Popup
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let sPrice: String = String.init(format: "$%.2f", self.event?.price ?? 0)
        lblAmount.text = sPrice + " \(event.currency.str)"
    }
    
    @IBAction func onTapContinue(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        if delegate != nil {
            delegate.onTapContinue()
        }
    }
    
    @IBAction func onTapLater(_ sender: Any) {
        if delegate != nil {
            delegate.onTapLater()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
