//
//  ChatTextCell.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/26.
//

import UIKit

protocol ChatTextCellDelegate {
    func onTapLike(index: Int)
    func onTapComment(index: Int)
    func onTapDelete(index: Int)
    func onTapVoice(index: Int)
    func onTapPhoto(index: Int)
    func onSendComment(index: Int, text: String)
}

class ChatTextCell: UITableViewCell {

    @IBOutlet weak var btnPhoto: PhotoButton!
    @IBOutlet weak var tableView: AutoHeightTableView!
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var contTableHeight: NSLayoutConstraint!
    @IBOutlet weak var contEditHeight: NSLayoutConstraint!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnVoice: UIButton!
    
    let myfont: UIFont = UIFont(name: "Source Sans Pro", size: 14.0)!
    
    var index: Int!
    var delegate: ChatTextCellDelegate!
    var comments: [Comment] = []
    var userid:Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        txtComment.delegate = self
    }
    
    func setData(data: Msg) {
        btnPhoto.sd_setImage(with: URL(string: data.uPhoto), for: .normal, completed: nil)
        lblName.text = data.uName
        userid = Int(data.uId)
        
        if data.nType == 2 {
            lblMessage.text = "  " + data.sMsg + "  "
            lblMessage.backgroundColor = UIColor.green
            lblMessage.textColor = UIColor.white
            lblMessage.layer.cornerRadius = 5
            lblMessage.clipsToBounds = true
            btnVoice.isHidden = false
        } else {
            lblMessage.text = data.sMsg
            lblMessage.textColor = UIColor(rgb: 0x363C5A)
            lblMessage.backgroundColor = UIColor.clear
            lblMessage.clipsToBounds = false
            btnVoice.isHidden = true
        }
        
        let time = Date(timeIntervalSince1970: TimeInterval(data.lTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        lblTime.text = formatter.string(from: time)
        
        if data.likes.count > 0 {
            lblLike.text = "\(data.likes.count) Likes"
        } else {
            lblLike.text = "Like"
        }
        if data.bLike {
            imgLike.image = UIImage(named: "ic_liked")
        } else {
            imgLike.image = UIImage(named: "ic_like")
        }
        
        if data.comments.count > 0 {
            lblComment.text = "\(data.comments.count) Comments"
        } else {
            lblComment.text = "Comment"
        }
        if data.bComment {
            imgComment.image = UIImage(named: "ic_comment_d")
        } else {
            imgComment.image = UIImage(named: "ic_comment")
        }
        if data.uId == "\(me.id)" {
            btnDelete.isHidden = false
        } else {
            btnDelete.isHidden = true
        }
        
        comments = data.comments
        
        var height: CGFloat = 0
        for oneC in comments {
            let width = self.tableView.frame.size.width - 46
            let hL = heightForView(text: oneC.sMsg, font: myfont, width: width)
            height += (44.0 + hL)
        }
        contTableHeight.constant = CGFloat(height)
        contEditHeight.constant = 40
        
        if data.bVisibleComment {
            tableView.isHidden = false
            txtComment.isHidden = false
            tableView.reloadData()
        } else{
            tableView.isHidden = true
            txtComment.isHidden = true
            contTableHeight.constant = 0
            contEditHeight.constant = 0
        }
        
    }

    @IBAction func onTapLike(_ sender: Any) {
        if delegate != nil {
            delegate.onTapLike(index: index)
        }
    }
    
    @IBAction func onTapComment(_ sender: Any) {
//        constTxtComment.constant = 40
//        txtComment.isHidden = false
        if delegate != nil {
            delegate.onTapComment(index: index)
        }
    }
    
    @IBAction func onTapDelete(_ sender: Any) {
        if delegate != nil {
            delegate.onTapDelete(index: index)
        }
    }
    
    @IBAction func onTapVoice(_ sender: Any) {
        if delegate != nil {
            delegate.onTapVoice(index: index)
        }
    }
    
    @IBAction func onTapPhoto(_ sender: Any) {
        if delegate != nil {
            delegate.onTapPhoto(index: userid)
        }
    }
}

extension ChatTextCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let oneC = comments[indexPath.row]
        let width = self.tableView.frame.size.width - 46
        var height = heightForView(text: oneC.sMsg, font: myfont, width: width)
        height += 44
        return height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.index = indexPath.row
        cell.delegate = self
        cell.setData(data: comments[indexPath.row])
        return cell
    }
}

extension ChatTextCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            if delegate != nil {
                delegate.onSendComment(index: self.index, text: textField.text!)
            }
            textField.text = ""
        }
        return true
    }
}

extension ChatTextCell: CommentCellDelegate {
    func onTapPhoto(index: Int) {
        if self.delegate != nil {
            let uid = Int(comments[index].uId)!
            self.delegate.onTapPhoto(index: uid)
        }
    }
}
