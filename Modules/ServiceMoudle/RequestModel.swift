//
//  RequestModel.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/2.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

//class RequestModel {
//    
//    ///默认是post
//    var reuestType: HTTPMethod = .post
//    ///请求URL
//    var requestUrl: String = ""
//    ///默认loading类型
//    var requestLoadingType: RequestLoadingType = .defult
//    ///请求参数
//    var params: [String : Any]? = nil
//    
//    var baseType: BaseUrlType = .nomal {
//        willSet(type){
//            switch type {
//            case .nomal:
//                self.baseUrl = SSAPI.SSBaseHost
//                break
//            case .TestCase:
//                self.baseUrl = "wwrwrw"
//                break
//        }
//    }
//    }
//    ///baseUrl
//    var baseUrl = ""
//}
//
//
//extension RequestModel{
//    
//    @discardableResult
//    func reuestType(type: HTTPMethod) -> RequestModel {
//        reuestType = type
//        return self
//    }
//    
//    @discardableResult
//    func requestUrl(url: String) -> RequestModel {
//        requestUrl = url
//        return self
//    }
//    
//    @discardableResult
//    func requestLoadingType(loadingType: RequestLoadingType) -> RequestModel {
//        requestLoadingType = loadingType
//        return self
//    }
//    
//    @discardableResult
//    func params(requestDic: [String:Any]) -> RequestModel {
//        params = requestDic
//        return self
//    }
//    
//    @discardableResult
//    func baseType(type:BaseUrlType) -> RequestModel {
//        baseType = type
//        return self
//    }
//}
