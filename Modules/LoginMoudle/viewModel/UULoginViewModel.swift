//
//  UULoginViewModel.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/11.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

class UULoginAPiService{
    
    ///用户协议请求
    lazy var userProtocolRequest = Action<Void,UULoginModel>.init { (_) -> Observable<UULoginModel> in
        RxProvider.instance.rx.requestEducation(url: UULoginApi.getUserProtocol, parameters: ["utype": 2]).asObservable().mapObject(UULoginModel.self)
    }
} 

class UULoginViewModel {
    
    let intput = Intput()
    let output = Output()
    let service: UULoginAPiService!
    
    
    struct Intput {
        ///启动用户协议请求
        let startUserRequest = PublishSubject<Void>()
    }
    
    struct Output {
        ///用户协议输出
        let userProtcolOutput = PublishSubject<String>()
    }
    
    var requestFail: Binder<Void>{
        return Binder(self){ _,_ in
            UUProgressHUD.showInfo("请求失败")
        }
    }
    
    init(apiService: UULoginAPiService, dispose: DisposeBag) {
        service = apiService
        apiService.userProtocolRequest.elements.hideLoading().map{$0.jsondata.url}.observeOn(MainScheduler.instance).bind(to: output.userProtcolOutput).disposed(by: dispose)
        apiService.userProtocolRequest.errors.hideLoading().map {_ in ()}.bind(to: requestFail).disposed(by: dispose)
        intput.startUserRequest.showLoading().bind(to: apiService.userProtocolRequest.inputs).disposed(by: dispose)
    }
}
