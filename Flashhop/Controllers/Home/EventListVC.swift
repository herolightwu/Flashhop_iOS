//
//  EventListVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/4.
//

import UIKit

class EventListVC: UIViewController {
    
    public var events:[Event] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EventListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.events[indexPath.row]
        
        var cell:UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "EventCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "EventCell")
        }
        
        let lbMon = cell.viewWithTag(11) as! UILabel;
        let lbDay = cell.viewWithTag(12) as! UILabel
        let lbWeekday = cell.viewWithTag(13) as! UILabel
        let lbTitle = cell.viewWithTag(20) as! UILabel
        let lbTime = cell.viewWithTag(30) as! UILabel
        let lbAddress = cell.viewWithTag(40) as! UILabel
        let ivPhoto = cell.viewWithTag(50) as! UIImageView
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        lbMon.text = formatter.string(from: event.time())
        formatter.dateFormat = "dd"
        lbDay.text = formatter.string(from: event.time())
        formatter.dateFormat = "E"
        lbWeekday.text = formatter.string(from: event.time())
        lbTitle.text = event.title
        lbTime.text = event.start_end()
        lbAddress.text = event.address
        lbAddress.sizeToFit()
        if event.cover_photo == "" { ivPhoto.image = event.category.cover_image }
        else { ivPhoto.sd_setImage(with: URL(string: event.cover_photo), completed: nil) }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventVC") as! EventVC
        vc.event = self.events[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
