//
//  LearnCenterApi.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/10/14.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

enum LearnCenterApi {
    /// 作业列表
     case homeListUrl
}

extension LearnCenterApi : BaseApi {
    var path: String {
        switch self {
        case .homeListUrl:
             return "courseware/courseware.php?act=getTopicStatus"
        }
    }
}
