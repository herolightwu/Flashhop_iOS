//
//  TipsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/5.
//

import UIKit

class TipsVC: UIViewController {
    var paylist:[Tip] = []
    @IBOutlet weak var earningLb: UILabel!
    @IBOutlet weak var nextLb: UILabel!
    @IBOutlet weak var mDateBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let dtf = DateFormatter()
        dtf.dateFormat = "MM/dd/yyyy"
        let dt_today = dtf.string(from: Date())
        mDateBtn.setTitle(dt_today, for: .normal)
        dtf.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let to_str = dt_today + " 23:59:59"
        let end_dt = dtf.date(from: to_str)!
        loadData(timestamp: "\(end_dt.timeIntervalSince1970)")
    }
    
    func loadData(timestamp: String) {
        APIManager.getPaymentTransactions(timestamp: timestamp, uid: "\(me.id)", result: { (value) in
            self.paylist.removeAll()
            let data_dic = value["data"] as! [String:AnyObject]
            let total_dic = data_dic["total_earnings"] as! [[String: AnyObject]]
            for dic in total_dic {
                let cur_str = dic["currency"] as! String
                if cur_str.contains("cad") {
                    let total_str = dic["amount"] as! String
                    self.earningLb.text = "$" + total_str
                }
            }
            let available_dic = data_dic["available_balances"] as! [[String: AnyObject]]
            for dic in available_dic {
                let cur_str = dic["currency"] as! String
                if cur_str.contains("cad") {
                    let available_str = dic["amount"] as! String
                    self.earningLb.text = "$" + available_str
                }
            }
            let trans_dic = data_dic["data"] as! [[String: AnyObject]]
            for dic in trans_dic {
                let one = Tip()
                one.tid = dic["id"] as! String
                let created = dic["created"] as! Int64
                let created_date = Date(timeIntervalSince1970: TimeInterval(created))
                let dtf = DateFormatter()
                dtf.dateFormat = "MM/dd/yyyy"
                one.datestr = dtf.string(from: created_date)
                let detail_dic = dic["details"] as! [String: AnyObject]
                one.receiving = detail_dic["net"] as! String
                let user_dic = detail_dic["sender"] as! [String: AnyObject]
                one.uid = user_dic["id"] as! String
                one.name = user_dic["first_name"] as! String
                one.photo = user_dic["avatar"] as! String
                self.paylist.append(one)
            }
            self.tableView.reloadData()
        }, error: { (error) in
            print(error)
        })
    }

    @IBAction func onDateTap(_ sender: Any) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.date =  Date()
        picker.maximumDate = Date()
        let pickerframe : CGSize = picker.sizeThatFits(CGSize.zero)
        let viewFrame : CGSize = self.view.frame.size
        let x = (viewFrame.width - pickerframe.width) / 2
        let y = (viewFrame.height - 460) / 2
        picker.frame = CGRect(x:x, y:y, width:pickerframe.width, height:460)
        picker.addTarget(self, action: #selector(onChangedDate(sender:)), for: .valueChanged)
        self.view.addSubview(picker)
    }
    
    @objc func onChangedDate(sender: UIDatePicker) {
        let set_date = sender.date
        let dtf = DateFormatter()
        dtf.dateFormat = "MM/dd/yyyy"
        let dt_set = dtf.string(from: set_date)
        mDateBtn.setTitle(dt_set, for: .normal)
        dtf.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let to_str = dt_set + " 23:59:59"
        let end_dt = dtf.date(from: to_str)!
        loadData(timestamp: "\(end_dt.timeIntervalSince1970)")
        sender.removeFromSuperview()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onEarningTap(_ sender: Any) {
        showConfirmDlg()
    }
    @IBAction func onNextTap(_ sender: Any) {
        showConfirmDlg()
    }
    
    func showConfirmDlg() {
        AlertVC.showMessage(parent: self.navigationController?.parent, text:"You have to save a debit card to withdraw the tips.", action1_title:"Not Now", action2_title: "Continue", action1: nil){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DebitVC") as! DebitVC
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false, completion: nil)
        }
    }
}

extension TipsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paylist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "TipCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "TipCell")
        }
        let lbDate = cell.viewWithTag(11) as! UILabel
        let lbAmount = cell.viewWithTag(12) as! UILabel
        let lbName = cell.viewWithTag(13) as! UILabel
        let lbPhoto = cell.viewWithTag(14) as! PhotoButton
        let oneTip = self.paylist[indexPath.row]
        lbDate.text = oneTip.datestr
        lbAmount.text = "$" + oneTip.receiving
        lbName.text = oneTip.name
        lbPhoto.sd_setImage(with: URL(fileURLWithPath: oneTip.photo), for: .normal, completed: nil)
        return cell
    }
}
