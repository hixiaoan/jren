//
//  ActivityApi.swift
//  UUStudent
//
//  Created by Asun on 2020/7/29.
//  Copyright © 2020 UUabc. All rights reserved.
//

import UIKit

enum ActivityApi {
    case getActivityList
    case getUserLikeActivityShareContent
}

extension ActivityApi: BaseApi {
     var path: String {
        switch self {
        case .getActivityList:
            return "\(SSAPI.ListenTestCenter)\(ActivityCustomApi.list)"
        case .getUserLikeActivityShareContent:
            return "\(SSAPI.ListenTestCenter)\(ActivityCustomApi.shareContent)"
        }
    }
}

struct ActivityCustomApi {
    static let list = "api/activity/checkActitysStatusList"
    static let shareContent = "/api/activity/shareKidsSongAction"
}
