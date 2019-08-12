//
//  SuperDissVC.swift
//  Flashhop
//
//  Created by MeiXiang Wu on 11/13/19.
//

import UIKit

class SuperDissVC: UIViewController {
    
    public var what_id: String!
    public var username: String!
    public var avater_url: String!

    @IBOutlet weak var photoBtn: PhotoButton!
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var whatBtn: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Popup
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // Do any additional setup after loading the view.
        whatBtn.layer.borderWidth = 1
        whatBtn.layer.borderColor = UIColor.gray.cgColor
        
        descLb.text = username + " super dissed you."
        photoBtn.sd_setImage(with: URL(fileURLWithPath: avater_url), for: .normal, completed: nil)
    }
    
    @IBAction func onTapThrow(_ sender: Any) {
        APIManager.responseSuperDiss(whatsup_id: what_id, reply: "throw_back", result: { result in
            self.dismiss(animated: true, completion: nil)
        }, error: { error in
        })
    }
    
    @IBAction func onTapWhatever(_ sender: Any) {
        APIManager.responseSuperDiss(whatsup_id: what_id, reply: "whatever", result: { result in
            self.dismiss(animated: true, completion: nil)
        }, error: { error in
        })
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
