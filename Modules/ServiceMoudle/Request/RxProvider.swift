//
//  RxProvider.swift
//  UUStudent
//
//  Created by Asun on 2020/7/17.
//  Copyright © 2020 UUabc. All rights reserved.
//

import UIKit


struct RequestField {
    /// 错误码
    static let errorCode: String = "errno"
    /// 提示语
    static let serviceTip: String = "tips"
    
    static let dicObject: String = "jsondata"
    
    static let arrayObject: String = "list"
    
    struct ResourceField {
        /// 错误码
        static let errorCode: String = "code"
        /// 提示语
        static let serviceTip: String = "message"
        
        static let dicObject: String = "data"
    }
    
    struct params {
        static let loginToken: String = "af_token"
    }
    /// 后台返回Code
    struct RequestCodeNumber {
        static let requestSuccess = 0
        static let requestRelogin = 3005
    }
}

/// 请求实例
open class RxProvider {
    static let instance = RxProvider()
    private init() {}
}

extension RxProvider: ReactiveCompatible {}

protocol RxRequestTarget {
    associatedtype Input
    associatedtype Output
    /// ViewModel 需要构建输入输出参数
    var input: Input { get }
    var output: Output { get }
    /// 销毁序列
    var destructionBag: DisposeBag { get }
}

open class RequestSessionManager {
    static var manager:Alamofire.SessionManager = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        config.networkServiceType = .default
        Alamofire.SessionManager.default.delegate.taskWillPerformHTTPRedirection = nil
        return Alamofire.SessionManager(configuration: config)
    }()
    
    static func createUrlAndHeaders(urlStr: String) -> (url: String, headers: [String: String]){
        let Url = urlStr
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let headers = ["Accept": "application/json; version=\(version)", "token":"\(DefaultsTool.getValue(DefaultsKey.uuToken) ?? "")"]
        return (Url, headers)
    }
}

public extension Reactive where Base: RxProvider {
    
    /// 请求
    /// - Parameters:
    ///   - fullUrl: 遵守BaseApi的协议地址
    ///   - parameters: 入参 可为空
    /// - Returns: 返回信号
    func requestEducation(isResource: Bool = false, url: BaseApi, parameters: [String:Any]?) -> Single<Any>{
        return self.request(isResource: isResource, url, parameters)
    }
    
    func requestUUWithAbc(_ fullUrl: BaseApi, parameters: [String: Any]?) -> Single<Any> {
        return self.requestUWithU(fullUrl, parameters: parameters)
    }
    
    private func requestUWithU(_ urlString: BaseApi,
                               parameters: [String:Any]?)
        -> Single<Any> {
            var para = parameters == nil ? [String: AnyObject]() : parameters!
            para["appVersion"] = Device.appVersion as AnyObject
            para["deviceType"] = Device.modelName as AnyObject
            para["systemVersion"] = Device.sysVersion as AnyObject
            para["deviceUUID"] = Device.deviceUUID as AnyObject
            para["system"] =  "iOS" as AnyObject
            para["appType"] = 2 as AnyObject
            para["user-agent"] = "\(Device.appName ?? "")/\(Device.appVersion ?? "") (iOS; \(Device.sysVersion); \(Device.modelName); \(Device.deviceModel)) " as AnyObject
            let handle = RequestSessionManager.createUrlAndHeaders(urlStr: urlString.path)
            let URL = handle.url
            let headers = handle.headers
            let encoding:ParameterEncoding = JSONEncoding.default
            return Single.create{ single in
                let cancellable = RequestSessionManager.manager.request(URL, method: .post, parameters: para, encoding: encoding, headers: headers).responseJSON { (response) in
                    switch response.result {
                    case .success:
                        prints("数据地址:\(URL) 参数:\(para) 数据数据\(String(describing: response.result.value))")
                        guard let resp:[String:Any] = response.result.value! as? [String:Any] else{
                            single(.error(RxError.analyticalModel(.Service)))
                            return
                        }
                        var isSuccess = resp["isSuccess"] as? Bool
                        if isSuccess == nil {
                            isSuccess = resp["success"] as? Bool
                        }
                        if isSuccess == true, let dicStr = JSON(resp).rawString() {
                            single(.success(dicStr))
                        } else {
                            var message: String = ""
                            if let msg = resp["message"]  {
                                message = msg as? String ?? ""
                            }
                            if let mess = resp["msg"] {
                                message = mess as? String ?? ""
                            }
                            AliCloudLog.shared.putEnterServiceError(requestUrl: URL, reponse: "\(resp)", errorMsg: message, requestParams: para)
                            single(.error(RxError.analyticalModel(.Service)))
                        }
                    case .failure(let error):
                          AliCloudLog.shared.putEnterNetworkError(error: error, requestUrl: URL, requestParams: para)
                            if !URL.contains("/api/mobile/config") {
                                Toast.show(desc: error.showErrorString())
                            }
                        single(.error(RxError.networkError(error)))
                    }
                }
                return Disposables.create {
                    cancellable.cancel()
                }
            }
    }
    
    /// Base请求
    /// - Parameters:
    ///   - fullUrl: 地址
    ///   - parameters: 入参
    /// - Returns: 返回值信号
    private func request(isResource: Bool = false, _ fullUrl: BaseApi, _ parameters: [String:Any]?) -> Single<Any> {
        var requestUrl: String = ""
        
        var parameter: [String:Any] = [:]
        if isResource {
            requestUrl = SSAPI.WeChat_API_Host.appending(fullUrl.path)
        } else {
            requestUrl = SSAPI.SSBaseHost.appending(fullUrl.path)
        }
        if let para = parameters {
            parameter = para
            if isResource {
                parameter[RequestField.params.loginToken] = DefaultsTool.getValue(.resourceToken)
            } else {
                parameter[RequestField.params.loginToken] = DefaultsTool.getValue(DefaultsKey.loginToken)
            }
        } else {
            if isResource {
                parameter[RequestField.params.loginToken] = DefaultsTool.getValue(.resourceToken)
            } else {
                parameter[RequestField.params.loginToken] = DefaultsTool.getValue(DefaultsKey.loginToken)
            }
        }
        return Single
            .create{ single in
                let cancellable = RequestSessionManager.manager.request(requestUrl, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseData { (value) in
                    switch value.result {
                    case .success(let data):
                        if let json = try? JSON(data: data) {
                            prints("url = \(requestUrl)\n,request:\(json.rawValue),\n parameter= \(parameter)")
                            var code: Int = 999
                            if isResource {
                                code = json[RequestField.ResourceField.errorCode].intValue
                            } else {
                                code = json[RequestField.errorCode].intValue
                            }
                            
                            switch code {
                                ///正常返回
                            case 0:
                                single(.success(json.rawString() ?? ""))
                                break
                            ///token 失效
                            case 3005:
                               if !UserTool.shared.isTokenHaveShow {
                                   UserTool.shared.isTokenHaveShow = true
                                   let _ = BKBaseAlertView.show(fromVc: RouterManager.getTopVC(), title: "温馨提示", content: "您的登录有效时间已过期,请您重新登录", cancelBtnTitle: "", confirmBtnTitle: "确定") {
                                       UserTool.shared.isTokenHaveShow = false
                                    RouterManager.againLogin()
                               }
                               }
                                break
                               //否则异常
                               default:
                                /// 服务器错误
                                AliCloudLog.shared.putEnterServiceError(requestUrl: requestUrl, reponse: "\(json)", errorMsg: "服务异常", requestParams: parameter)
                                single(.error(RxError.serverError(.Service)))
                                Toast.show(desc: json[RequestField.serviceTip].string ?? "")
                                   break
                            }
                        } else {
                            single(.error(RxError.serverError(.Service)))
                            if let str = String(data: data, encoding: String.Encoding.utf8) {
                                Toast.show(desc: str)
                            }
                        }
                    case .failure(let error):
                         AliCloudLog.shared.putEnterNetworkError(error: error, requestUrl: requestUrl, requestParams: parameter)
                         Toast.show(desc: error.showErrorString())
                         single(.error(RxError.networkError(error)))
                    }
                }
                return Disposables.create {
                    cancellable.cancel()
                }
        }
    }
    
     func abnormalRequest(url: String, parameters: [String:Any]?) -> Single<Any> {
        return Single
            .create{ single in
                let cancellable = RequestSessionManager.manager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (value) in
                    switch value.result {
                    case .success(let data):
                        if let json = try? JSON(data: data) {
                            prints("url = \(url)\n,request:\(json.rawValue),\n parameter= \(String(describing: parameters))")
                             single(.success(json.rawString() ?? ""))
                        } else {
                            single(.error(RxError.serverError(.Service)))
                            if let str = String(data: data, encoding: String.Encoding.utf8) {
                                Toast.show(desc: str)
                            }
                        }
                    case .failure(let error):
                         Toast.show(desc: error.showErrorString())
                        single(.error(RxError.networkError(error)))
                    }
                }
                return Disposables.create {
                    cancellable.cancel()
                }
        }
    }
//    func getAppleVersion() -> Single<Bool> {
//        return Single.create { single in
//            let cancellable = Alamofire.request(Api.appstoreURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    print(json)
//                    let appStoreVersion = json["results"][0]["version"].stringValue
//                    let localVersion = Device.appVersion as! String
//                    /// 如果当前版本不等于AppStore版本，在审核，展示原生页面
//                    if appStoreVersion != localVersion {
//                        single(.success(true))
//                    } else {
//                        single(.success(false))
//                    }
//                } else {
//                    /// 请求失败展示原生页面
//                    single(.success(false))
//                }
//            }
//            return Disposables.create {
//                cancellable.cancel()
//            }
//        }
//        
//    }
    
    func needreLogin(_ msg:String) {
        let a1 = AlertAction(style: .default, title: "确认") {
            DefaultsTool.userLoginout()
//            DefaultsTool.errorForwardLogin()
        }
        let alert = Alert(title: "温馨提示", message: msg, tapDismiss: false)
        alert.addAction(a1)
        alert.show()
    }
}

