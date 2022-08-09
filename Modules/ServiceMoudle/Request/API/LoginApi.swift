//
//  LoginApi.swift
//  UUStudent
//
//  Created by Asun on 2020/8/12.
//  Copyright © 2020 UUabc. All rights reserved.
//

import UIKit

enum LoginApi {
    /// 登录
    case login
    /// 发送登录验证码
    case sendSsoCode
    /// 校验验证码
    case verifyResetCode
    /// 修改密码
    case resetPassword
}

extension LoginApi: BaseApi {
    var path: String {
        switch self {
        case .login:
            return "user/user.php?act=login"
        case .sendSsoCode:
            return "user/user.php?act=sendSsoCode"
        case .verifyResetCode:
            return "user/user.php?act=verifyResetCode"
        case .resetPassword:
            return "user/user.php?act=resetPassword"
        }
    }
}

