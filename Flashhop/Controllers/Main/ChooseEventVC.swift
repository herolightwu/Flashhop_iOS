//
//  ChooseEventVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/28.
//

import UIKit

class ChooseEventVC: UIViewController {

    var events:[Event] = []
    var callback:((Event)->Void)?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // pop up
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        tableView.reloadData()
    }
    @IBAction func onTapClose(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func onSend(_ sender: RoundButton) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let event = events[indexPath.row]
            callback?(event)
            self.dismiss(animated: false, completion: nil)
        }else{
            sender.shake()
        }
    }
}
extension ChooseEventVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "EventCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "EventCell")
        }
        
        let event = events[indexPath.row]
        
        let lbMon = cell.viewWithTag(11) as! UILabel
        let lbDay = cell.viewWithTag(12) as! UILabel
        let lbWeekday = cell.viewWithTag(13) as! UILabel
        let lbTitle = cell.viewWithTag(20) as! UILabel
        let ivPhoto = cell.viewWithTag(30) as! UIImageView
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        lbMon.text = formatter.string(from: event.time())
        formatter.dateFormat = "dd"
        lbDay.text = formatter.string(from: event.time())
        formatter.dateFormat = "E"
        lbWeekday.text = formatter.string(from: event.time())
        lbTitle.text = event.title
        if event.cover_photo == "" { ivPhoto.image = event.category.cover_image }
        else { ivPhoto.sd_setImage(with: URL(string: event.cover_photo), completed: nil) }
        return cell
    }
}
