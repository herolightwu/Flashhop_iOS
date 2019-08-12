//
//  ReportVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/8.
//

import UIKit
import iOSDropDown

class ReportVC: UIViewController {

    var report_id:Int!
    
    @IBOutlet weak var ddCategory: DropDown!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var btnReport: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ddCategory.optionArray = ["User", "Event", "Admin"]
        ddCategory.selectedIndex = 0
        ddCategory.text = "User"
        
        tvContent.text = "Report content"
        tvContent.layer.cornerRadius = 10
        tvContent.layer.borderWidth = 1
        tvContent.layer.borderColor = UIColor.light.cgColor
    }
    @IBAction func onCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onReport(_ sender: UIButton) {
        let category = ddCategory.text?.lowercased() ?? ""
        let content = tvContent.text ?? ""
        APIManager.report(content: content, category: category, id: report_id, result: { (value) in
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            print(error)
        }
    }
}
extension ReportVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Report content" {
            textView.text = ""
        }
    }
}
