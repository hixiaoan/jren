//
//  BaseCollectionController.swift
//  MSStudent
//
//  Created by Derrick on 2018/12/13.
//  Copyright © 2018年 mgss. All rights reserved.
//

import UIKit
import DZNEmptyDataSet


class BaseCollectionController: BaseViewController {
    
    public var collectionView:UICollectionView?
    public var dataArray = [Any?]()
    public var refreshWhenLoad:Bool = false
    // 页码
    public var page: Int = 1
    /// 每页加载数
    public var perpageCount:Int = 18
    // 是否显示空数据页面
    public var haveData:Bool = true
    public var cellIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCollectionView()
        
    }
    
    /// 创建collectionView
    public func createCollectionView() {
        
        self.refreshWhenLoad = true
        
        collectionView = UICollectionView.init(frame: collectionViewFrame(), collectionViewLayout: collectionViewFlowLayout())
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        
        registerCell()
        view.addSubview(collectionView!)
        
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        if responds(to: #selector(getter: automaticallyAdjustsScrollViewInsets)) {
            automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
    /// 设置collectionViewFrame
    public func collectionViewFrame() -> CGRect {
        return CGRect.init(x: 0, y: self.navBarBottom, width: kScreenWidth, height: kScreenHeight-self.navBarBottom)
    }
    
    // 注册cell 子类重写
    public func registerCell() {
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    public func collectionViewFlowLayout() -> UICollectionViewFlowLayout {
        return UICollectionViewFlowLayout()
    }
    
    /// 注册刷新头部
    public func registRefreshHeader() {
        let header = RefreshAnimationHeader{ [weak self] in
            self?.loadNewData()
        }
        collectionView?.mj_header = header
        if refreshWhenLoad {
            collectionView?.mj_header.beginRefreshing()
        }
    }
    
    /// 注册刷新尾部
    public func registRefreshFooter() {
        let footer = RefreshAnimationFooter{ [weak self] in
            self?.loadNextPage()
        }
        collectionView?.mj_footer = footer
        collectionView?.mj_footer.isHidden = true
    }
    
    /// 注册头部尾部
    public func registRefreshHeaderAndFooter() {
        registRefreshHeader()
        registRefreshFooter()
    }
    
    
    
    /// MARK: 刷新事件
    private func reloadData() {
        collectionView?.reloadData()
        collectionView?.reloadEmptyDataSet()
    }
    
    /// 开始刷新
    public func refreshWithAnimation() {
        collectionView?.mj_header.beginRefreshing()
    }
    
    /// 结束刷新
    @objc public func endRefreshAnimation() {
        endRefreshWithCount(0)
    }
    
    public func endHeaderRefreshing() {
        guard let header = collectionView?.mj_header else {
            return
        }
        if header.isRefreshing {
            collectionView?.mj_header.endRefreshing()
        }
        haveData = self.dataArray.count > 0 ? true : false
        reloadData()
    }
    
    
    
    public func endRefreshWithCount(_ count: Int) {
        guard let header = collectionView?.mj_header else {
            return
        }
        if header.isRefreshing {
            collectionView?.mj_header.endRefreshing()
        }
        guard let footer = collectionView?.mj_footer else {
            return
        }
        if footer.isRefreshing {
            collectionView?.mj_footer.endRefreshing()
        }
        
        let isNoMoreData = count < perpageCount || count == 0
        collectionView?.mj_footer.isHidden = isNoMoreData
        
        haveData = self.dataArray.count > 0 ? true : false
        reloadData()
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
        self.collectionView?.register(UINib.init(nibName: cellClassString, bundle: nil), forCellWithReuseIdentifier: cellClassString)
        self.cellIdentifier = cellClassString
    }
    public func registerCellClass(_ cellClassString:AnyClass) {
        self.collectionView?.register(cellClassString, forCellWithReuseIdentifier: "\(cellClassString)")
        self.cellIdentifier = "\(cellClassString)"
    }
    
    deinit {
        
    }
}


extension  BaseCollectionController : UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
}

extension  BaseCollectionController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "empty_placeholde_happy_image")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "暂无数据"
        let attributes:[NSAttributedString.Key:AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 14),NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.init(hexString: "3c3e42")]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 0
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return !haveData
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> UIImage! {
        
        return UIImage(name: "")
        
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        
        
    }
    
}

