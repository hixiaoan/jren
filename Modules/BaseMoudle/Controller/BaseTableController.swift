//
//   BaseTableController.swift
//  FutureCity_Swift
//
//  Created by Derrick on 2018/9/4.
//  Copyright © 2018年 bike. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Alamofire
import Reachability
class BaseTableController: BaseViewController {
    
    public var tableView:UITableView?
    public var dataArray = [Any?]()
    /// 是否自动刷新
    public var refreshWhenLoad:Bool = true
    public var onBeginRefreshing: (()->())?
    // 页码
    public var page: Int = 1
    /// 每页加载数
    public var perpageCount: Int = 18
    // 是否显示空数据页面
    public var haveData:Bool = true
    public var cellIdentifier = "cell"
    /// 是否缓存成功
    public var haveCache: Bool = false
    /// 缓存数组
    public var cacheArray = [Any?]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
        
    }
    
    
    
    /// 创建tableView
    public func createTableView() {
        
        
        tableView = UITableView.init(frame: tableViewFrame(), style: .plain)
        
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.emptyDataSetSource = self
        tableView?.emptyDataSetDelegate = self
        
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = Theam.Color.background
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.tableFooterView = UIView.init()
        
        tableView?.estimatedRowHeight = 0
        tableView?.estimatedSectionFooterHeight = 0
        tableView?.estimatedSectionHeaderHeight = 0
        
        view.addSubview(tableView!)
        
        if #available(iOS 11.0, *) {
            tableView?.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        if responds(to: #selector(getter: automaticallyAdjustsScrollViewInsets)) {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        
        
    }
    
    /// 设置tableViewFrame
    public func tableViewFrame() -> CGRect {
        return CGRect.init(x: 0, y: self.navBarBottom, width: kScreenWidth, height: kScreenHeight-self.navBarBottom)
    }
    
    /// 注册头部尾部
    public func registRefreshHeaderAndFooter() {
        registRefreshHeader()
        registRefreshFooter()
    }
    
    /// 注册刷新头部
    public func registRefreshHeader() {
        let header = RefreshAnimationHeader{ [weak self] in
            self?.loadNewData()
        }
        
        tableView?.mj_header = header
        if refreshWhenLoad {
            tableView?.mj_header.beginRefreshing()
        }
    }
    
    /// 注册刷新尾部
    public func registRefreshFooter() {
        let footer = RefreshAnimationFooter{ [weak self] in
            self?.loadNextPage()
        }
        tableView?.mj_footer = footer
        tableView?.mj_footer.isHidden = true
    }
    
    /// MARK: 刷新事件
    private func reloadData() {
        tableView?.reloadData()
        tableView?.reloadEmptyDataSet()
    }
    
    
    
    /// 开始刷新
    public func refreshWithAnimation() {
        tableView?.mj_header.beginRefreshing()
    }
    
    /// 结束刷新
    public func endRefreshAnimation() {
        endRefreshWithCount(0)
    }
    
    public func endRefreshWithCount(_ count: Int) {
        haveData = self.dataArray.count > 0 ? true : false
        reloadData()
        
        guard let header = tableView?.mj_header else {
            return
        }
        if (header.isRefreshing) {
            tableView?.mj_header.endRefreshing()
        }
        guard let footer = tableView?.mj_footer else {
            return
        }
        if (footer.isRefreshing) {
            tableView?.mj_footer.endRefreshing()
        }
        
        let isNoMoreData = count < perpageCount || count == 0
        tableView?.mj_footer.isHidden = isNoMoreData
        
        
    }
    
    /// MARK: 处理数据相关
    
    /// 刷新数据
    public func refreshData() {
        
    }
    
    /// 加载下一页
    public func loadNextPage() {
        page+=1
        refreshData()
        
    }
    
    /// 加载最新的数据
    override func loadNewData() {
        
        page=1
        if self.dataArray.count > 0 {
            self.dataArray.removeAll()
        }
        refreshData()
        
    }
    
    // 注册cell
    public func registerCellNib(_ cellClassString:String) {
        self.tableView?.register(UINib.init(nibName: cellClassString, bundle: nil), forCellReuseIdentifier: cellClassString)
        self.cellIdentifier = cellClassString
    }
    public func registerCellClass(_ cellClassString:AnyClass) {
        self.tableView?.register(cellClassString, forCellReuseIdentifier: "\(cellClassString)")
        self.cellIdentifier = "\(cellClassString)"
    }
    
    
}


extension  BaseTableController : UITableViewDelegate,UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.textLabel?.text = "哈哈哈哈哈"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension  BaseTableController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "empty_placeholde_happy_image")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "暂无数据"
        let attributes:[NSAttributedString.Key:AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 14),NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.init(hexString: "3c3e42")]
        return NSAttributedString.init(string: text, attributes: attributes)
        
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> UIImage! {
        return UIImage(named: "")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return !haveData
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}
