//
//  HomeApi.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/7.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

enum HomeApi {
    /// 预约课
    case orderClassUrl
    ///选课弹窗接口
    case choseClassUrl
    ///是否有预约课
     case isHaveClass
    ///课程信息
    case classInfoUrl
    ///获取Ub
    case get_user_account
    ///获取用户信息
    case getUserInfo
}

extension HomeApi: BaseApi {
    var path: String {
        switch self {
        case .orderClassUrl:
            return "course/chooseCourse.php?act=getStudentFeeListWithSeasonList"
        case .choseClassUrl:
            return "student/student.php?act=hasChooseClass"
        case .isHaveClass:
            return "course/classTimes.php?act=getDesktopCourseInfo"
        case .classInfoUrl:
            return "classroom/classroom.php?act=createRoom"
        case .get_user_account:
            return "student/student.php?act=get_user_account"
        case .getUserInfo:
            return "user/user.php?act=getUserInfo"
        }
    }
}

