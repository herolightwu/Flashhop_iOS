//
//  ChangeBirthdayVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/11.
//

import UIKit
import JMMaskTextField_Swift
import Alamofire

class ChangeBirthdayVC: UIViewController {

    @IBOutlet weak var tfBirthday: JMMaskTextField!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var lbStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tfBirthday.text = me.dob
        if me.dob_editable {
            lbStatus.isHidden = true
            btnSave.isHidden = false
        }else{
            tfBirthday.isEnabled = false
            lbStatus.isHidden = false
            btnSave.isHidden = true
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let last_updated_date = formatter.date(from: me.last_dob_updated_at) ?? Date()
            let new_date = Calendar.current.date(byAdding: .month, value: 6, to: last_updated_date) ?? Date()
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "MMMM dd yyyy"
            let str = formatter2.string(from: new_date)
            lbStatus.text = "You can make edits after \(str)"
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onSave(_ sender: Any) {
        let birthday = tfBirthday.text ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if dateFormatter.date(from: birthday) != nil {  // valid
            let params:Parameters = ["dob":birthday]
            APIManager.updateUserProfile(params: params, result: { (value) in
                me.dob = birthday
                me.dob_editable = false
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                me.last_dob_updated_at = formatter.string(from: Date())
                
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                print(error)
            }
        } else {
            btnSave.shake()
        }
    }
}
