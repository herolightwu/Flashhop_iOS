//
//  GroupChatVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/18.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import AVFoundation
import KRProgressHUD
import Photos

class GroupChatVC: UIViewController {

    public var event:Event!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMon: UILabel!
    @IBOutlet weak var lbDay: UILabel!
    @IBOutlet weak var lbWeekday: UILabel!
    @IBOutlet weak var viewProfiles: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var btnMic: UIButton!
    @IBOutlet weak var lblRemain: UILabel!
    @IBOutlet weak var btnInvite: RoundButton!
    
    var database: DatabaseReference!
    var storage: StorageReference!
    var messages: [Msg] = []
    var fmessages: [Msg] = []
    public var photos:[PHAsset] = []
    public var photo_urls:[String] = []
    
    let myfont: UIFont = UIFont(name: "Source Sans Pro", size: 14.0)!
    
    var audioRecorder: AVAudioRecorder!
    var audioFileName: URL!
    var player: AVPlayer!
    var bPlay = false

    var startTime: Int64!
    var endTime: Int64!
    var voiceLength: Int64!
    var photo_ind: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        database = Database.database().reference()
        storage = Storage.storage().reference()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        makeShadowView(btnInvite)
        
        loadChatData()
        
        // Do any additional setup after loading the view.
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        lbMon.text = formatter.string(from: event.time())
        formatter.dateFormat = "dd"
        lbDay.text = formatter.string(from: event.time())
        formatter.dateFormat = "E"
        lbWeekday.text = formatter.string(from: event.time())
        lbTitle.text = event.title
        
        let diff = 7*24*3600 - (Int(Date().timeIntervalSince1970 - event.time().timeIntervalSince1970))
        if diff < 3600 {
            lblRemain.text = "This group chat will disappear in \(diff/60) minutes."
        } else if diff < 24*3600 {
            lblRemain.text = "This group chat will disappear in \(diff/3600) hours."
        } else {
            lblRemain.text = "This group chat will disappear in \(diff/3600/24) days."
        }
        
        var n = event.members.count
        if n > 4 { n = 4 }
        var x:CGFloat = 0
        let y = viewProfiles.frame.height / 2
        for i in 0...n {
            var user: FUser!
            if i==0 { user = event.creator } else { user = event.members[i-1] }
            var size:CGFloat = 24; if i==0 { size = 30 }
            let photo = PhotoButton(frame: CGRect(x: x, y: y-size*0.66, width: size, height: size))
            photo.sd_setImage(with: URL(string: user.photo_url), for: .normal, completed: nil)
            viewProfiles.addSubview(photo)
            
            x += size/2
        }
    }
    
    func loadChatData() {
        messages.removeAll()
        database.child("chat_history").child("\(event!.id)").queryOrdered(byChild: "timestamp").observe(
            .childAdded,
            with: { dataSnapshot in
                if dataSnapshot.value != nil {
                    let oneMsg = Msg()
                    let dict = dataSnapshot.value as? [String:Any] ?? [:]
                    let one = Message(dict: dict)
                    
                    oneMsg.dbKey = dataSnapshot.key
                    oneMsg.uId = one.uid
                    oneMsg.uName = one.username
                    oneMsg.uPhoto = one.avatar
                    oneMsg.lTime = one.timestamp
                    oneMsg.likes = one.likes
                    oneMsg.comments = one.comments
                    oneMsg.photos = one.photos
                    oneMsg.nType = one.type
                    oneMsg.sMsg = one.value
                    
                    for like in one.likes {
                        if like == "\(me.id)" {
                            oneMsg.bLike = true
                        }
                    }
                    for comment in one.comments {
                        if comment.uId == "\(me.id)" {
                            oneMsg.bComment = true
                        }
                    }
                    var index = -1
                    for i in 0..<self.messages.count {
                        if self.messages[i].dbKey == oneMsg.dbKey {
                            index = i
                            break
                        }
                    }
                    if index == -1 {
                        self.messages.append(oneMsg)
                    } else {
                        self.messages.insert(oneMsg, at: index)
                    }
                    var bRead = false
                    for read in one.reads {
                        if read == "\(me.id)" {
                            bRead = true
                            break
                        }
                    }
                    if bRead == false {
                        self.database.child("chat_history").child("\(self.event!.id)").child(oneMsg.dbKey).child("read").child("\(one.reads.count)").setValue("\(me.id)")
                    }
                    self.fmessages.removeAll()
                    self.fmessages.append(contentsOf: self.messages)
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
                }
            }
        )
        database.child("chat_history").child("\(event!.id)").queryOrdered(byChild: "timestamp").observe(
            .childChanged,
            with: { dataSnapshot in
                if dataSnapshot.value != nil {
                    let oneMsg = Msg()
                    let dict = dataSnapshot.value as? [String:Any] ?? [:]
                    let one = Message(dict: dict)
                    
                    oneMsg.dbKey = dataSnapshot.key
                    oneMsg.uId = one.uid
                    oneMsg.uName = one.username
                    oneMsg.uPhoto = one.avatar
                    oneMsg.lTime = one.timestamp
                    oneMsg.likes = one.likes
                    oneMsg.comments = one.comments
                    oneMsg.photos = one.photos
                    oneMsg.nType = one.type
                    oneMsg.sMsg = one.value
                    
                    for like in one.likes {
                        if like == "\(me.id)" {
                            oneMsg.bLike = true
                        }
                    }
                    for comment in one.comments {
                        if comment.uId == "\(me.id)" {
                            oneMsg.bComment = true
                        }
                    }
                    var index = -1
                    for i in 0..<self.messages.count {
                        if self.messages[i].dbKey == oneMsg.dbKey {
                            index = i
                            break
                        }
                    }
                    if index == -1 {
                        self.messages.append(oneMsg)
                    } else {
                        self.messages[index] = oneMsg
                    }
                    var bRead = false
                    for read in one.reads {
                        if read == "\(me.id)" {
                            bRead = true
                            break
                        }
                    }
                    if bRead == false { self.database.child("chat_history").child("\(self.event!.id)").child(oneMsg.dbKey).child("read").child("\(one.reads.count)").setValue("\(me.id)")
                    }
                    self.fmessages.removeAll()
                    self.fmessages.append(contentsOf: self.messages)
                    self.tableView.reloadData()
                }
            }
        )
        database.child("chat_history").child("\(event!.id)").queryOrdered(byChild: "timestamp").observe(
            .childRemoved,
            with: { dataSnapshot in
                if dataSnapshot.value != nil {
                    for i in 0..<self.messages.count {
                        if self.messages[i].dbKey == dataSnapshot.key {
                            // send notification
                            self.messages.remove(at: i)
                            self.fmessages.removeAll()
                            self.fmessages.append(contentsOf: self.messages)
                            self.tableView.reloadData()
                            break
                        }
                    }
                }
            }
        )
        database.child("last_history").child("\(event!.id)").observeSingleEvent(of: .value, with: { dataSnapshot in
                if dataSnapshot.value != nil {
                    let dict = dataSnapshot.value as? [String:Any] ?? [:]
                    let lMsg = LastMessage(dict:dict)
                    if !lMsg.likes.contains("\(me.id)") {
                        lMsg.likes = lMsg.likes + "\(me.id)" + ","
                    self.database.child("last_history").child("\(self.event!.id)").setValue(lMsg.dictionary)
                    }
                }
            }
        )
    }
    
    func sendMessage() {
        if txtMessage.text != "" {
            let timestamp = Int64(Date().timeIntervalSince1970)
            let key = database.child("chat_history").child("\(event!.id)").childByAutoId().key
            
            let one = Message()
            one.uid = "\(me.id)"
            one.username = me.first_name
            one.avatar = me.photo_url
            one.timestamp = timestamp
            one.type = 0
            one.value = txtMessage.text!
            one.reads.append("\(me.id)")
            
            database.child("chat_history").child("\(event!.id)").child(key!).setValue(one.dictionary)
            
            let lastMsg = LastMessage()
            lastMsg.uId = "\(me.id)"
            lastMsg.msg = me.first_name + " : " + txtMessage.text!
            lastMsg.uName = me.first_name
            lastMsg.lTime = timestamp
            lastMsg.likes = "\(me.id),"
            
            database.child("last_history").child("\(event!.id)").setValue(lastMsg.dictionary)
            
            // send notification
            APIManager.sendChatNotification(ev_id: "\(event!.id)", msg: lastMsg.msg, uid: "\(me.id)", callback: { result in
            })
        }
        txtMessage.text = ""
    }
    
    func sendVoice(url: String, len: String) {
        if url != "" {
            let timestamp = Int64(Date().timeIntervalSince1970)
            let key = database.child("chat_history").child("\(event!.id)").childByAutoId().key
            
            let one = Message()
            one.uid = "\(me.id)"
            one.username = me.first_name
            one.avatar = me.photo_url
            one.timestamp = timestamp
            one.type = 2
            one.photos.append(url)
            one.value = "Sent Voice : " + len
            one.reads.append("\(me.id)")
            
            database.child("chat_history").child("\(event!.id)").child(key!).setValue(one.dictionary)
            
            let lastMsg = LastMessage()
            lastMsg.uId = "\(me.id)"
            lastMsg.msg = me.first_name + " : Sent Voice : " + len
            lastMsg.uName = me.first_name
            lastMsg.lTime = timestamp
            lastMsg.likes = "\(me.id),"
            
            database.child("last_history").child("\(event!.id)").setValue(lastMsg.dictionary)
            
            // send notification
            APIManager.sendChatNotification(ev_id: "\(event!.id)", msg: lastMsg.msg, uid: "\(me.id)", callback: { result in
            })
            
        }
        txtMessage.text = ""
    }
    
    func sendPhotos() {
        let timestamp = Int64(Date().timeIntervalSince1970)
        let key = database.child("chat_history").child("\(event!.id)").childByAutoId().key
        
        let one = Message()
        one.uid = "\(me.id)"
        one.username = me.first_name
        one.avatar = me.photo_url
        one.timestamp = timestamp
        one.type = 1
        one.photos = self.photo_urls
        one.value = "Posted " + "\(self.photo_urls.count)" + " Photos"
        one.reads.append("\(me.id)")
        
        database.child("chat_history").child("\(event!.id)").child(key!).setValue(one.dictionary)
        
        let lastMsg = LastMessage()
        lastMsg.uId = "\(me.id)"
        lastMsg.msg = me.first_name + " : Posted " + "\(self.photo_urls.count)" + " Photos"
        lastMsg.uName = me.first_name
        lastMsg.lTime = timestamp
        lastMsg.likes = "\(me.id),"
        
        database.child("last_history").child("\(event!.id)").setValue(lastMsg.dictionary)
        
        // send notification
        APIManager.sendChatNotification(ev_id: "\(event!.id)", msg: lastMsg.msg, uid: "\(me.id)", callback: { result in
        })
        txtMessage.text = ""
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapLocation(_ sender: Any) {
        AlertVC.showMessage(parent: self.navigationController?.parent, text: "Send your current location?", action1_title: "No", action2_title: "Yes", action1: nil)
        {
            self.txtMessage.text = "My Address : \(me.address)"
            self.sendMessage()
        }
    }
    
    @IBAction func onTapGroup(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupInfoVC") as! GroupInfoVC
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapInvite(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChooseFriendsVC") as! ChooseFriendsVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.callback = { friends in
        }
        self.navigationController?.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func onTapImage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChoosePhotosVC") as! ChoosePhotosVC
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.callback = { result in
            self.photos = result
            self.uploadPhotos()
        }
    }
    
    func uploadPhotos() {
        photo_ind = 0;
        self.photo_urls.removeAll()
        KRProgressHUD.show()
        for photo in self.photos {
            let img = getImage(asset: photo) 
            let img_data = img.resizedTo1MB()!.pngData()!
            let filePath = "\(me.id)" +  "_\(Date().timeIntervalSince1970)"
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            let storageRef = self.storage.child("photos").child(filePath)
            storageRef.putData(img_data, metadata: metadata) { (metaData, error) in
                  if error != nil {
                      print("error")
                    KRProgressHUD.dismiss()
                  } else {
                    // your uploaded photo url.
                    storageRef.downloadURL(completion: { (url, error) in
                        //code
                        self.photo_urls.append("\(url!)")
                        self.photo_ind += 1
                        if self.photo_ind == self.photos.count {
                            KRProgressHUD.dismiss()
                            self.sendPhotos()
                        }
                    })
                }
             }
        }
    }
    
    @IBAction func onTapSend(_ sender: Any) {
        sendMessage()
        view.endEditing(true)
    }
    
    @IBAction func onTapMic(_ sender: Any) {
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission({ allowed in
                if allowed {
                    if self.audioRecorder != nil {
                        self.finishRecording()
                    } else {
                        self.startRecording()
                    }
                } else {
                }
            })
        } catch {
            
        }
    }
    
    func startRecording() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        audioFileName = paths[0].appendingPathComponent("recording\(Date().timeIntervalSince1970).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            btnMic.setImage(UIImage(named: "ic_mic_red"), for: .normal)
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            startTime = Int64(Date().timeIntervalSince1970)
        } catch {
            finishRecording()
        }
    }
    
    func finishRecording() {
        audioRecorder.stop()
        audioRecorder = nil
        btnMic.setImage(UIImage(named: "ic_mic"), for: .normal)
    }
}

extension GroupChatVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fmessages.removeAll()
        if(searchText.count > 0){
            for msg in messages {
                if msg.sMsg.lowercased().contains(searchText.lowercased()) {
                    fmessages.append(msg)
                } else {
                    for com in msg.comments {
                        if com.sMsg.lowercased().contains(searchText.lowercased()){
                            fmessages.append(msg)
                        }
                    }
                }
            }
        } else{
            fmessages.append(contentsOf: messages)
        }
        self.tableView.reloadData()
    }
}

extension GroupChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fmessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 66
        let msg = fmessages[indexPath.row]
        let widthC = self.tableView.frame.size.width - 86
        let width = self.tableView.frame.size.width - 40
        if msg.bVisibleComment {
            for oneC in msg.comments {
                let hL = heightForView(text: oneC.sMsg, font: myfont, width: widthC)
                height += (44.0 + hL)
            }
            height += 44
        }
        if msg.nType == 1{
            height += 64
        }
        let hM = heightForView(text: msg.sMsg, font: myfont, width: width)
        let gap = CGFloat(Int(hM/16) * 2)
        height += (hM + gap)
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = fmessages[indexPath.row]
        if msg.nType == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatPhotoCell") as! ChatPhotoCell
            cell.delegate = self
            cell.index = indexPath.row
            cell.setData(data: fmessages[indexPath.row])
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTextCell") as! ChatTextCell
            cell.delegate = self
            cell.index = indexPath.row
            cell.setData(data: fmessages[indexPath.row])
            return cell
        }
    }
}

extension GroupChatVC: ChatPhotoCellDelegate {
    func findUser(id: String)->FUser {
        for member in event.members {
            if "\(member.id)" == id {
                return member
            }
        }
        return FUser()
    }
    
    func onTapImage(index: Int, img_ind: Int) {
        let sel_msg = fmessages[index]
        let storyboard:UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PhotoViewVC") as! PhotoViewVC
        vc.img_url = sel_msg.photos[img_ind]
        vc.username = sel_msg.uName
        vc.eTitle = event.title
        vc.eDesc = event.desc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onTapPhoto(index: Int) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        if index != me.id {
            vc.user = findUser(id: "\(index)")
            vc.status = .INVITE
        } else {
            vc.user = me
            vc.status = .PREVIEW
        }
        if vc.user.id != 0 {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onTapLike(index: Int) {
        let one = fmessages[index]
        let cKey = "\(one.likes.count)"
        if one.bLike == false {
            database.child("chat_history").child("\(event.id)").child(one.dbKey).child("likes").child(cKey).setValue("\(me.id)")
        } else {
            for i in 0..<one.likes.count {
                if one.likes[i] == "\(me.id)" {
                    one.likes.remove(at: i)
                    break
                }
            }
            database.child("chat_history").child("\(event.id)").child(one.dbKey).child("likes").setValue(one.likes)
        }
    }
    
    func onTapComment(index: Int) {
        var one = self.fmessages[index]
        one.bVisibleComment = !one.bVisibleComment
        self.tableView.reloadData()
    }
    
    func onTapDelete(index: Int) {
        AlertVC.showMessage(parent: self.navigationController?.parent, text: "Delete the message?", action1_title: "No", action2_title: "Yes", action1: nil)
        {
            let one = self.fmessages[index]
            self.database.child("chat_history").child("\(self.event.id)").child(one.dbKey).setValue(nil)
        }
    }
    
    func onSendComment(index: Int, text: String) {
        let one = fmessages[index]
        let timestamp = Date().timeIntervalSince1970
        let cKey = "\(one.comments.count)"
        let comment = Comment()
        comment.uId = "\(me.id)"
        comment.sMsg = text
        comment.uPhoto = me.photo_url
        comment.lTime = Int64(timestamp)
        comment.uName = me.first_name
        database.child("chat_history").child("\(event.id)").child(one.dbKey).child("comments").child(cKey).setValue(comment.dictionary)
        
        // send notification
        let noti_str = me.first_name + " left a comment"
        APIManager.sendChatNotification(ev_id: "\(event!.id)", msg: noti_str, uid: "\(me.id)", callback: { result in
        })
    }
}

extension GroupChatVC: ChatTextCellDelegate {
    
    func onTapVoice(index: Int) {
        if bPlay{
            player?.pause()
            player = nil
            bPlay = false
        } else{
            let one = fmessages[index]
            if one.photos.count > 0 {
                guard let url = URL.init(string: one.photos[0]) else { return }
                //print(url.absoluteString)
                do {
                    player = try AVPlayer(url: url as URL)
                } catch {
                    print("audio file error")
                    return
                }
                player?.play()
                bPlay = true
            }
        }
        
    }
}

extension GroupChatVC: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag == false {
            finishRecording()
        } else {
            endTime = Int64(Date().timeIntervalSince1970)
            voiceLength = endTime - startTime
            APIManager.uploadVoiceFile(filename: audioFileName, result: { (value) in
                let url_str = value["data"] as! String
                let minutes = self.voiceLength / 60
                let second = self.voiceLength % 60
                
                let timeStr = minutes > 0 ? "\(minutes)\' \(second)\"" : "\(second)\""
                self.sendVoice(url: url_str, len: timeStr)
            }) { (error) in
                print(error)
            }
            /*let ref = storage.child("voices").child(audioFileName.lastPathComponent)
            KRProgressHUD.show()
            _ = ref.putFile(from: audioFileName, metadata: nil) { (metadata, error) in
                KRProgressHUD.dismiss()
                guard metadata != nil else {
                    return
                }
                ref.downloadURL(completion: { (url, error) in
                    KRProgressHUD.dismiss()
                    guard let downloadUrl = url else {
                        return
                    }
                    let minutes = self.voiceLength / 60
                    let second = self.voiceLength % 60
                    
                    let timeStr = minutes > 0 ? "\(minutes)\' \(second)\"" : "\(second)\""
                    self.sendVoice(url: downloadUrl.absoluteString, len: timeStr)
                })
            }*/
        }
    }
}
