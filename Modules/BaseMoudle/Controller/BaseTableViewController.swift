//
//  BaseTableViewController.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/30.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

struct BaseTableViewConfig {
    
    ///tableView 配置
    var frame:CGRect = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    var style : UITableView.Style = .plain
    var separatorStyle :UITableViewCell.SeparatorStyle = .none
    var tableViewCells = [String]()
    var showsHorizontalScrollIndicator  = false
    var showsVerticalScrollIndicator    = false
    var isDefultConfig  = true
    ///工具配置
    var isHeaderRefresh = true
    var isFooterRefresh = true
    
}

class BaseTableViewController: BaseViewController {

    var tableView : UITableView!
    lazy var config = BaseTableViewConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfig().reugisterCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observableMethodIsImp()
    }
}
extension BaseTableViewController{
    
    func observableMethodIsImp() -> BaseTableViewController {
        if self.tableView.dataSource == nil {
            print("TableView's dataSource is nil ")
        }
        
        if self.tableView.delegate == nil {
            print("TableView's delegate is nil ")
        }
        if self.config.isDefultConfig {
            print("该tableView是默认设置,如有需求请重新初始化config属性,关闭提示请将isDefultConfig设置为false")
        }
        return self
    }
}

extension BaseTableViewController{
    
    ///添加下拉刷新和上拉刷新功能
    func setHeaderRefreshAndFooterRefresh() -> BaseTableViewController {
        
        return self
    }
    
   fileprivate func reugisterCell() -> BaseTableViewController {
        if config.tableViewCells.count == 0 {
            print("cofig's tableViewCells 未设置,请设置要注册的cell")
        }else{
            for cellId in config.tableViewCells {
                self.tableView.register(NSClassFromString(cellId).self, forCellReuseIdentifier:cellId )
            }
        }
        return self
    }
}


extension BaseTableViewController{
    
    func tableViewConfig() -> BaseTableViewController {
        tableView = UITableView.init(frame: config.frame, style: config.style)
        tableView.separatorStyle = config.separatorStyle
        tableView.backgroundColor = Theam.Color.background
        tableView.showsHorizontalScrollIndicator = config.showsHorizontalScrollIndicator
        tableView.showsVerticalScrollIndicator = config.showsVerticalScrollIndicator
        tableView.tableFooterView = UIView.init()
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        view.addSubview(tableView!)
        if #available(iOS 11.0, *) {
            tableView?.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        if responds(to: #selector(getter: automaticallyAdjustsScrollViewInsets)) {
            automaticallyAdjustsScrollViewInsets = false
        }
        return self
    }
}
