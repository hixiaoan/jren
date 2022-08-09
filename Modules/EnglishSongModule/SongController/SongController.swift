//
//  SongController.swift
//  UUEnglish
//
//  Created by Asun on 2020/9/17.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

class SongController: RxBaseController {
    
    fileprivate lazy var segHead: MLMSegmentHead = MLMSegmentHead.init(frame: getHeadFrame(), titles: ["英文儿歌","我的录制","儿歌广场"], headStyle: SegmentHeadStyleLine, layoutStyle: MLMSegmentLayoutDefault)!.then{
        $0.headColor = .clear
        $0.fontSize = 21
        $0.fontScale = 1.2
        $0.selectedBold = true
        $0.selectColor = .init(hexString: "3D7AFF")
        $0.deSelectColor = .init(hexString: "38393A")
        $0.lineColor = .clear
        $0.bottomLineColor = .clear
        $0.lineHeight = 2
        $0.lineScale = 0.8
        $0.equalSize = true
        $0.gradualChangeTitleColor = true
    }
    
    fileprivate lazy var segScroll: MLMSegmentScroll = MLMSegmentScroll.init(frame: geSegScrollFrame(), vcOrViews: getListViewCons())!.then{
        $0.addTiming = SegmentAddScale
        $0.loadAll = false
        $0.addScale = 0.1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSegMentView()
        addNotification()
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "kAddKidSongNotification"), object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            guard let `self` = self else {return}
            self.segHead.change(1, completion: true)
        }
    }
}

extension SongController {
    @discardableResult
    fileprivate func configSegMentView() -> SongController{
        MLMSegmentManager.associateHead(segHead, with: segScroll) { [weak self] in
            guard let `self` = self else {return}
            self.view.addSubview(self.segHead)
            self.navigationItem.titleView = self.segHead
            self.view.addSubview(self.segScroll)
        }
        return self
    }
    
    fileprivate func getHeadFrame() -> CGRect {
        return CGRect(x: 0, y: navBarHeight, width: ScreenWidth/2, height: 44)
    }
    
    fileprivate func geSegScrollFrame() -> CGRect {
        return CGRect(x: 0, y: navBarHeight, width: ScreenWidth, height: ScreenHeight-navBarHeight)
    }
    
    fileprivate func getListViewCons() -> [RxCollectionController] {
        return [SongRecordListController()
                ,SongHistoryListController()
                ,SongSquareListController()]
    }
}
