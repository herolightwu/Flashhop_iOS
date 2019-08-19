//
//  ChooseLngVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/12.
//

import UIKit

class ChooseLngVC: UIViewController {

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
    @IBAction func onNext(_ sender: Any) {
        me.langs = []
        for i in 0..<10 {
            let button = self.view.viewWithTag(100)!.viewWithTag(i) as! ColorCheckBox
            if button.isChecked {
                switch i {
                case 0: me.langs.append(.en); break
                case 1: me.langs.append(.fr); break
                case 2: me.langs.append(.cn); break
                case 3: me.langs.append(.es); break
                case 4: me.langs.append(.ja); break
                case 5: me.langs.append(.ko); break
                case 6: me.langs.append(.ar); break
                case 7: me.langs.append(.ru); break
                case 8: me.langs.append(.de); break
                case 9: me.langs.append(.po); break
                default: print("Invalid language"); break
                }
            }
        }
        
        if me.langs.count == 0 {
            btnNext.shake()
        }else{
            let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChooseInterestVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
