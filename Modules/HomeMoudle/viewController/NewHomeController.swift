//
//  NewHomeController.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/7.
//  Copyright © 2020 uuabc. All rights reserved.
//  新的首页

import UIKit
import Reachability

class NewHomeController: BaseViewController,RoomExitDelegate {
    
    ///预约
    fileprivate lazy var oppointmentView: BKHomeNewCourseView = BKHomeNewCourseView.createViewFromNib()
    ///用户信息
    fileprivate lazy var userInfoView : BKNewHomeUserView = BKNewHomeUserView.createViewFromNib()!.then({ (make) in
        make.frame = CGRect(x: 30, y: 20, width: 100, height: 84)
    })
    ///背景
    fileprivate lazy var backgrundImageView = HHImageZoomView.init(frame: UIScreen.main.bounds)
    ///设置内容
    fileprivate lazy var setView = HomeSetView.init(frame: .zero).then { (make) in
        make.isHidden = true
    }
    ///菜单
    fileprivate lazy var menuListView = HomeMenuListView.init(frame: .zero)
   
    ///选课请求
    fileprivate lazy var oppointmentClassObservable = PublishSubject<Bool>()
    
    ///获取U币
    fileprivate lazy var getUserUPointObservable  = PublishSubject<Void>()
    
    fileprivate      var classType : UUClassRoomLayout!
    ///客服
    fileprivate lazy var kefuBtn = TIMKeFuButton()
    
    fileprivate      var viewModel : HomeViewModel!
    
    fileprivate      var roomToken: String!
    
    fileprivate      var rechargeURL: String = ""
    
    fileprivate lazy var manager = NetworkReachabilityManager()
    
    ///网路可否刷新
    fileprivate lazy var isRefresh = false
    
    ///阿里云上报开关
     fileprivate lazy var logConfig = LogConfigModule()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
            .viewModelCofig()
            .dataWithActionToBinding()
            .kefuConfig().currentNetReachability()
    }
    
     func currentNetReachability() {

        manager?.listener = { status in
            switch status {
            case .reachable:
                if self.isRefresh {
                    self.oppointmentClassObservable.onNext(true)
                    self.getUserUPointObservable.onNext(())
                }
                break
            default:
                break
            }
        }
        manager?.startListening()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logConfig.logService.AliCloudConfig.execute()
        oppointmentClassObservable.onNext(true)
        getUserUPointObservable.onNext(())
        self.navigationController?.setNavigationBarHidden( true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isRefresh = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    deinit {
        manager?.stopListening()
    }
}

///数据绑定
extension NewHomeController{
    
    @discardableResult
    func viewModelCofig() ->NewHomeController {
        viewModel = HomeViewModel.init(orderClass: menuListView.orderClassBtn.rx.tap.asObservable(),
                                       isHaveClass: oppointmentClassObservable,
                                       getUserUPoint: getUserUPointObservable,
                                       apiService: HomeApiService(),
                                       dispose: dispose)
        return self
    }
    
    @discardableResult
    func dataWithActionToBinding() ->NewHomeController {
        
        ///设置操作
        setView.cellAction.bind(to: setViewHandle).disposed(by: dispose)
        ///设置
        menuListView.setBtn.rx.tap.asObservable().map{_ in true}.bind(to: setBtnAction).disposed(by: dispose)
        ///订单
        menuListView.orderBtn.rx.tap.asObservable().map{_ in true}.bind(to: orderAction).disposed(by: dispose)
        ///英文儿歌
        backgrundImageView.songBtn.rx.tap.asObservable().map{_ in true}.bind(to: englishSongAction).disposed(by: dispose)
        ///绘本读书
        backgrundImageView.readingBtn.rx.tap.asObservable().map{_ in true}.bind(to: readerBookAction).disposed(by: dispose)
        ///uu直播
        backgrundImageView.uLiveListBtn.rx.tap.asObservable().map{_ in true}.bind(to: uuLiveAction).disposed(by: dispose)
        ///学习中心
        backgrundImageView.learnCenterBtn.rx.tap.asObservable().map{_ in true}.bind(to: learnCenterAction).disposed(by: dispose)
        ///约课
        viewModel.output.orderClassOutput.bind(to: orderClassHandle).disposed(by: dispose)
        ///选课弹窗
        viewModel.output.choseClassOutput.bind(to: choseClaseHandle).disposed(by: dispose)
        ///是否有约课信息
        viewModel.output.isHaveClassOutput.bind(to: isHaveClassHandle).disposed(by: dispose)
        ///预约课按钮响应
        viewModel.output.handlerClassOutPut.bind(to: handleClassAction).disposed(by: dispose)
        ///开始上课
        viewModel.output.classInfoOuput.asDriver(onErrorDriveWith: Driver.empty()).drive(startClassAction).disposed(by: dispose)
        ///用户信息绑定
        viewModel.output.userInfoOutput.bind(to: userInfoHandle).disposed(by: dispose)
        ///aapstore请求业务处理
        viewModel.output.appStoreResultOutput.bind(to: appStoreHandle).disposed(by: dispose)
        return self
    }
    
    func kefuConfig() -> NewHomeController {
        HXChatManager.shared().parentVc = self
        HXChatManager.shared().loginHX()
        ///u币点击事件
        userInfoView.ubBlock = { [weak self] in
            self?.viewModel.input.gotoAppStoreRequestInput.onNext(())
        }
        return self
    }
}

extension NewHomeController{
    
    var learnCenterAction : Binder<Bool>{
        return Binder(self){ vc, state in
            vc.navigationController?.pushViewController(BKCourseController(), animated: state)
            vc.setView.isHidden = true
        }
    }
    
    var readerBookAction: Binder<Bool>{
        return Binder(self){ vc, state in
            vc.navigationController?.pushViewController(BKBooksController(), animated: state)
            vc.setView.isHidden = true
        }
    }
    
    var englishSongAction: Binder<Bool>{
        return Binder(self){vc, state in
            vc.navigationController?.pushViewController(SongController(), animated: state)
            vc.setView.isHidden = true
        }
    }
    
    var uuLiveAction : Binder<Bool>{
        return Binder(self){ vc, state in
            vc.navigationController?.pushViewController(ULiveListViewController(), animated: state)
            vc.setView.isHidden = true
        }
    }
    
    var orderAction: Binder<Bool>{
        return Binder(self){ vc, state in
            vc.setView.isHidden = true
            vc.navigationController?.pushViewController(OrderManagerViewController(), animated: state)
        }
    }
    
    var setBtnAction: Binder<Bool>{
        return Binder(self){vc,_ in
            vc.setView.isHidden = !vc.setView.isHidden
            vc.view.bringSubviewToFront(vc.setView)
        }
    }
    
    var setViewHandle: Binder<SetType>{
        return Binder(self){ vc, type in
            vc.setViewBusinessHandle(type)
        }
    }
    
    var orderClassHandle: Binder<OrderClassModel>{
        return Binder(self){vc, model in
            vc.setView.isHidden = true
            vc.orderClassBusinessHandle(model: model)
        }
    }
    
    var choseClaseHandle: Binder<OrderClassModel>{
        return Binder(self){ vc,model in
            vc.choseClaseBusinessHandle(model: model)
        }
    }
    
    var isHaveClassHandle : Binder<Any>{
        return Binder(self){ vc, json in
            vc.isHaeClassBusinessHandle(json: json)
        }
    }
    
    var handleClassAction: Binder<ListNewModel>{
        return Binder(self){vc, model in
            vc.handleClassBusiness(model: model)
        }
    }
    
    var startClassAction: Binder<OrderClassModel> {
        return Binder(self){ vc, model in
            if model.isRequestSccussed{
               vc.startClassBusinessHandle(model)
            }else{
                Toast.show(desc: "课程信息有误,暂时无法进入教室")
            }
        }
    }
    
    var userInfoHandle : Binder<(String,OrderClassModel)>{
        return Binder(self){vc, tuples in
            vc.userInfoBusinessHandle(tuples)
        }
    }
    
    var appStoreHandle: Binder<Bool>{
        return Binder(self){ vc, result in
            vc.appstoreBusinessHandle(result)
        }
    }
    
}

///MARK:  所有业务处理
extension NewHomeController{
    
    func evaluationTeacher(model: SSClassOverModel) {
      let vc = BKWebViewController()
      vc.url = model.redirect_url;
      self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setViewBusinessHandle(_ type: SetType){
        switch type{
        case .outLogin:
            BKBaseAlertView.show(fromVc: self, title: "温馨提示", content: "确认退出吗?", cancelBtnTitle: "取消", confirmBtnTitle: "确定") {
                RouterManager.againLogin()
            }
            break
            ///修改密码
        case .setPassword:
            BKChangePwdView.showFormVc(self)
            break
            
        case .textDevice:
            BKDeviceCheckView.show(fromVc: self)
            break

        case .reload:
            //MARK: 刷新
            self.getUserUPointObservable.onNext(())
            self.oppointmentClassObservable.onNext(true)
            break
        }
    }
    
    func orderClassBusinessHandle(model: OrderClassModel){
        if model.isRequestSccussed {
            switch model.errno {
            case 701:
                let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "BKUpdateUserInfoController")
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 702:
                let vc = BKWebViewController()
                vc.url = model.jsondata.url
                vc.webViewDidCloseBlock = {
                    self.navigationController?.pushViewController(ACArrangeCourseController(), animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 703,0:
                 self.navigationController?.pushViewController(ACArrangeCourseController(), animated: true)
                break
            default:
                break
            }
        }
    }
    
    func choseClaseBusinessHandle(model: OrderClassModel){
        if model.isRequestSccussed{
            if model.jsondata.has_chose == 0 {
                self.viewModel.business.hasShow = true
                let alertView = BKBaseAlertView.show(fromVc: self, title: "温馨提示", content: model.jsondata.show_txt, cancelBtnTitle: "我再想想", confirmBtnTitle:"去选课" )
                alertView?.checkCancelHandler = { isChecked in
                    if (isChecked) {
                        self.viewModel.business.saveAlertShowDay()
                    }
                }
                alertView?.checkConfirmHandler = { isChecked in
                  if (isChecked) {
                      self.viewModel.business.saveAlertShowDay()
                  }
                 self.navigationController?.pushViewController(ACArrangeCourseController(), animated: true)
                }
            }
        }
    }
    
    func isHaeClassBusinessHandle(json: Any){
        guard let dicStr = json as? String,
               let dic = self.viewModel.business.stringValueDic(dicStr),
               let _ = dic["jsondata"],
               let result = dic["jsondata"] as? [String: Any] else{
               return
           }
           self.oppointmentView.data = result
           self.oppointmentView.actionHandler = { data in
               guard let dataSource = data as? [String: Any],
                   let _ = dataSource["class_status"] ?? nil
                   else{
                   return
               }
               
               guard let model = ListNewModel.deserialize(from: dataSource) else{
                   return
               }
               self.viewModel.output.handlerClassOutPut.onNext(model)
           }
    }
    
    func handleClassBusiness(model: ListNewModel){
        switch model.class_status{
        case 1:
            if model.has_courseware == 1 {
                let controller = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BKPreviewController") as! BKPreviewController
                controller.courseware_id             = model.courseware_id
                controller.clt_id                    = model.clt_id
                controller.modalPresentationStyle    = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }else{
                UUProgressHUD.showWarn(withStatus: model.has_courseware_txt)
            }
            break
            ///开始上课
        case 2:
            self.viewModel.input.beginClass.onNext(model)
            break
        case 3:
            if !model.record_url.isEmpty {
                let wkVC = BKWebViewController()
                wkVC.url = model.record_url
                self.navigationController?.pushViewController(wkVC, animated: true)
            }else{
                UUProgressHUD.showWarn(withStatus: "回顾视频正在生成中,请耐心等候")
            }
            break
        case 4:
            self.viewModel.output.checkUserInfoOutput.onNext(())
            break
        default:
            break
        }
    }
    
    func startClassBusinessHandle(_ model:OrderClassModel){
        self.roomToken = model.jsondata.token
        switch (model.jsondata.classroomType){
        case 1:
            self.classType = .OneToOneClass
            break
        case 2:
            self.classType = .OneToFourClass
            break
        case 3:
            self.classType = .LiveClass
            break
        default:
            break
        }
        SSClassInTool.classesBegin(supportDel: self, classType: self.classType, classToken: model.jsondata.token)
    }
    
    func userInfoBusinessHandle(_ tuples: (String, OrderClassModel)) {
        
        let model : OrderClassModel = tuples.1
        
        let userInfoModel = BKUserInfoModel()
        userInfoModel.uuid          = model.jsondata.uuid
        userInfoModel.avatars       = model.jsondata.avatars
        userInfoModel.uid           = model.jsondata.uid
        userInfoModel.af_token      = model.jsondata.af_token
        userInfoModel.st_sex        = model.jsondata.st_sex
        userInfoModel.mini_token    = model.jsondata.mini_token
        userInfoModel.st_class      = model.jsondata.st_class
        userInfoModel.enname        = model.jsondata.enname
        userInfoModel.st_birthday   = model.jsondata.st_birthday
        userInfoModel.birthday      = model.jsondata.birthday
        userInfoModel.test_level    = model.jsondata.test_level
        userInfoModel.utype         = model.jsondata.utype
        userInfoModel.username      = model.jsondata.username
        userInfoModel.gql_token     = model.jsondata.gql_token
        userInfoModel.st_class_text = model.jsondata.st_class_text
        userInfoModel.email         = model.jsondata.email
        userInfoModel.name          = model.jsondata.name
        userInfoModel.age           = model.jsondata.age
        userInfoModel.pad_recharge_url  = model.jsondata.pad_recharge_url
        self.userInfoView.updagteUserInfo(userInfoModel, uBi: tuples.0)
        UserTool.shared.nickname = model.jsondata.name
        UserTool.shared.birthday = model.jsondata.birthday
        UserTool.shared.sex      = model.jsondata.sex
        UserTool.shared.age      = model.jsondata.age;
        UserTool.shared.englishName = model.jsondata.englishName
        self.rechargeURL         = model.jsondata.recharge_url
    }
    
    func appstoreBusinessHandle(_ isOpenPurchasing:Bool){
        if !isOpenPurchasing {
            IPAPurchase.manager()?.buyProduct(withProductID: PRODUCT_ID, payResult: { [weak self](_, _,_) in
                UUHud.hideHud()
                self?.getUserUPointObservable.onNext(())
            })
        }else{
            if !self.rechargeURL.isEmpty {
                let vc = MSPayWebController()
                vc.url = self.rechargeURL
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                UUProgressHUD.showInfo("操作失败,无效的URL")
            }
        }
    }
    
    func changePasswordViewConfig(){
        
        
    }
}


extension NewHomeController{
    
    @discardableResult
    func setUpUI() -> NewHomeController {
        
        self.view.addSubview(backgrundImageView)
        backgrundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        backgrundImageView.addSubview(menuListView)
        menuListView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(kScreenScale(-30));
            make.top.equalToSuperview().offset(kScreenScale(23));
            make.size.equalTo(CGSize(width: kScreenScale(282), height: kScreenScale(100)))
        }
        
        backgrundImageView.addSubview(setView)
        setView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kScreenScale(125))
            make.right.equalToSuperview()
            make.size.equalTo(CGSize(width: kScreenScale(173), height: kScreenScale(220)))
        }
        
        backgrundImageView.addSubview(oppointmentView)
        oppointmentView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(kScreenScale(-72))
            make.size.equalTo(CGSize(width: kScreenScale(256), height: kScreenScale(178)))
        }
        
        backgrundImageView.addSubview(kefuBtn)
        kefuBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(kScreenScale(5))
            make.top.equalToSuperview().offset(ScreenHeight - kScreenScale(190))
            make.size.equalTo(CGSize(width: kScreenScale(106), height: kScreenScale(96)))
        }
        
        backgrundImageView.addSubview(userInfoView)
//        userInfoView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(kScreenScale(30))
//            make.top.equalToSuperview().offset(kScreenScale(20))
//            make.size.equalTo(CGSize(width: kScreenScale(100), height: kScreenScale(84)))
//        }
        return self
    }
    
}
