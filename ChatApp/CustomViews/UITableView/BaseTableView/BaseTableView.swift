//
//  BaseTableView.swift
//  Spotliss
//
//  Created by Agile-mac on 25/07/16.
//  Copyright © 2016 Agile-mac. All rights reserved.
//

import UIKit

class BaseTableView: TPKeyboardAvoidingTableView {
    
    //MARK :- TableView Life Cycle
    //MARK :-
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableFooterView = UIView()
        self.separatorStyle = .None
        self.estimatedRowHeight = 200
        self.rowHeight = UITableViewAutomaticDimension
    }
    
 }
