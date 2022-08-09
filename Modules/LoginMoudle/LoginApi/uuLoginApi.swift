//
//  LoginApi.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/11.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit


enum UULoginApi {
    ///用户协议
     case getUserProtocol
    ///获取验证码
    case getCode
    ///登录
     case login
}

extension UULoginApi: BaseApi {
    var path: String {
        
        switch self {
        case .getUserProtocol:
            return "app_ry.php?act=getServiceProtocol"
        case .getCode:
            return "user/user.php?act=sendSsoCode"
        case .login:
            return "user/user.php?act=login"
        }
    }
}
