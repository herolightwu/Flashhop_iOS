//
//  ChangeInterestsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/3.
//

import UIKit

class ChangeInterestsVC: UIViewController {
    
    let user = me
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var btnSelectAll: ImageCheckBox!
    @IBOutlet weak var btnSave: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for subview in container.subviews {
            let button = subview as! ImageCheckBox
            let interest = Interest(rawValue: button.tag)!
            button.isChecked = user.interests[interest] ?? false
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onInterest(_ sender: ImageCheckBox) {
        let interest = Interest(rawValue: sender.tag)!
        user.interests[interest] = sender.isChecked
        btnSelectAll.isChecked = isSelectedAll()
    }
    @IBAction func onSelectAll(_ sender: ImageCheckBox) {
        for subview in container.subviews {
            let button = subview as! ImageCheckBox
            let interest = Interest(rawValue: button.tag)!
            user.interests[interest] = sender.isChecked
            button.isChecked = sender.isChecked
        }
    }
    func isSelectedAll() -> Bool {
        var bSelectedAll = true
        if me.interests.count != Interest.allCases.count { bSelectedAll = false }
        for (_ , flag) in me.interests {
            if flag == false {
                bSelectedAll = false
                break
            }
        }
        return bSelectedAll
    }
    @IBAction func onSave(_ sender: Any) {
        if user.interests.count == 0 {
            btnSave.shake()
        }else{
            APIManager.changeInterests(interests: user.interest_str(), result: { (value) in
                me.interests = self.user.interests
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                print(error)
            }
        }
    }
}
