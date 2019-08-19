//
//  ChooseGenderVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/12.
//

import UIKit

class ChooseGenderVC: UIViewController {    
    private var gender:Gender = .co
    
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
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
    @IBAction func onMale(_ sender: Any) {
        gender = .male
        btnMale.setImage(UIImage(named: "male_sel"), for: .normal)
        btnFemale.setImage(UIImage(named: "female"), for: .normal)
    }
    @IBAction func onFemale(_ sender: Any) {
        gender = .female
        btnMale.setImage(UIImage(named: "male"), for: .normal)
        btnFemale.setImage(UIImage(named: "female_sel"), for: .normal)
    }
    @IBAction func onNext(_ sender: Any) {
        if gender == .co {
            btnNext.shake()
            return
        }else{
            me.gender = gender
            
            let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChooseBirthdayVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
