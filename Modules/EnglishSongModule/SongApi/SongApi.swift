//
//  SongApi.swift
//  UUEnglish
//
//  Created by Asun on 2020/9/17.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

enum SongApi {
    case recordList /// 儿歌列表
    /// 音乐广场
    case musicCenter
    ///我的录制
     case myRecord
}

extension SongApi: BaseApi {
    var path:String {
        switch self {
        case .recordList:
            return "kidsong/song-api/get-list"
        case .musicCenter:
            return "kidsong/song-api/kidsong-square"
        case .myRecord:
            return "kidsong/song-api/get-user-list"
        }
    }
    
    
    
    
}
