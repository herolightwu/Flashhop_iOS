//
//  PhotoViewVC.swift
//  Flashhop
//
//  Created by MeiXiang Wu on 11/11/19.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import KRProgressHUD


class PhotoViewVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    
    public var img_url: String!
    public var username: String!
    public var eTitle: String!
    public var eDesc: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imgView.sd_setImage(with: URL(string: img_url), completed: nil)
        titleLb.text = "Posted by " + username
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onBackTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDownloadTap(_ sender: Any) {
        KRProgressHUD.show()
        let storageRef = Storage.storage().reference(forURL: img_url)
        storageRef.downloadURL(completion: { (url, error) in
            let data = NSData(contentsOf: url!)
            let image = UIImage(data:data! as Data)
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            KRProgressHUD.dismiss()
        })
    }
    @IBAction func onShareTap(_ sender: Any) {
        let title = eTitle as AnyObject
        let desc = eDesc as AnyObject
        let image = imgView.image as AnyObject
        let sharedObjects:[AnyObject] = [title, image, desc]
        let vc = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.navigationController?.parent?.view
        
        vc.excludedActivityTypes = []
        self.navigationController?.parent?.present(vc, animated: true, completion: nil)
    }
}
