//
//  File.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/19.
//

import UIKit

func isValidEmail(_ emailStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: emailStr)
}
