//
//  Message.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/26.
//

import Foundation

public class Message {
    public var uid: String = ""
    public var username: String = ""
    public var avatar: String = ""
    public var timestamp: Int64 = 0
    public var type: Int64 = 0
    public var value: String = ""
    public var photos: [String] = []
    public var likes: [String] = []
    public var comments: [Comment] = []
    public var reads: [String] = []
    
    var dictionary: [String:Any] {
        return ["uid" : uid,
                "username" : username,
                "avatar" : avatar,
                "timestamp" : timestamp,
                "type" : type,
                "value" : value,
                "photos" : photos,
                "likes" : likes,
                "comments" : comments,
                "reads" : reads]
    }
    
    init() {}
    
    init(dict: [String:Any]) {
        self.uid = dict["uid"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.avatar = dict["avatar"] as? String ?? ""
        self.timestamp = dict["timestamp"] as? Int64 ?? 0
        self.type = dict["type"] as? Int64 ?? 0
        self.value = dict["value"] as? String ?? ""
        self.photos = dict["photos"] as? [String] ?? []
        self.likes = dict["likes"] as? [String] ?? []
        if let comments = dict["comments"] as? [[String:Any]] {
            for comment in comments {
                self.comments.append(Comment(dict: comment))
            }
        }
        self.reads = dict["reads"] as? [String] ?? []
    }
}
