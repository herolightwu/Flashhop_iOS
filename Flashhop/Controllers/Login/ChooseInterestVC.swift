//
//  ChooseInterestVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/12.
//

import UIKit

class ChooseInterestVC: UIViewController {
    
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var btnSelectAll: ImageCheckBox!
    @IBOutlet weak var btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func onPrev(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onInterest(_ sender: ImageCheckBox) {
        let interest = Interest(rawValue: sender.tag)!
        me.interests[interest] = sender.isChecked
        btnSelectAll.isChecked = isSelectedAll()
    }
    @IBAction func onSelectAll(_ sender: ImageCheckBox) {
        for subview in container.subviews {
            let button = subview as! ImageCheckBox
            let interest = Interest(rawValue: button.tag)!
            me.interests[interest] = sender.isChecked
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
    @IBAction func onNext(_ sender: Any) {        
        if me.interests.count == 0 {
            lbDesc.text = "Please at least select one"
            btnNext.shake()
        }else{
            let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChoosePhotoVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
