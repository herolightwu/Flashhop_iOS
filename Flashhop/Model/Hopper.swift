//
//  Hopper.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/31.
//

import Foundation

public class Hopper: NSObject {
    public var uid = 0
    public var avatar = ""
    public var name = ""
    public var nPaid = 0
    public var nOffline = 0
    
    convenience init(dic:[String:AnyObject]) {
        self.init()
        
        if let uid = dic["id"] as? Int { self.uid = uid }
        if let avatar = dic["avatar"] as? String { self.avatar = avatar }
        if let name = dic["first_name"] as? String { self.name = name }
        
        nPaid = 0
        nOffline = 0
    }
}
