//
//  PersonalCenterApi.swift
//  UUStudent
//
//  Created by Asun on 2020/7/20.
//  Copyright © 2020 UUabc. All rights reserved.
//

import UIKit

enum PersonalCenterApi {
    /// 保存用户头像
    case updateAvater
    /// 获取七牛Token
    case getQiniuToken
    /// 获取用户信息
    case getStudentInfo
    /// 获取U币数量
    case getUserUAccount
    /// 获取未读消息
    case getUnreadMessCount
    /// 获取课时详情
    case getCourseTotal
    /// 获取用户等级测试地址
//    case getLevelTestUrl
    /// 获取用户积分 - UU接口
    case getUseIntegral
}

extension PersonalCenterApi: BaseApi {
    var path: String {
        switch self {
        case .updateAvater:
            return Api.updateUserAvatars
        case .getQiniuToken:
            return Api.getQiniuToken
        case .getStudentInfo:
            return Api.getStudentInfo
        case .getUserUAccount:
            return Api.getUserUAccount
        case .getUnreadMessCount:
            return Api.getUnreadMessCount
        case .getCourseTotal:
            return Api.getCourseTotal
//        case .getLevelTestUrl:
//            return Api.getTestLevelUrl
        case .getUseIntegral:
            return "\(SSAPI.ListenTestCenter)\(UStoreAPI.userPoints)"
        }
    }
}
