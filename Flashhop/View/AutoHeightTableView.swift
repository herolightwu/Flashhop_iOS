//
//  AutoHeightTableView.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/27.
//

import UIKit

class AutoHeightTableView: UITableView {

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }

    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: contentSize.width, height: contentSize.height)
    }
}
