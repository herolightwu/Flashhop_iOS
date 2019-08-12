//
//  PhotoPreviewVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/24.
//

import UIKit
import Photos
import KRProgressHUD
import Alamofire

class PhotoPreviewVC: UIViewController {

    public var photo:PHAsset!
    @IBOutlet weak var btnPhoto: PhotoButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnPhoto.setImage(getImage(asset: photo), for: .normal)
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
    @IBAction func onEdit(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onNext(_ sender: Any) {
        APIManager.registerUserProfile(photo: self.photo, result: { (value) in
            me = FUser(dic: value["data"] as! [String : AnyObject])
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TutorialVC")
            self.present(vc, animated: true, completion: nil)
        }) { (error) in
            print(error)
        }
    }
}
