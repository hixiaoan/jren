//
//  ApiService.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/2.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

//typealias RequestSingle = Single<Any>
//fileprivate let designatedPath: String = "jsondata"
//fileprivate let statusCode: String = "code"
//fileprivate let tipMessage: String = "msg"
//
////open class RequestSessionManager {
////    static var manager:Alamofire.SessionManager = {
////        let config = URLSessionConfiguration.default
////        config.timeoutIntervalForRequest = 10  // seconds
////        config.timeoutIntervalForResource = 10
////        config.timeoutIntervalForResource = config.timeoutIntervalForRequest
////        Alamofire.SessionManager.default.delegate.taskWillPerformHTTPRedirection = nil
////        return Alamofire.SessionManager(configuration: config)
////    }()
////}
//
//enum RequestLoadingType {
//    case defult
//}
//
//enum BaseUrlType {
//    case nomal
//    case TestCase
//}
//
////protocol RequestProtocol {
////    ///请求类型
////    var reuestType: HTTPMethod {set get}
////    ///请求URL
////    var requestUrl: String{set get}
////    /// loading 类型
////    var requestLoadingType: RequestLoadingType{set get}
////    ///请求参数
////    var params : [String: Any]? {set get}
////    ///baseUrl
////    var baseUrl: String {set get}
////    ///baseUrlTYpe
////    var baseType : BaseUrlType {set get}
////    
////}` 
//
// open class RxApiService{
//      
//    static let instance = RxApiService()
//    private init() {}
//}
//
//extension RxApiService: ReactiveCompatible {}
//
//extension Reactive where Base: RxApiService{
//
//    
//    private func netRequest<T: RequestModel>(reuqestModel: T,encoding: ParameterEncoding = JSONEncoding.default) ->RequestSingle{
//        RequestSessionManager.manager.delegate.sessionDidReceiveChallenge = { session, challenge in
//            return (URLSession.AuthChallengeDisposition.useCredential,URLCredential(trust:challenge.protectionSpace.serverTrust!))
//        }
//        return Single<Any>
//                    .create { single in
//                         //MARK: Header 暂未配置，弹窗暂未配置 ，Token失效暂未配置
//                        let cancellable = RequestSessionManager.manager.request(
//                            reuqestModel.baseUrl.appending(reuqestModel.requestUrl),
//                            method: reuqestModel.reuestType,
//                            parameters: reuqestModel.params,
//                            encoding: JSONEncoding.default,
//                            headers: HttpHeaderConfig.getHeader()
//                        ).responseData { (result) in
//                        
//                            switch result.result {
//                            case .success(let data):
//                                if let json = try? JSON(data: data) {
//                                    let code = json[statusCode].intValue
//        //                            /// 判断请求是否成功
//                                    if code == 200 || code == 0{
//                                        prints("url:\n \(reuqestModel.baseUrl.appending(reuqestModel.requestUrl)) \n response: \n \(json.rawString() ?? "")")
//                                        single(.success(json.rawString() ?? ""))
//                                    } else {
//                                        // code不为200时  包含登录失效
//                                        if code == 4301 || code == 400 {
//                                          //MARK: 登录失效
//                                        } else {
//                                            single(.error(OLError.serverError(code: code, errorMessage: json[tipMessage].stringValue, type: .Service)))
//                                       // MARK: 后台错误 code
//                                        }
//                                    }
//                                } else {
//                                     //MARK: 服务器错误
//                                    single(.error(OLError.serverError(code: 111111, errorMessage: "服务器返回数据异常", type: .Service)))
//                                }
//                            case .failure(let error):
//                                let code = (error as NSError).code
//                                if code == -1009{
//                                     //MARK: 网络错误 提示
//                                }
//                                single(.error(OLError.networkError(error)))
//                            }
//
//                        }
//                        return Disposables.create {
//                            cancellable.cancel()
//                        }
//                }
//    }
//    
//    
//}
//
//struct HttpHeaderConfig {
//    static func getHeader() ->HTTPHeaders{
//                  let token:String = UserTool.shared.token ?? ""
//                  var header = HTTPHeaders()
//                  if !token.isEmpty {
//                   
//                      header["Authorization"] = token
//                  }else {
//                      header = ["x-visitor" : "1"]
//                  }
//                  header["x-device-info"] = Self.getDeviceInfo()
//                  return header
//              }
//           
//           static func getDeviceInfo() -> String {
//                  var dict:[String:Any] = [:]
//                  dict["DeviceModel"] = Device.deviceModel
//    //              dict["DeviceRatio"] = Device.ratio
//                  dict["DeviceOS"] = Device.sysName
//                  dict["AppVersion"] = Device.appVersion
//                  dict["TimeStamp"] = Date().timeIntervalSince1970
//    //              dict["IPAddress"] = Device.ipAddress
//                  dict["DeviceID"] = Device.deviceUUID
//                  return (dict as NSDictionary).mj_JSONString()
//              }
//}
//
//public enum OLError: Error {
//    // 网络错误
//    case networkError(Error)
////    // 解析失败
////    case analyticalModel(EmptyDataType)
//    // 无数据
//    case resultNoData
//    // 服务错误
//    case serverError(code: Int, errorMessage: String, type: EmptyDataType)
//    
//}
//public enum EmptyDataType:Int {
//    case TimeOut = -100// 超时
//    case Network = -200// 网络出错
//    case NoData = -300// 没有数据
//    case Service = -400// 服务器接口出错
//    case NotLogin = -500 // 没有登录
//    case Success = 200 //请求成功
//}
//
//
