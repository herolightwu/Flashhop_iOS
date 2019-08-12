//
//  ChooseBirthdayVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/12.
//

import UIKit
import JMMaskTextField_Swift

class ChooseBirthdayVC: UIViewController {

    @IBOutlet weak var tfBirthday: JMMaskTextField!
    @IBOutlet weak var btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func onPrev(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
/*    @IBAction func onPick(_ sender: UITextField) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        sender.inputView = picker
        picker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
    }
    @objc func dateChanged(sender : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        _tfBirthday.text = dateFormatter.string(from: sender.date)
    }
 */
    @IBAction func onNext(_ sender: Any) {
        let birthday = tfBirthday.text ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if dateFormatter.date(from: birthday) != nil {  // valid
            me.dob = birthday
            let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChooseLngVC")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            btnNext.shake()
        }
    }
}
