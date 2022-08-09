//
//  HomeModel.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/7.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

//["tips_cn": SUCCESS, "errno": 0, "tips": 获取成功, "jsondata": ["from_time_format": , "sub_data": ["cl_name": 孩子接下来没有课程,快帮宝宝约课吧], "class_status": 4, "button_text": 前去约课]]

struct JsonData: HandyJSON {
    
    var url : String = ""
    var has_chose: Int = 11111
    var show_txt : String = ""
    var cl_name : String = ""
    var class_status : Int = 1111
    var button_text: String = ""
    var sub_data: [String: Any] = [:]
    var from_time_format: String = ""
    var token :   String = ""
    var classroomType : Int = 0
    var room_id : String = ""
    var ucoins : String = ""
    var plepay_flag: String = ""
    
    var uid : String = ""
    var uuid: String = ""
    var utype: String = ""
    var username: String = ""
    var nickname: String = ""
    var email: String = ""
    var avatars : String = ""
    var af_token: String = ""
    var sex: String = ""
    var modify_password_time: String = ""
    var name: String = ""
    var enname: String = ""
    var id: String = ""
    var st_sex: String = ""
    var st_birthday: String = ""
    var st_class: String = ""
    var test_level: String = ""
    var birthday: String = ""
    var englishName: String = ""
    var st_class_text: String = ""
    var is_ta: Int = 0
    var mini_token: String = ""
    var recharge_url: String = ""
    var pad_recharge_url: String = ""
    var need_modify_password: Int = 111111
    var gql_token: String = ""
    var age: String = ""
    
    
    
    
    
    
    
//    "uid": "165322",
//    "uuid": "303878881692152883",
//    "utype": "2",
//    "username": "12020042205",
//    "nickname": "帅",
//    "email": "",
//    "avatars": "https://sishu-qiniu.uuabc.com/upfiles/9B3525DC-76DC-41AB-B485-4A4DB04E2B79.jpg",
//    "af_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0aW9uIjoyLCJleHAiOjE1OTk4MDA2MzgsInNzb191dWlkIjoiMzAzODc4ODgxNjkyMTUyODgzIn0.tOXh2TJKGIK6deXvXBcn_-6uor9X1gSmXmQzIEguYfw",
//    "sex": "男",
//    "modify_password_time": "1598524034",
//    "name": "帅",
//    "id": "134535",
//    "enname": "shuai",
//    "st_sex": "男",
//    "st_birthday": "1326384000",
//    "st_class": "10306",
//    "test_level": "",
//    "birthday": "2012-01-13",
//    "englishName": "shuai",
//    "st_class_text": "Lv.1",
//    "is_ta": 0,
//    "mini_token": "OPs_VpdB7HPDNojI3fl3n_0d5PRznQrW",
//    "recharge_url": "http://qa-member-frontend.uuabc.com/#/mobile-recharge?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0aW9uIjoyLCJleHAiOjE1OTk4MDA2MzgsInNzb191dWlkIjoiMzAzODc4ODgxNjkyMTUyODgzIn0.tOXh2TJKGIK6deXvXBcn_-6uor9X1gSmXmQzIEguYfw&firstPage=1",
//    "pad_recharge_url": "http://qa-member-frontend.uuabc.com/#/pad-recharge?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0aW9uIjoyLCJleHAiOjE1OTk4MDA2MzgsInNzb191dWlkIjoiMzAzODc4ODgxNjkyMTUyODgzIn0.tOXh2TJKGIK6deXvXBcn_-6uor9X1gSmXmQzIEguYfw&firstPage=1",
//    "need_modify_password": 1,
//    "gql_token": "b3ifeRZ-ExOz94nFKy-l-mZXWuoo4vta8z33iOGo0FK2zdXicDFIBkcbKhm4PN5LwURZAjVYRglbKU7O5_vWGs2qugdcQ7n3T5JLrWnMEPY"
}

struct OrderClassModel: HandyJSON {
    
//    "tips_cn": SUCCESS, "tips": 操作成功, "jsondata": ["has_chose": 1, "show_txt": ], "errno": 0
    var tips_cn : String = ""
    var errno: Int = 111111
    var jsondata: JsonData = JsonData()
    var isRequestSccussed: Bool = true
    
    
}

struct ListNewModel: HandyJSON {
    
    
    var class_status :Int = 0
    var clt_id: String = ""
    var cl_id: String = ""
    var courseware_id: String = ""
    var button_text: String = ""
    var content_img: String = ""
    var header_img: String = ""
    var type: String = ""
    var record_url:String = ""
    var sub_data:SubDataNewModel = SubDataNewModel()
    var liveroom_type: Int = 0
    var classroomType: Int = 0
    var has_courseware:Int = 0
    var has_courseware_txt : String = ""
    
    
//    /// 1 预习 2 上课 3 复习 4 没有课程
//    @property (nonatomic, assign) NSUInteger class_status;
//    /// clt_id 课程时间id
//    @property (nonatomic, copy) NSString *clt_id;
//    ///
//    @property (nonatomic, copy) NSString *cl_id;
//    ///
//    @property (nonatomic, copy) NSString *courseware_id;
//    ///
//    @property (nonatomic, copy) NSString *button_text;
//    /// 中间背景图
//    @property (nonatomic, copy) NSString *content_img;
//    /// 头部背景图
//    @property (nonatomic, copy) NSString *header_img;
//    /// 列表类型  lesson  课程  test 测试 url 加载url
//    @property (nonatomic, copy) NSString *type;
//    @property (nonatomic, copy) NSString *record_url;
//
//    ///
//    @property (nonatomic, strong) BKMainSubDataModel *sub_data;
//    ///
//    @property (nonatomic, assign) NSUInteger liveroom_type;
//
//    @property (nonatomic, assign) NSUInteger classroomType;
//    @property(nonatomic, assign) NSUInteger has_courseware;
//    @property(nonatomic, copy) NSString *has_courseware_txt;
}

struct SubDataNewModel:HandyJSON {
    
    var avatar : String = ""
    var desc : String = ""
    var level: String = ""
    var name: String = ""
    var title: String = ""
    var url: String = ""
    var live_rec: LiveRecModel = LiveRecModel()
    
//    ///
//    @property (nonatomic, copy) NSString *avatar;
//    ///
//    @property (nonatomic, copy) NSString *desc;
//    ///
//    @property (nonatomic, copy) NSString *level;
//    ///
//    @property (nonatomic, copy) NSString *name;
//    ///
//    @property (nonatomic, copy) NSString *title;
//    ///
//    @property (nonatomic, copy) NSString *url;
//    /// 直播信息
//    @property (nonatomic, strong) BKMainLiveRecModel *live_rec;
}

struct LiveRecModel: HandyJSON {
    
    var cl_name: String = ""
    var name: String = ""
    var room_id: String = ""
    var room_number: String = ""
    var student_token: String = ""
    var student_url: String = ""
    var teacher_token: String = ""
    var teacher_url: String = ""
    
    
    
//    ///
//    @property (nonatomic, copy) NSString *cl_name;
//    ///
//    @property (nonatomic, copy) NSString *name;
//    ///
//    @property (nonatomic, copy) NSString *room_id;
//    ///
//    @property (nonatomic, copy) NSString *room_number;
//    ///
//    @property (nonatomic, copy) NSString *student_token;
//    ///
//    @property (nonatomic, copy) NSString *student_url;
//    ///
//    @property (nonatomic, copy) NSString *teacher_token;
//    ///
//    @property (nonatomic, copy) NSString *teacher_url;
}


struct AppStoreModel : HandyJSON{
    
    var resultCount :Int = 111111
    var results: [indexModel] = [indexModel]()
}

struct indexModel : HandyJSON{
    
    var version: String  = ""
}
