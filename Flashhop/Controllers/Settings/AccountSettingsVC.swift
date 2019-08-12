//
//  AccountsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/2.
//

import UIKit

class AccountSettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onChangeEmail(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeEmailVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onChangePassword(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onChangeLang(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeLangsVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onChangeInterests(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeInterestsVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onChangeBirthday(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeBirthdayVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onChangeGender(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeGenderVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
