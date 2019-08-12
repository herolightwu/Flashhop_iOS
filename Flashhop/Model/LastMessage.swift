//
//  LastMessage.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/26.
//

import Foundation

public class LastMessage {
    public var uId: String = ""
    public var uName: String = ""
    public var msg: String = ""
    public var lTime: Int64 = 0
    public var likes: String = ""
    
    var dictionary: [String:Any] {
        return ["uId" : uId,
                "uName" : uName,
                "msg" : msg,
                "lTime" : lTime,
                "likes" : likes]
    }
    
    init() {}
    
    init(dict: [String:Any]) {
        self.uId = dict["uId"] as? String ?? ""
        self.uName = dict["uName"] as? String ?? ""
        self.msg = dict["msg"] as? String ?? ""
        self.lTime = dict["lTime"] as? Int64 ?? 0
        self.likes = dict["likes"] as? String ?? ""
    }
}
