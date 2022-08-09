//
//  MusicCenterViewModel.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/25.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

class MusicCenterApiService {
    
    var page = 1
    lazy var listRequest = Action<Int,MusicCenterModel>.init { (body) -> Observable<MusicCenterModel> in
        RxProvider.instance.rx.requestEducation(isResource: true, url: SongApi.musicCenter, parameters: ["page":body,"per-page":18]).asObservable().mapObject(MusicCenterModel.self, "data")
    }
}

class MusicCenterViewModel{
    
   lazy var input = Input()
   lazy var output = Output()
   lazy var apiService = MusicCenterApiService()
    
    struct Input {
        ///当前请求页码
        lazy var dataRequestPage = BehaviorSubject(value: 1)
        /// 下拉刷新事件
        lazy var headerRefresh = PublishSubject<Void>()
        /// 上拉刷新事件
        lazy var footerRefresh = PublishSubject<Void>()
        /// 重试事件
        lazy var retry = PublishSubject<Void>.init()
    }
    
    struct Output {
        ///下拉刷新数据输出
        lazy var listDataOutput = PublishSubject<(MusicCenterModel,Int)>()
        ///下拉刷新数据输出
        lazy var footerRequestDataOutput = PublishSubject<MusicCenterModel>()
        lazy var requestError = PublishSubject<ActionError>()
        /// 空数据视图输出
       lazy var emptyData: BehaviorSubject<EmptyDataType> = BehaviorSubject<EmptyDataType>(value: .Success)
       /// 上拉刷新状态输出
       lazy var footerState: PublishSubject<(Int,Int)> = PublishSubject<(Int,Int)>()
    }
    
    init(dispose:DisposeBag) {
        
        ///服务错误
        apiService.listRequest.errors.hideLoading().bind(to: output.requestError).disposed(by: dispose)
        ///正常请求数据
        apiService.listRequest.elements.hideLoading().map{($0,self.apiService.page)}.bind(to: output.listDataOutput).disposed(by: dispose)
        ///下拉刷新
        input.headerRefresh.startWith(()).showLoading().map{_ in
            self.apiService.page = 1
            return 1
        }.bind(to: apiService.listRequest.inputs).disposed(by: dispose)
        ///上拉刷新
        input.footerRefresh.showLoading().map{ _ in
            self.apiService.page += 1
            return self.apiService.page
        }.bind(to: apiService.listRequest.inputs).disposed(by: dispose)
        ///重试事件
        input.retry.map{_ in self.apiService.page}.bind(to: apiService.listRequest.inputs).disposed(by: dispose)
    }

}
