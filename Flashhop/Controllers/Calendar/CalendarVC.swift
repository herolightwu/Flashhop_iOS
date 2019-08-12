//
//  CalendarVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/8.
//

import UIKit

class CalendarVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func onEvents(_ sender: Any) {
    }
    @IBAction func onPin(_ sender: Any) {
        let mainVC = UIApplication.shared.delegate!.window!!.rootViewController as! MainVC
        mainVC.selectedIndex = 0
        let navigationController = mainVC.selectedViewController as! UINavigationController
        let vc = navigationController.viewControllers.first as! HomeVC
        vc.onPinMyLocation(vc.btnPinMyLocation)
    }
    @IBAction func onJoin(_ sender: Any) {
        let mainVC = UIApplication.shared.delegate!.window!!.rootViewController as! MainVC
        mainVC.selectedIndex = 0
    }
    @IBAction func onHost(_ sender: Any) {
        let mainVC = UIApplication.shared.delegate!.window!!.rootViewController as! MainVC
        mainVC.selectedIndex = 0
        let navigationController = mainVC.selectedViewController as! UINavigationController
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditEventVC")
        navigationController.pushViewController(vc, animated: true)
    }
}
