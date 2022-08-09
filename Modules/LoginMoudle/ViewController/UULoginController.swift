//
//  UULoginController.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/11.
//  Copyright © 2020 uuabc. All rights reserved.
//  新的等登录控制器


import UIKit

class UULoginController: BaseController {
    
    
    fileprivate lazy var segmentView                   = LoginHeaderSegmentView()
    fileprivate lazy var bottomLabel                   = YBTapLabel()
    fileprivate lazy var rightImageView                = UIImageView.init(image: kImage("login-right-bg"))
    fileprivate lazy var smsView: SMSLoginView         = SMSLoginView.loadViewFromNib()
    fileprivate lazy var accountView: AccountLoginView = AccountLoginView.loadViewFromNib().then { (make) in
        make.alpha = 0
    }
    fileprivate lazy var leftView                      = UIView().then { (make) in
        make.isUserInteractionEnabled = true
    }
    fileprivate var viewModel: UULoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiConfig()
            .viewModelInit()
            .attributeLabelConfig()
            .viewModelInputBinding()
            .viewModelOutpuBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden( true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden( false, animated: animated)
    }
    
}

extension  UULoginController{
    
    func viewModelInit() -> UULoginController {
        viewModel = UULoginViewModel.init(apiService: UULoginAPiService(),
                                          dispose: dispose)
        return self
    }
    
    @discardableResult
    func viewModelInputBinding() -> UULoginController {
        segmentView.smsLabel.rx.tap.asObservable().bind(to: smsButtonAction).disposed(by: dispose)
        segmentView.accountLabel.rx.tap.asObservable().bind(to: accountAction).disposed(by: dispose)
        accountView.forgetBtn.rx.tap.asObservable().bind(to: forgetBtnAction).disposed(by: dispose)
        accountView.pushObservable.bind(to: pushHandle).disposed(by: dispose)
        smsView.pushObservable.bind(to: pushHandle).disposed(by: dispose)
        return self
    }
    
    @discardableResult
    func viewModelOutpuBinding() -> UULoginController {
        ///用户协议数据绑定
        viewModel.output.userProtcolOutput.asDriver(onErrorDriveWith: Driver.empty()).drive(userProtocol).disposed(by: dispose)
        return self
    }
}

extension UULoginController{
    
    var userProtocol: Binder<String>{
        return Binder(self){ vc, url in
            let webVc = WKWebController.init(title: "", url: url, customNaviBar: false)
            vc.navigationController?.pushViewController(webVc, animated: true)
        }
    }
    
    var accountAction: Binder<Void>{
        return Binder(self){ vc, _ in
            vc.smsView.alpha = 1
            vc.accountView.alpha = 0
        }
    }
    
    var smsButtonAction: Binder<Void>{
        return Binder(self){ vc, _ in
            vc.smsView.alpha = 0
            vc.accountView.alpha = 1
        }
    }
    
    var forgetBtnAction: Binder<Void>{
        return Binder(self){ vc, _ in
            let controller = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "BKForgetPwdController")
            controller.modalPresentationStyle = .fullScreen
            vc.present(controller, animated: true, completion: nil)
        }
    }
    
    var pushHandle: Binder<Void>{
        return Binder(self){ vc,_ in
            kWindow.rootViewController =  BaseNavgationController(rootViewController: NewHomeController())
        }
    }
}


extension UULoginController{
    @discardableResult
    func attributeLabelConfig() -> UULoginController{
        let text = "登录即代表同意精锐在线少儿HD 用户协议 和 隐私政策"
        let range1 = (text as NSString).range(of: "用户协议")
        let range2 = (text as NSString).range(of: "隐私政策")
        let attrStr = NSMutableAttributedString(string: text)
        attrStr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        attrStr.addAttribute(.underlineColor, value: UIColor(hexString: "#5C5D5F") as Any, range: range1)
        attrStr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        attrStr.addAttribute(.underlineColor, value: UIColor(hexString: "#5C5D5F") as Any, range: range2)
        bottomLabel.attributedText = attrStr
        bottomLabel.textColor = UIColor(hexString: "#5C5D5F")
        bottomLabel.font = UIFont(PingFangSCRegular: 18)
        bottomLabel.textAlignment = .center
        bottomLabel.enabledTapEffect = false
        bottomLabel.enabledTapAction = true
        bottomLabel.yb_addAttributeTapAction(["用户协议","隐私政策"]) { [weak self](title, range, index) in
            guard let `self` = self else{return}
            switch index{
            ///用户协议
            case 0:
                self.viewModel.intput.startUserRequest.onNext(())
                break
            ///隐私政策
            case 1:
                let vc = WKWebController.init(title: "隐私政策", url: "https://app.uuabc.com/#/protocol")
                self.navigationController?.pushViewController(vc, animated: false)
                break
            default:
                break
            }
        }
        return self
    }
}




extension UULoginController{
    
    func uiConfig() -> UULoginController{
        
        self.view.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(kScreenWidth * 0.46)
        }
        
        self.view.addSubview(leftView)
        leftView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(rightImageView.snp.left)
        }
        
        leftView.addSubview(segmentView)
        segmentView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kScreenScale(70))
            make.size.equalTo(CGSize(width: kScreenScale(300), height: kScreenScale(40)))
        }
        
        leftView.addSubview(smsView)
        smsView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(segmentView.snp.bottom)
            make.bottom.equalToSuperview().offset(kScreenScale(-50))
        }
        
        leftView.addSubview(accountView)
        accountView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(segmentView.snp.bottom)
            make.bottom.equalToSuperview().offset(kScreenScale(-50))
        }
        
        leftView.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(kScreenScale(-24))
        }
        return self
    }
}


