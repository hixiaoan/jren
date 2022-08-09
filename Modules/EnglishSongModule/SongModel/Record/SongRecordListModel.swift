//
//  SongRecordListModel.swift
//  UUEnglish
//
//  Created by Asun on 2020/9/17.
//  Copyright © 2020 uuabc. All rights reserved.
//

struct SongRecordListModel: RxBaseModel {
    var totoal: Int = 0
    var list: [SongRecordItemModel] = []
}


struct SongRecordItemModel: RxBaseModel {
    var bg_video_id: String = ""
    var bg_video_url: String = ""
    var video_id: String = ""
    var display: String = ""
    var image_url: String = ""
    var user_id: String = ""
    var edit_time: String = ""
    var image_id: String = ""
    var kidsong_song_id: String = ""
    var name: String = ""
    var add_time: String = ""
    var kidsong_user_has_song_id: String = ""
    var record_url: String = ""
    var nickname: String = ""
    var video_url: String = ""
}
