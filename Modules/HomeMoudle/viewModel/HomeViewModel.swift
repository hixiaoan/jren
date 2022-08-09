//
//  HomeViewModel.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/7.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxSwift

class HomeApiService{
    
    var ubRowValue: String = ""
    ///预约课请求
    lazy var orderClassRequest = Action<Void,OrderClassModel>.init { (_) -> Observable<OrderClassModel> in
        RxProvider.instance.rx.requestEducation(url:HomeApi.orderClassUrl, parameters: nil).asObservable().mapObject(OrderClassModel.self)
    }
    
    ///选课弹窗显示接口
    lazy var choseClassRequest = Action<Void,OrderClassModel>.init { (_) -> Observable<OrderClassModel> in
        RxProvider.instance.rx.requestEducation(url: HomeApi.choseClassUrl, parameters: nil).asObservable().mapObject(OrderClassModel.self)
    }
    ///是否有预约课
    lazy var isHaveOrderClassRequest = Action<Void, Any>.init { (_) -> Observable<Any> in
        RxProvider.instance.rx.requestEducation(url: HomeApi.isHaveClass, parameters: nil).asObservable()
    }
    
    ///课程信息
    lazy var classInfoRequest = Action<[String: Any],OrderClassModel>.init { (dic) -> Observable<OrderClassModel> in
        RxProvider.instance.rx.requestEducation(url: HomeApi.classInfoUrl, parameters: dic).asObservable().mapObject(OrderClassModel.self)
    }
    ///U币接口
    lazy var uBRequest = Action<Void,OrderClassModel>.init { (_) -> Observable<OrderClassModel> in
        RxProvider.instance.rx.requestEducation(url: HomeApi.get_user_account, parameters: nil).asObservable().mapObject(OrderClassModel.self)
    }
    
    ///获取用户信息
    lazy var userInfoRequest = Action<Void, OrderClassModel>.init { (_) -> Observable<OrderClassModel> in
        RxProvider.instance.rx.requestEducation(url: HomeApi.getUserInfo, parameters: nil).asObservable().mapObject(OrderClassModel.self)
    }
    
    ///appstore 请求
    lazy var appstoreRequest = Action<Void,AppStoreModel>.init { (_) -> Observable<AppStoreModel> in
        RxProvider.instance.rx.abnormalRequest(url: "https://itunes.apple.com/lookup?bundleId=com.uuabc.UUOnlineTeaching", parameters: nil).asObservable().mapObject(AppStoreModel.self)
    }
    
}

class HomeLogic{
    
    lazy var isShow = false
    lazy var hasShow = false
    
    func judgeIsShow(){
        var key:String
        let model = UserTool.shared
        if model.uid?.length ?? 0 > 0 {
            key = "select_course_alert_\(model.uid!)"
        }else{
            key = "select_course_alert"
        }
        let lastData : String = UserDefaults.standard.object(forKey: key) as? String ?? ""
        if !lastData.isEmpty {
            if !lastData.date__YMd.isToday(){
                self.isShow = true
            }else{
                isShow = false
            }
        }else{
            isShow = true
        }
    }
    
    func saveAlertShowDay(){
        let model = UserTool.shared
        var key : String
        if model.uid?.isEmpty ?? true {
            key = "select_course_alert"
        }else{
            key = "select_course_alert_\(model.uid!)"
        }
        let today = DateFormatter()
        today.dateFormat = "yyyy-MM-dd"
        let dateStr =  today.string(from: Date())
        UserDefaults.standard.set(dateStr, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func stringValueDic(_ str: String) -> [String : Any]?{
           let data = str.data(using: String.Encoding.utf8)
           if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
               return dict
           }
           return nil
       }
}

class HomeViewModel {
    
    let input       = Input()
    let output      = Output()
    let business    = HomeLogic()
    
    struct Input {
        
        let beginClass = PublishSubject<ListNewModel>()
        ///app接口启动
        let gotoAppStoreRequestInput = PublishSubject<Void>()
    }
    
    struct Output {
        
        let checkUserInfoOutput     = PublishSubject<Void>()
        let orderClassOutput        = PublishSubject<OrderClassModel>()
        let choseClassOutput        = PublishSubject<OrderClassModel>()
        let isHaveClassOutput       = PublishSubject<Any>()
        let handlerClassOutPut      = PublishSubject<ListNewModel>()
        let classInfoOuput          = PublishSubject<OrderClassModel>()
        let ubRequestDataOutput     = PublishSubject<Void>()
        let userInfoOutput          = PublishSubject<(String,OrderClassModel)>()
        let appStoreResultOutput    = PublishSubject<Bool>()
    }
    
    init(orderClass:Observable<Void>,
         isHaveClass: Observable<Bool>,
         getUserUPoint: Observable<Void>,
         apiService: HomeApiService,
         dispose: DisposeBag) {
        
        apiService.orderClassRequest.errors.hideLoading().asObservable().map{_ in
            var model = OrderClassModel()
            model.isRequestSccussed = false
            return model
        }.bind(to: output.orderClassOutput).disposed(by: dispose)
        
        apiService.orderClassRequest.elements.hideLoading().bind(to: output.orderClassOutput).disposed(by: dispose)
        Observable.merge(orderClass,output.checkUserInfoOutput).showLoading().bind(to: apiService.orderClassRequest.inputs).disposed(by: dispose)
        
        
        apiService.choseClassRequest.elements.hideLoading().bind(to: output.choseClassOutput).disposed(by: dispose)
        apiService.choseClassRequest.errors.hideLoading().map{_ in
          var model =  OrderClassModel()
            model.isRequestSccussed = false
            return model
        }.bind(to: output.choseClassOutput).disposed(by: dispose)
        business.judgeIsShow()
        if !business.hasShow && business.isShow {
            Observable.just(0).showLoading().map{_ in }.bind(to: apiService.choseClassRequest.inputs).disposed(by: dispose)
        }
        
        
        apiService.isHaveOrderClassRequest.errors.hideLoading().map{_ in }.bind(to: output.isHaveClassOutput).disposed(by: dispose)
        apiService.isHaveOrderClassRequest.elements.hideLoading().bind(to: output.isHaveClassOutput).disposed(by: dispose)
        isHaveClass.showLoading().map{_ in }.bind(to: apiService.isHaveOrderClassRequest.inputs).disposed(by: dispose)
        
        /// 课程信息
        apiService.classInfoRequest.elements.hideLoading().bind(to: output.classInfoOuput).disposed(by: dispose)
        apiService.classInfoRequest.errors.hideLoading().map{_ in
            var  model = OrderClassModel()
            model.isRequestSccussed = false
            return model
        }.bind(to: output.classInfoOuput).disposed(by: dispose)
        input.beginClass.showLoading().map { model -> [String: Any] in
            var dic = [String: Any]()
            dic["cl_id"] = model.cl_id
            dic["clt_id"] = model.clt_id
            dic["platform"] = "2"
            return dic
        }.bind(to: apiService.classInfoRequest.inputs).disposed(by: dispose)
        
        /// 获取u币-用户信息(无论UB接口成功或者失败都要请求用户信息)
        apiService.userInfoRequest.elements.map{model -> (String,OrderClassModel)  in
            (apiService.ubRowValue, model)
            }.bind(to: output.userInfoOutput).disposed(by: dispose)
        
        apiService.uBRequest.elements.hideLoading().map{model-> Void in
            apiService.ubRowValue = model.jsondata.ucoins
            return ()
        }.bind(to: apiService.userInfoRequest.inputs).disposed(by: dispose)
        
        apiService.uBRequest.errors.hideLoading().map{ _ -> Void in
            apiService.ubRowValue = "0"
            return ()
            }.bind(to: apiService.userInfoRequest.inputs).disposed(by: dispose)
        
        getUserUPoint.showLoading().bind(to:apiService.uBRequest.inputs).disposed(by: dispose)
    
        ///appstore请求
        apiService.appstoreRequest.elements.hideLoading().map{ model ->Bool in
            guard let childModel = model.results.first else{
                return  false
            }
            if childModel.version == (Device.appVersion as? String){
                return true
            }else{
                return false
            }
        }.bind(to: output.appStoreResultOutput).disposed(by: dispose)
        
        apiService.appstoreRequest.errors.hideLoading().map{ _ -> Bool in true}.bind(to: output.appStoreResultOutput).disposed(by: dispose)
        
        input.gotoAppStoreRequestInput.showLoading().bind(to: apiService.appstoreRequest.inputs).disposed(by: dispose)
    }

}
