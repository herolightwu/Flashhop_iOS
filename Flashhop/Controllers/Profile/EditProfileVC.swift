//
//  EditProfileVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/16.
//

import UIKit
import iOSDropDown
import Photos

class EditProfileVC: UIViewController {
    public var user:FUser!
    public var photos:[PHAsset] = []
    public var preview:((FUser,[PHAsset])->Void)?

    @IBOutlet weak var btnPhoto: PhotoButton!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var photosView: PhotosView!
    @IBOutlet weak var ddPersonalityType: DropDown!
    @IBOutlet weak var tvFunFacts: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ddPersonalityType.borderWidth = 1
        ddPersonalityType.borderColor = UIColor.gray
        ddPersonalityType.borderStyle = .line
        
        tvFunFacts.layer.borderWidth = 1
        tvFunFacts.layer.borderColor = UIColor.gray.cgColor
        
        ddPersonalityType.optionArray = [
            "Architect - INTJ",
            "Logician - INTP",
            "Commander - ENTJ",
            "Debater - ENTP",
            "Advocate - INFJ",
            "Mediator - INFP",
            "Protagonist - ENFJ",
            "Campaigner - ENFP",
            "Logistician - ISTJ",
            "Defender - ISFJ",
            "Executive - ESTJ",
            "Consul - ESFJ",
            "Virtuoso - ISTP",
            "Adventurer - ISFP",
            "Entrepreneur - ESTP",
            "Entertainer - ESFP"
        ]
        
        refresh()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onChoosePhotos(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChoosePhotosVC") as! ChoosePhotosVC
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.callback = { result in
            self.photosView.set_photos(photos: result)
            self.photos = result
        }
    }
    @IBAction func onWhatsThis(_ sender: UIButton) {
        let str = "We recommend you to take the test before selecting."
        showTip(text: str, parent: sender)
    }
    @IBAction func onSettings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onTips(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TipsVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func onPreview(_ sender: Any) {
        user.personality_type = ddPersonalityType.text ?? ""
        user.fun_facts = tvFunFacts.text
        self.navigationController?.popViewController(animated: true)
        preview?(user, photos)
    }
    
    func refresh() {
        // photo
        if user.photo_url != "" { btnPhoto.sd_setImage(with: URL(string: user.photo_url), for: .normal, completed: nil) }
        
        // name
        lbName.text = user.first_name + " " + user.second_name
        
        //images
        photosView.set_photos(urls: user.images)
        
        // personality
        ddPersonalityType.text = user.personality_type
        
        // fun facts
        tvFunFacts.text = user.fun_facts
    }
}

extension EditProfileVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 140
    }
}
