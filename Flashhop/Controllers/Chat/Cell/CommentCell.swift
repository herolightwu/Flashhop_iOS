//
//  CommentCell.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/27.
//

import UIKit

protocol CommentCellDelegate {
    func onTapPhoto(index: Int)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var btnPhoto: PhotoButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    var index: Int!
    var delegate: CommentCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func onTapPhoto(_ sender: Any) {
        if delegate != nil {
            delegate.onTapPhoto(index: index)
        }
    }
    
    func setData(data: Comment) {
        btnPhoto.sd_setImage(with: URL(string: data.uPhoto), for: .normal, completed: nil)
        lblName.text = data.uName
        //lblMessage.numberOfLines = 0
        //lblMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblMessage.text = data.sMsg
        
        let time = Date(timeIntervalSince1970: TimeInterval(data.lTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        lblTime.text = formatter.string(from: time)
    }
}
