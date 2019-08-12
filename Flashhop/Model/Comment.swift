//
//  Comment.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/26.
//

import Foundation

public class Comment {
    public var uId: String = ""
    public var uName: String = ""
    public var uPhoto: String = ""
    public var lTime: Int64 = 0
    public var sMsg: String = ""
    
    var dictionary: [String:Any] {
        return ["uId" : uId,
                "uName" : uName,
                "uPhoto" : uPhoto,
                "lTime" : lTime,
                "sMsg" : sMsg]
    }
    
    init() {
    }
    
    init(dict: [String: Any]) {
        self.uId = dict["uId"] as? String ?? ""
        self.uName = dict["uName"] as? String ?? ""
        self.uPhoto = dict["uPhoto"] as? String ?? ""
        self.lTime = dict["lTime"] as? Int64 ?? 0
        self.sMsg = dict["sMsg"] as? String ?? ""
    }
}
