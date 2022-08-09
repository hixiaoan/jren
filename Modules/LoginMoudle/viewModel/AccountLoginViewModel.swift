//
//  AccountLoginViewModel.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/15.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxSwift

class AccountApiService {
    ///登录请求
       lazy var loginRequest = Action<[String: Any],UULoginModel>.init { (dic) -> Observable<UULoginModel> in
           RxProvider.instance.rx.requestEducation(url: UULoginApi.login, parameters: dic).asObservable().mapObject(UULoginModel.self)
       }
}

class AccountVaildTool {
    
    func validPhoneText(text: String) -> Bool {
        return text.length == 11 ? true : false
    }
    
    func passordVaild(pass: String) -> Bool {
        return pass.length >= 6 ? true : false
    }
    
    func getLogBtnConfigModel(phone: String,passW: String) -> LoginBtnModel {
        var model = LoginBtnModel()
        if validPhoneText(text: phone), passordVaild(pass: passW) {
            model.isCanAction = true
            model.backgroundColor = "3D7AFF"
        } else {
            model.isCanAction = false
            model.backgroundColor = "B0C9FF"
        }
        return model
    }
    
    func loginSuccessConfig(_ loginModel: UULoginModel)  {
           
           let tool = UserTool.shared
           var model:Jsondata = loginModel.jsondata
           tool.mini_token = model.mini_token
           tool.username = model.username
           tool.password = model.password
           tool.uuid = model.uuid
           tool.uuidString = "\(model.uuid)"
           tool.uid = model.uid
           tool.avatars = model.avatars
           tool.gql_token = model.gql_token
           tool.sex = model.sex
           tool.birthday = model.birthday
           tool.age = model.age
           tool.englishName = model.englishName
           
           if Util.isTelNumber(num: model.nickname) {
               tool.nickname = ""
               model.nickname = ""
           }else{
               tool.nickname = model.nickname
           }
           
           UUuserDefault.sharedInstance.name = model.nickname
           UUuserDefault.sharedInstance.gqltoken = model.gql_token
           UUuserDefault.sharedInstance.avater = model.avatars
           UUuserDefault.sharedInstance.socketUid = model.uid
           UUuserDefault.sharedInstance.af_token = model.af_token
           
           let hasNotFinishInfo = (model.nickname.isEmpty || model.birthday.isEmpty || model.sex.isEmpty)
           tool.hasFinishInfo = !hasNotFinishInfo
           
          
           JPUSHService.setAlias("\(model.uuid)", completion: { (iResCode, iAlias, seq) in
               print("iResCode:\(iResCode)iAlias:\(iAlias)")
           }, seq: 0)
           
       }
}

class AccountLoginViewModel{
    
    let intput = Intput()
    let output = Output()
    let vailedManager : AccountVaildTool
    struct Intput {
        ///手机号
        let phoneNum  = PublishSubject<String>()
        /// 密码
        let passwordNum = PublishSubject<String>()
        ///登录btn
        let logBtnAction = PublishSubject<Void>()
        
    }
    
    struct Output {
        let phoneTextConfig = BehaviorRelay(value: UserTool.shared.username ?? "")
        let loginBntConfig  = BehaviorRelay(value: LoginBtnModel())
        let loginRequestOutput = PublishSubject<UULoginModel>()
        let loginBtnAnimation = PublishSubject<Void>()
    }
    
    init(apiService: AccountApiService,tool: AccountVaildTool,dispose:DisposeBag) {
        
        vailedManager = tool
        Observable.combineLatest(intput.phoneNum,intput.passwordNum){phone,passW in
            tool.getLogBtnConfigModel(phone: phone, passW: passW)
            }.bind(to: output.loginBntConfig).disposed(by: dispose)
       
        intput.logBtnAction.withLatestFrom(Observable.combineLatest(intput.phoneNum,intput.passwordNum)).map { tuples -> [String: Any] in
            var params:[String:Any]  = [:]
            params["username"] = tuples.0
            params["password"] = tuples.1
            params["device_type"] = 1
            params["device_info"] = Util.getDeviceInfo()
            params["is_student"] = "true"
            params["is_teacher"] = "false"
            params["remeber_me"] = "false"
            params["appType"] = "1"
            return params
            }.bind(to:apiService.loginRequest.inputs).disposed(by: dispose)
        apiService.loginRequest.elements.bind(to: output.loginRequestOutput).disposed(by: dispose)
        apiService.loginRequest.checkError.map{_ in ()}.bind(to: output.loginBtnAnimation).disposed(by: dispose)
    }

}
