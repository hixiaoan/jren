//
//  SmsLoginViewModel.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/14.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit


class SmsLoginApiService{
    
    ///验证码请求
    lazy var codeRequest = Action<[String: Any], UULoginModel>.init { (dic) -> Observable<UULoginModel> in
        RxProvider.instance.rx.requestEducation(url: UULoginApi.getCode, parameters: dic).asObservable().mapObject(UULoginModel.self)
    }
    ///登录请求
    lazy var loginRequest = Action<[String: Any],UULoginModel>.init { (dic) -> Observable<UULoginModel> in
        RxProvider.instance.rx.requestEducation(url: UULoginApi.login, parameters: dic).asObservable().mapObject(UULoginModel.self)
    }
}


class VaildSmsManager {
    
    func validPhoneText(text: String) -> Bool {
        return text.length == 11 ? true : false
    }
    
    func getCodeBtnModelWithPhone(_ text: String) -> Observable<CodeBtnModel> {
        var model = CodeBtnModel()
        
        if validPhoneText(text: text) {
            model.isCanAction = true
            model.borderColor = Theam.Color.blue.cgColor
            model.titleColor = Theam.Color.blue
        }else{
            model.isCanAction = false
            model.borderColor =  UIColor(hexString: "#C8C8C8").cgColor
            model.titleColor = UIColor(hexString: "#C8C8C8")
        }
        return Observable.just(model)
    }
    
    func vaildCodeText(str: String) -> Bool {
        return str.count == 6 ? true: false
    }
    
    func getLogBtnConfigModel(phone: String,code: String) -> LoginBtnModel {
        var model = LoginBtnModel()
        if validPhoneText(text: phone), vaildCodeText(str: code) {
            model.isCanAction = true
            model.backgroundColor = "3D7AFF"
        }else{
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


struct CodeBtnModel {
    var borderColor: CGColor = UIColor(hexString: "#C8C8C8").cgColor
    var isCanAction = false
    var titleColor : UIColor    = UIColor(hexString: "#C8C8C8")
}

struct LoginBtnModel {
    var isCanAction = false
    var backgroundColor = "B0C9FF"
}


class SmsLoginViewModel{

    let input = Input()
    let output = Output()
    let vailedManager : VaildSmsManager
    
    struct Input {
        ///手机号
        var phoneNum = PublishSubject<String>()
        ///验证码
        var vaildCode = PublishSubject<String>()
        ///定时器
        var codeBtnAction = PublishSubject<Void>()
        ///登录
        var loginBtnAction = PublishSubject<Void>()
    }
    
    struct Output {
        
        let codeBtnConfigOutput = BehaviorSubject(value: CodeBtnModel())
        let loginBtnConfigOutput = BehaviorSubject(value: LoginBtnModel())
        let getCodeOutput = PublishSubject<Bool>()
        let loginRequestOutput = PublishSubject<UULoginModel>()
        let loginBtnAnimation = PublishSubject<Void>()
    }
    
    var requestFaild:Binder<Bool>{
        return Binder(self){ model, state in
            UUProgressHUD.showError(withStatus: "请求失败")
        }
    }
    
    
    init(manager: VaildSmsManager, apiService:SmsLoginApiService, dispose:DisposeBag) {
        
        vailedManager = manager
        ///获取定时器的配置
        input.phoneNum.flatMapLatest { str -> Observable<CodeBtnModel> in
            manager.getCodeBtnModelWithPhone(str)
            }.bind(to: output.codeBtnConfigOutput).disposed(by: dispose)
        
        ///登录按钮配置
        Observable.combineLatest(input.phoneNum,input.vaildCode){ phone, code in
            manager.getLogBtnConfigModel(phone: phone, code: code)
            }.bind(to: output.loginBtnConfigOutput).disposed(by: dispose)
        
        ///获取验证码
        apiService.codeRequest.elements.map{_ in true}.bind(to: output.getCodeOutput).disposed(by: dispose)
        apiService.codeRequest.errors.map {_ in false}.bind(to: output.getCodeOutput).disposed(by: dispose)
        input.codeBtnAction.withLatestFrom(input.phoneNum).map { phone -> [String: Any] in
            var dic = [String: Any]()
            dic["mobile"] = phone
            dic["sms_type"] = 1
            return dic
            }.bind(to: apiService.codeRequest.inputs).disposed(by: dispose)
        
        ///登录请求
        let phoneAndCode = Observable.combineLatest(input.phoneNum,input.vaildCode){
            (phone: $0, code:$1)
        }
        input.loginBtnAction.withLatestFrom(phoneAndCode).map { tuples -> [String: Any] in
            var params = [String: Any]()
            params["username"] = tuples.phone
            params["code"] = tuples.code
            params["device_type"] = 1
            params["device_info"] = Util.getDeviceInfo()
            params["is_student"] = "true"
            params["is_teacher"] = "false"
            params["remeber_me"] = "false"
            params["appType"] = "1"
            return params
            }.bind(to: apiService.loginRequest.inputs).disposed(by: dispose)
        apiService.loginRequest.elements.hideLoading().bind(to: output.loginRequestOutput).disposed(by: dispose)
        apiService.loginRequest.errors.hideLoading().map{_ in ()}.bind(to: output.loginBtnAnimation).disposed(by: dispose)
    }
}
