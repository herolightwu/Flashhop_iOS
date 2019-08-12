//
//  SuperLikeVC.swift
//  Flashhop
//
//  Created by MeiXiang Wu on 11/13/19.
//

import UIKit

class SuperLikeVC: UIViewController {
    
    public var what_id: String!
    public var username: String!
    public var avater_url: String!

    @IBOutlet weak var photoBtn: PhotoButton!
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var hellnoBtn: RoundButton!
    @IBOutlet weak var notyetBtn: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Popup
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // Do any additional setup after loading the view.
        hellnoBtn.layer.borderColor = UIColor.gray.cgColor
        hellnoBtn.layer.borderWidth = 1
        notyetBtn.layer.borderColor = UIColor.gray.cgColor
        notyetBtn.layer.borderWidth = 1
        
        descLb.text = username + " super liked you."
        photoBtn.sd_setImage(with: URL(fileURLWithPath: avater_url), for: .normal, completed: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    

    @IBAction func onTapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onTapMetoo(_ sender: Any) {
        APIManager.responseSuperLike(whatsup_id: what_id, reply: "me_too", result: { result in
            self.dismiss(animated: true, completion: nil)
        }, error: { error in
        })
    }
    @IBAction func onTapHellno(_ sender: Any) {
        APIManager.responseSuperLike(whatsup_id: what_id, reply: "hell_no", result: { result in
            self.dismiss(animated: true, completion: nil)
        }, error: { error in
        })
    }
    @IBAction func onTapNotyet(_ sender: Any) {
        APIManager.responseSuperLike(whatsup_id: what_id, reply: "not_yet", result: { result in
            self.dismiss(animated: true, completion: nil)
        }, error: { error in
        })
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
