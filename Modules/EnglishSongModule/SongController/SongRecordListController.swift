//
//  SongRecordListController.swift
//  UUEnglish
//
//  Created by Asun on 2020/9/17.
//  Copyright © 2020 uuabc. All rights reserved.
//  英文儿歌

import Foundation

class SongRecordListController: RxCollectionController {
    
    var viewModel: SongRecordListViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI().bindingInput().aimingOutput()
    }
    
    override func createCollectionView() {
        self.limitCount = 18
        super.createCollectionView()
        self.collectionView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        self.registerCellClass(SongCell.self)
    }
    
    override func collectionViewFrame() -> CGRect {
        return CGRect(x: 100, y: 40, width: ScreenWidth-200, height: self.view.height - 104)
    }
}

extension SongRecordListController {
    @discardableResult
    fileprivate func configUI() -> SongRecordListController {
        self.view.backgroundColor = .clear
        self.imgView.image = UIColor.image(with: .clear)
        return self
    }
    
    @discardableResult
    fileprivate func bindingInput() -> SongRecordListController {
        viewModel = SongRecordListViewModel.init(pageStatu: .songRecord, apiService: SongRecordListService(), dispose: rx.disposeBag)
        self.headerRefresh()?.asDriver().drive(viewModel.input.headerRefresh).disposed(by: rx.disposeBag)
        self.footerRefresh()?.asDriver().drive(viewModel.input.footerRefresh).disposed(by: rx.disposeBag)
        self.collectionView.rx.retry.bind(to: viewModel.input.retry).disposed(by: dispose)
        viewModel.output.footerState.asDriver(onErrorJustReturn: (0,18)).drive(self.footerEndState()).disposed(by: rx.disposeBag)
        viewModel.output.emptyData.asDriver(onErrorJustReturn: .Success).drive(self.collectionView.rx.isShowRetryView).disposed(by: rx.disposeBag)
        return self
    }
    
    @discardableResult
    fileprivate func aimingOutput() -> SongRecordListController{
        self.viewModel.output.dataSource.subscribeNext(weak: self) { (vc) -> ([SongRecordListCellViewModel]) -> Void in
            return { _ in
                vc.refresh(.Success)
            }
        }.disposed(by: rx.disposeBag)
        
        self.selectCell()?.subscribe(onNext: { [weak self] (index) in
            guard let `self` = self else {return}
            if let record = try? self.viewModel.output.dataSource.value()[index.row] {
                let recordVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BKRecordEnglishSongController") as! BKRecordEnglishSongController
                recordVc.image_url = record.output.contentImageNormal.value;
                recordVc.video_url = record.output.videoUrl.value;
                recordVc.bg_video_url = record.output.bgUrl.value;
                recordVc.navTitle = record.output.navTitle.value;
                recordVc.kidsong_song_id = record.output.songId.value;
                self.navigationController?.pushViewController(recordVc, animated: true)
            }
        }).disposed(by: rx.disposeBag)
        return self
    }
}

extension SongRecordListController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return (try? self.viewModel.output.dataSource.value().count) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:SongCell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.className, for: indexPath) as! SongCell
        do {
            cell.bindResult(try self.viewModel.output.dataSource.value()[indexPath.row])
        } catch {
            prints("赋值错误")
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 0.36*kScreenWidth, height: 0.36*kScreenHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

