//
//  TestTableView.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/30.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TestTableView: BaseTableViewController, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .red
        self.config.tableViewCells = ["UITableViewCell"]
        Observable.just(["1","2","3","4","5","6"]).bind(to: tableView.rx.items){ view,row,str in
            let cell = view.dequeueReusableCell(withIdentifier: "UITableViewCell") as! UITableViewCell
            cell.textLabel?.text = str
            return cell
        }.disposed(by: dispose)
    }
}
