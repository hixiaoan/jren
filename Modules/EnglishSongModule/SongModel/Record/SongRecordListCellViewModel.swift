//
//  SongRecordListCellViewModel.swift
//  UUEnglish
//
//  Created by Asun on 2020/9/18.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SongRecordListCellViewModel {
    
    var output = Output()
    
    let dispose = DisposeBag()
    
    struct Output {
        lazy var titleText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var contentImage: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var dateText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var nameText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var contentImageNormal: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var videoUrl: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var bgUrl: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var navTitle: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var songId: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        lazy var songCoverIsHidden: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    }
    
    
    init(_ item: SongRecordItemModel, _ pageStatu: SongSegmentStatus) {
        Observable.just(item.image_url + "?imageView/1/w/744/h/466").bind(to: output.contentImage).disposed(by: dispose)
        Observable.just(item.name).bind(to: output.titleText).disposed(by: dispose)
        Observable.just(item.add_time).bind(to: output.dateText).disposed(by: dispose)
        Observable.just(item.nickname).bind(to: output.nameText).disposed(by: dispose)
        Observable.just(item.image_url).bind(to: output.contentImageNormal).disposed(by: dispose)
        Observable.just(item.video_url).bind(to: output.videoUrl).disposed(by: dispose)
        Observable.just(item.bg_video_url).bind(to: output.bgUrl).disposed(by: dispose)
        Observable.just(item.name).bind(to: output.navTitle).disposed(by: dispose)
        Observable.just(item.kidsong_song_id).bind(to: output.songId).disposed(by: dispose)
        switch pageStatu {
        case .songRecord:
            Observable.just(true).bind(to: output.songCoverIsHidden).disposed(by: dispose)
        case .songSquare: break
        case .songHistory: break
        }
    }
    
}
