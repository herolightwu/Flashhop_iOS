//
//  ChangeGenderVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/11.
//

import UIKit
import Alamofire

class ChangeGenderVC: UIViewController {

    var gender = me.gender
    @IBOutlet weak var btnMale: ImageCheckBox!
    @IBOutlet weak var btnFemale: ImageCheckBox!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var lbStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnMale.isChecked = gender == .male
        btnFemale.isChecked = gender == .female
        
        if me.dob_editable {
            lbStatus.isHidden = true
            btnSave.isHidden = false
        }else{
            btnMale.isEnabled = false
            btnFemale.isEnabled = false
            lbStatus.isHidden = false
            btnSave.isHidden = true
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let last_updated_date = formatter.date(from: me.last_gender_updated_at) ?? Date()
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
    @IBAction func onGender(_ sender: ImageCheckBox) {
        if sender.tag == 0 { gender = .male; btnFemale.isChecked = false }
        if sender.tag == 1 { gender = .female; btnMale.isChecked = false }
    }
    @IBAction func onSave(_ sender: Any) {
        var str = ""
        if gender == .male { str = "male" }
        if gender == .female { str = "female" }
        let params:Parameters = ["gender":str]
        APIManager.updateUserProfile(params: params, result: { (value) in
            me.gender = self.gender
            me.gender_editable = false
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            me.last_gender_updated_at = formatter.string(from: Date())
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            print(error)
        }
    }
}
