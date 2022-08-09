//
//  SongHistoryListController.swift
//  UUEnglish
//
//  Created by Asun on 2020/9/17.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

class SongHistoryListController: RxCollectionController {
    
    
    var viewModel : MyRecordListViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI().viewModelCofig().viewModelOutputBind()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "kAddKidSongNotification"), object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            guard let `self` = self else {return}
            self.viewModel.input.headerRefresh.onNext(())
        }
    }
    
    override func createCollectionView() {
        self.limitCount = 18
        super.createCollectionView()
        self.collectionView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        self.registerCellClass(BKEnglishSongCell.self)
    }
    
    override func collectionViewFrame() -> CGRect {
        return CGRect(x: 100, y: 40, width: ScreenWidth-200, height: self.view.height - 104)
    }
}
extension SongHistoryListController{
    
    func viewModelCofig() -> SongHistoryListController {
        
        viewModel = MyRecordListViewModel(dispose: dispose)
        self.headerRefresh()?.asDriver().drive(viewModel.input.headerRefresh).disposed(by: dispose)
        self.footerRefresh()?.asDriver().drive(viewModel.input.footerRefresh).disposed(by: dispose)
        self.collectionView.rx.retry.bind(to: viewModel.input.retry).disposed(by: dispose)
        viewModel.output.footerState.asDriver(onErrorDriveWith: Driver.empty()).drive(self.footerEndState()).disposed(by: dispose)
        viewModel.output.emptyData.asDriver(onErrorJustReturn: .Success).drive(self.collectionView.rx.isShowRetryView).disposed(by: dispose)
        return self
    }
    
    func viewModelOutputBind() {
        viewModel.output.listDataOutput.map{($0.list,$1)}.bind(to: dataHandle).disposed(by: dispose)
        viewModel.output.requestError.bind(to: requesteError).disposed(by: dispose)
    }
}

extension SongHistoryListController{
    
    var dataHandle : Binder<([ListModel],Int)>{
        return Binder(self){vc, tuples  in
            vc.viewModel.output.emptyData.onNext(.Success)
            switch tuples.1{
            ///下拉刷新
            case 1:
                if tuples.0.count > 0{
                    vc.viewModel.output.emptyData.onNext(.Success)
                    Observable.just(tuples.0).bind(to: vc.dataArray).disposed(by: vc.dispose)
                }else{
                    vc.viewModel.output.emptyData.onNext(.NoData)
                }
                break
            ///上拉刷新
            default:
                let newListData = vc.dataArray.value + tuples.0
                if tuples.0.count > 0{
                    Observable.just(newListData).bind(to: vc.dataArray).disposed(by: vc.dispose)
                    ///说明没有要刷新的数据了
                }
                vc.viewModel.output.emptyData.onNext(.Success)
                break
            }
            vc.viewModel.output.footerState.onNext((tuples.0.count,18))
            vc.collectionView.reloadData()
        }
    }
    var requesteError: Binder<ActionError>{
        return Binder(self){ vc, error in
            switch error{
            case .notEnabled:
                break
            case .underlyingError(let erro):
                let error = erro as! RxError
                switch error {
                ///网络错误
                case .networkError:
                    vc.viewModel.output.emptyData.onNext(.Network)
                    break
                ///服务错误
                default:
                    vc.viewModel.output.emptyData.onNext(.Service)
                    break
                }
                break
            }
            vc.collectionView.reloadData()
        }
    }
    
}

extension SongHistoryListController {
    @discardableResult
    fileprivate func configUI() -> SongHistoryListController {
        self.view.backgroundColor = .clear
        self.imgView.image = UIColor.image(with: .clear)
        return self
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.dataArray.value[indexPath.row]  as? ListModel else {
            return
        }
        let controller = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BKPlayEnglishSongController") as! BKPlayEnglishSongController
        controller.image_url = model.image_url;
        controller.record_audio_url = model.record_url;
        controller.bg_video_url = model.bg_video_url;
        controller.navTitle = model.name;
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.value.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:BKEnglishSongCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! BKEnglishSongCell
        let item: ListModel = self.dataArray.value[indexPath.row, true] as! ListModel
        let model = BKEnglishSongModel()
        model.bg_video_id = item.bg_video_id
        model.bg_video_url = item.bg_video_url
        model.video_id = item.video_id
        model.display = item.display
        model.image_url = item.image_url
        model.user_id = item.user_id
        model.edit_time = item.edit_time
        model.image_id = item.image_id
        model.video_url = item.video_url
        model.kidsong_song_id = item.kidsong_song_id
        model.name = item.name
        model.add_time = item.add_time
        model.kidsong_user_has_song_id = item.kidsong_user_has_song_id
        model.record_url = item.record_url
        model.nickname = item.nickname
        cell.hideUserName = true
        cell.hideCoverView = false
        cell.setCellUIWith(model)
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

