//
//  RxCollectionController.swift
//  UUStudent
//
//  Created by Asun on 2020/8/18.
//  Copyright © 2020 UUabc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HandyJSON

class RxCollectionController: RxBaseController {
    
    public var collectionView: UICollectionView!
    
    public var dataArray: BehaviorRelay<[RxBaseModel?]> = BehaviorRelay.init(value: [])
    
    public var emptyStatu: PublishSubject<EmptyDataType> = PublishSubject<EmptyDataType>()
    
    public var cellIdentifier = "cell"
    
    public var limitCount: Int = 18
    
    public var requestCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCollectionView()
        onceLoadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eachLoadData()
    }
    
    public func getSource() -> [RxBaseModel?]? {
        guard self.dataArray.value.count > 0 else { return []}
        return self.dataArray.value
    }
    
    /// 创建TableView并添加
    public func createCollectionView() {
        collectionView = UICollectionView.init(frame: collectionViewFrame(), collectionViewLayout: collectionViewFlowLayout())
        guard let col = collectionView else {
            print("=== CollectionView Nil ===")
            return
        }
        col.backgroundColor = UIColor.clear
        col.showsHorizontalScrollIndicator = false
        col.showsVerticalScrollIndicator = false
        
        col.dataSource = self
        col.delegate = self
        view.addSubview(col)
    }
    
    public func collectionViewFlowLayout() -> UICollectionViewFlowLayout {
        return UICollectionViewFlowLayout()
    }
    
    public func eachLoadData() {}
    
    public func onceLoadData() {}
    
    /// TableViewFrame
    /// - Returns: Frame
    public func collectionViewFrame() -> CGRect {
        return CGRect.init(x: 0, y: self.navBarHeight, width: kScreenWidth, height: kScreenHeight-self.navBarHeight)
    }
    
    /// 注册CellClass
    /// - Parameter cellClassString: 注册的Cell
    public func registerCellClass(_ cellClassString:AnyClass) {
        self.collectionView?.register(cellClassString, forCellWithReuseIdentifier: "\(cellClassString)")
        self.cellIdentifier = "\(cellClassString)"
    }
    
    public func registerCellNib(_ cellClassString:String) {
        self.collectionView?.register(UINib.init(nibName: cellClassString, bundle: nil), forCellWithReuseIdentifier: cellClassString)
        self.cellIdentifier = cellClassString
    }
    
    /// 下拉刷新
    /// - Returns: 没有就创建
    public func headerRefresh() -> Driver<Void>? {
        guard let col = self.collectionView else { return nil }
        return col.rx.headerRefreshing
    }
    
    /// 上拉加载 没有就创建
    /// - Returns:  上拉加载事件
    public func footerRefresh() -> Driver<Void>? {
        guard let col = self.collectionView else { return nil }
        return col.rx.footerRefreshing.asDriver()
    }
    
    public func footerEndState() -> Binder<(Int,Int)>{
        self.collectionView.rx.footerEndRefreshNodata
    }
    
    public func refresh(_ emptyStatu: EmptyDataType = .Success) {
        collectionView.rx.beginReloadData.onNext(())
        collectionView.rx.isShowRetryView.onNext(emptyStatu)
    }
    
    /// 点击Cell
    /// - Returns: 返回下标
    public func selectCell() -> Observable<IndexPath>? {
        guard let col = self.collectionView else { return nil}
        return col.rx.itemSelected.debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).observeOn(MainScheduler.instance).subscribeOn(MainScheduler.instance)
    }
}

extension RxCollectionController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (ScreenWidth - 15)/2
        if isIpad {
            return CGSize(width: itemWidth, height: itemWidth+5)
        } else {
            return CGSize(width: itemWidth, height: itemWidth+25)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 7.5, bottom: 0, right: 7.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
