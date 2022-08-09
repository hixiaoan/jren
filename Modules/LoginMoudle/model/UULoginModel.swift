//
//  UULoginModel.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/11.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

struct UULoginModel: HandyJSON {
    var tips: String = ""
    var errno : Int = 111111
    var jsondata : Jsondata = Jsondata()
}

struct Jsondata : HandyJSON{
    
    var url : String = ""
    var login_page: [Int]?
       var birthday: String = ""
       var token: String = ""
       var status: String = ""
       var app_ids: [App_ids] = []
       var nickname: String = ""
       var avatars: String = ""
       var userId: String = ""
       var sex: String = ""
       var mini_token: String = ""
       var uuid: Int = 0
       var af_token: String = ""
       var password: String = ""
       var gql_token: String = ""
       var decription: String = ""
       var uid: String = ""
       var rYtoken: String = ""
       var user_type: Int = 0
       var identity: String = ""
       var utypecn: String = ""
       var englishName: String = ""
       var access_token: String = ""
       var utype: String = ""
       var username: String = ""
       /// 测试等级
       var test_level: String = ""
       /// 等级
       var st_class: String = ""
       var age: String = ""
    
}
