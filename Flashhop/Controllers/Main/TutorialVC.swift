//
//  TutorialVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/27.
//

import UIKit

class TutorialVC: UIViewController {

    @IBOutlet weak var ivBg: UIImageView!
    @IBOutlet weak var btnSkip: UIButton!
    
    var iBg:[UIImage] = []
    var ivTuto:[UIImageView] = []
    
    let nCount = 6
    var nIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let v0 = self.view.viewWithTag(10) as! UIImageView
        ivTuto.append(v0)
        iBg.append(UIImage(named: "tutorial_pin_bg")!)
        
        let v1 = self.view.viewWithTag(11) as! UIImageView
        ivTuto.append(v1)
        iBg.append(UIImage(named: "tutorial_new_event_bg")!)
        
        let v2 = self.view.viewWithTag(12) as! UIImageView
        ivTuto.append(v2)
        iBg.append(UIImage(named: "tutorial_new_event_bg")!)
        
        let v3 = self.view.viewWithTag(13) as! UIImageView
        ivTuto.append(v3)
        iBg.append(UIImage(named: "tutorial_profile_bg")!)
        
        let v4 = self.view.viewWithTag(14) as! UIImageView
        ivTuto.append(v4)
        iBg.append(UIImage(named: "tutorial_full_bg")!)
        
        let v5 = self.view.viewWithTag(15) as! UIImageView
        ivTuto.append(v5)
        iBg.append(UIImage(named: "tutorial_full_bg")!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onSkip(_ sender: UIButton) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func onClickBg(_ sender: Any) {
        ivTuto[nIndex].isHidden = true
        if nIndex == 0 { btnSkip.isHidden = true }
        
        nIndex += 1
        if nIndex == nCount {
            onSkip(btnSkip)
            return
        }
        
        ivTuto[nIndex].isHidden = false
        ivBg.image = iBg[nIndex]
    }
}
