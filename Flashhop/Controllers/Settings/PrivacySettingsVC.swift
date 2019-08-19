//
//  PrivacySettingsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/2.
//

import UIKit

class PrivacySettingsVC: UIViewController {

    @IBOutlet weak var ivHideAge: UIImageView!
    @IBOutlet weak var ivHideLocation: UIImageView!
    
    var bHideAge = me.hide_my_age
    var bHideLocation = me.hide_my_location
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }
    func refresh() {
        let on = UIImage(named: "switch_on")
        let off = UIImage(named: "switch_off")
        if bHideAge { ivHideAge.image = on } else { ivHideAge.image = off }
        if bHideLocation { ivHideLocation.image = on } else { ivHideLocation.image = off }
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onHideAge(_ sender: Any) {
        bHideAge = !bHideAge
        refresh()
    }
    @IBAction func onHideLocation(_ sender: Any) {
        bHideLocation = !bHideLocation
        refresh()
    }
    @IBAction func onSave(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        APIManager.changePrivacy(bHideAge: bHideAge, bHideLocation: bHideLocation, result: { (value) in
            me = FUser(dic: value["data"] as! [String : AnyObject])
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            print(error)
        }
    }
}
