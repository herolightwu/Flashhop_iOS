//
//  ChooseFriendsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/28.
//

import UIKit

class ChooseFriendsVC: UIViewController {

    public var callback: (([FUser])->Void)?
    public var all_friends:[FUser] = []
    public var friends:[FUser] = []
    public var flags:[FUser:Bool] = [:]
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lbUsers: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // pop up
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        loadAllFriends()
    }
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func onSend(_ sender: Any) {
        var selected_friends:[FUser] = []
        for (user, flag) in flags {
            if flag {
                selected_friends.append(user)
            }
        }
        callback?(selected_friends)
    }
    func loadAllFriends() {
        APIManager.getAllFriends(result: { (value) in
            if let dic = value["data"] as? [[String:AnyObject]] {
                self.all_friends = []
                for userDic in dic {
                    let user = FUser(dic: userDic)
                    self.all_friends.append(user)
                }
                self.friends = self.all_friends
                self.collectionView.reloadData()
            }
        }) { (error) in
            print(error)
        }
    }
    func showUsersName() {
        var str = ""
        for (user, flag) in flags {
            if flag {
                str += user.first_name + ", "
            }
        }
        if str.count > 1 { str = String(str.dropLast()); str = String(str.dropLast()) }
        lbUsers.text = str
    }
    @objc func onChoosedUser(_ sender: PhotoButton) {
        let index = sender.tag2
        let user = self.friends[index]
        self.flags[user] = !(self.flags[user] ?? false)
        showUsersName()
        collectionView.reloadData()
    }
}

extension ChooseFriendsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath)
        
        let friend = self.friends[indexPath.row]
        let btnPhoto = cell.viewWithTag(10) as! PhotoButton
        let lbName = cell.viewWithTag(20) as! UILabel
        
        btnPhoto.sd_setImage(with: URL(string: friend.photo_url), for: .normal, completed: nil)
        btnPhoto.tag2 = indexPath.row
        btnPhoto.addTarget(self, action:#selector(onChoosedUser), for: .touchUpInside)
        lbName.text = friend.full_name()
        
        if let flag = self.flags[friend] {
            if flag {   // selected
                btnPhoto.borderColor = .red
                lbName.textColor = .red
            }else{
                btnPhoto.borderColor = .white
                lbName.textColor = .dark
            }
        }
        
        return cell
    }
}
extension ChooseFriendsVC: UICollectionViewDelegate {
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        self.flags[friend] = true
        
        collectionView.reloadData()
        self.showUsersName()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        flags[friend] = false
        collectionView.reloadData()
        self.showUsersName()
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.cellForItem(at: indexPath)?.isSelected ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
            return false
        }
        return true
    }*/
}
extension ChooseFriendsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 3 {
            self.friends = []
            for user in all_friends {
                if user.full_name().contains(searchText) {
                    self.friends.append(user)
                }
            }
            self.collectionView.reloadData()
        }else{
            self.friends = self.all_friends
            self.collectionView.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
