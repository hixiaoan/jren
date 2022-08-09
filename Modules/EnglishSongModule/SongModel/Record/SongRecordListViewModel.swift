//
//  SongRecordListViewModel.swift
//  UUEnglish
//
//  Created by Asun on 2020/9/17.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxSwift
import Action
import RxCocoa
import HandyJSON

struct SongRecordListService {
    /// 请求Action
    lazy var getRecordLisrt = Action<Int,SongRecordListModel>.init { (body) -> Observable<SongRecordListModel> in
        return RxProvider.instance.rx.requestEducation(isResource: true, url: SongApi.recordList, parameters: ["sort":["edit_time":"desc"].toString(), "page":body, "per-page":18]).asObservable().mapObject(SongRecordListModel.self, "data")
    }
}

class SongRecordListViewModel {
    let input = Input()
    var output = Output()
    /// 请求
    var service: SongRecordListService!
    
    struct Input {
        /// 下拉刷新事件
        let headerRefresh = PublishSubject<Void>()
        /// 上拉刷新事件
        let footerRefresh = PublishSubject<Void>()
        /// 重试事件
        let retry = PublishSubject<Void>.init()
    }
    
    struct Output {
        ///数据源输出
        let dataSource = BehaviorSubject<[SongRecordListCellViewModel]>(value: [])
        /// 空数据视图输出
        lazy var emptyData: BehaviorSubject<EmptyDataType> = BehaviorSubject<EmptyDataType>(value: .Success)
        /// 上拉刷新状态输出
        lazy var footerState: PublishSubject<(Int,Int)> = PublishSubject<(Int,Int)>()
    }
    
    /// 实例化方法
    /// - Parameters:
    ///   - pageStatu: 当前为哪个儿歌页面
    ///   - apiService: 请求示例
    ///   - dispose: 跟随控制器Deinit
    init(pageStatu: SongSegmentStatus, apiService: SongRecordListService, dispose: DisposeBag) {
        service = apiService
        let page = BehaviorSubject.init(value: 1)
        /// 请求数据 + 翻页 + 数组自增
        service.getRecordLisrt.elements
            .hideLoading()
            .map { (item) -> [SongRecordListCellViewModel] in
                item.list.map{
                    SongRecordListCellViewModel($0, pageStatu)
                }
            }
            .do(onNext: { (_) in
                page.onNext(try! page.value() + 1)
                print("当前页\(try! page.value())")
            })
            .scan([], accumulator: {
                return (try! page.value() == 1) ? $1 : $0 + $1
            })
            .bind(to: output.dataSource)
            .disposed(by: dispose)
        
        /// 返回底部刷新状态
        service.getRecordLisrt.elements.map{ (item) -> (Int,Int) in
            return (item.list.count,18)
        }.bind(to: output.footerState).disposed(by: dispose)
        
        /// 返回值 + 当前页面 返回空数据视图状态展示
        Observable.combineLatest(service.getRecordLisrt.elements, page).asObservable().map { (model,page) -> EmptyDataType in
            if model.list.count == 0, page == 1 {
                return .NoData
            }
            return .Success
        }.bind(to: output.emptyData).disposed(by: dispose)
        
        /// 底部刷新 合并 页码 绑定请求
        input.footerRefresh
            .withLatestFrom(page)
            .bind(to: service.getRecordLisrt.inputs)
            .disposed(by: dispose)
        
        /// 请求错误 + 页码 返回空数据视图展示
        Observable.combineLatest(service.getRecordLisrt.checkError, page).asObservable().map { (type,page) -> EmptyDataType in
            return page == 1 ? type : .Success
        }.bind(to: output.emptyData).disposed(by: dispose)
        
        /// 请求错误 返回底部刷新状态
        service.getRecordLisrt.checkError.hideLoading().map{ _ in
            return (0,0)
        }.bind(to: output.footerState).disposed(by: dispose)
        
        /// 头部刷新 更新页面 绑定请求
        input.headerRefresh.showLoading().map({ (_) in
            page.onNext(1)
            return 1
        }).startWith(1).bind(to: service.getRecordLisrt.inputs)
        .disposed(by: dispose)
        
        ///重试事件
        input.retry.withLatestFrom(page).bind(to: service.getRecordLisrt.inputs).disposed(by: dispose)
    }
}

