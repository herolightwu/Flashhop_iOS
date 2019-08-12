//
//  LikeFriendVC.swift
//  Flashhop
//
//  Created by MeiXiang Wu on 11/13/19.
//

import UIKit

class LikeFriendVC: UIViewController {
    
    public var other: FUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Popup
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTapLike(_ sender: Any) {
        APIManager.likeDisslike(receiver_id: "\(other.id)", islike: "1", result: { result in
            self.other.is_liked = 1
            self.dismiss(animated: true, completion: nil)
        }, error: { error in
        })
    }
    
    @IBAction func onTapDis(_ sender: Any) {
        APIManager.likeDisslike(receiver_id: "\(other.id)", islike: "-1", result: { result in
            self.other.is_liked = -1
            self.dismiss(animated: true, completion: nil)
        }, error: { error in
        })
    }
    @IBAction func onTapCancel(_ sender: Any) {
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
