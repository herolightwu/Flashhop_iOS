//
//  ChangeLangsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/3.
//

import UIKit

class ChangeLangsVC: UIViewController {

    let user = me
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for lang in user.langs {
            var tag = 0
            switch lang {
            case .en: tag = 0; break
            case .fr: tag = 1; break
            case .cn: tag = 2; break
            case .es: tag = 3; break
            case .ja: tag = 4; break
            case .ko: tag = 5; break
            case .ar: tag = 6; break
            case .ru: tag = 7; break
            case .de: tag = 8; break
            case .po: tag = 9; break
            }
            let button = self.view.viewWithTag(100)!.viewWithTag(tag) as? ColorCheckBox
            button?.isChecked = true
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onClickedLang(_ sender: ColorCheckBox) {
        var lang:Language!
        switch sender.tag {
        case 0: lang = .en; break
        case 1: lang = .fr; break
        case 2: lang = .cn; break
        case 3: lang = .es; break
        case 4: lang = .ja; break
        case 5: lang = .ko; break
        case 6: lang = .ar; break
        case 7: lang = .ru; break
        case 8: lang = .de; break
        case 9: lang = .po; break
        default:print("invalid language button tag"); break
        }
        if sender.isChecked { user.langs.append(lang) }
        else if let index = user.langs.firstIndex(of: lang) { user.langs.remove(at: index) }
    }
    @IBAction func onSave(_ sender: Any) {
        APIManager.changeLangs(langs: user.langs_string(), result: { (value) in
            me.langs = self.user.langs
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            print(error)
        }
    }
}
