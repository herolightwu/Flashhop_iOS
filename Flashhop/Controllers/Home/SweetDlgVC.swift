//
//  SweetDlgVC.swift
//  Flashhop
//
//  Created by MeiXiang Wu on 11/13/19.
//

import UIKit

class SweetDlgVC: UIViewController {
    
    public var username: String!

    @IBOutlet weak var descLb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Popup
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // Do any additional setup after loading the view.
        let str = String.init(format: "Sweet!\n%@ super likes you too.", username)
        descLb.text = str
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
