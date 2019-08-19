//
//  Msg.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/26.
//

import Foundation

public class Msg {
    public var dbKey: String = ""
    public var uId: String = ""
    public var uName: String = ""
    public var uPhoto: String = ""
    public var lTime: Int64 = 0
    public var nType: Int64 = 0
    public var sMsg: String = ""
    public var photos: [String] = []
    public var likes: [String] = []
    public var comments: [Comment] = []
    public var bLike: Bool = false
    public var bComment: Bool = false
    public var bOnline: Bool = false
    public var bVisibleComment = false
}
