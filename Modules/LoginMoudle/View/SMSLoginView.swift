//
//  SMSLoginView.swift
//  UUEnglish
//
//  Created by Derrick on 2019/8/15.
//  Copyright © 2019 uuabc. All rights reserved.
//

import UIKit
class SMSLoginView: UIView,NibLoadable {
    @IBOutlet weak var loginBtn: LoadingButton!
    @IBOutlet weak var codeTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var codeBtn: CountDownButton!
    ///判断手机号符合时,定时器在运行时,颜色为灰色
    var isTimeOpen = false
    var viewModel: SmsLoginViewModel!
    let dispose = DisposeBag()
    lazy var pushObservable = PublishSubject<Void>()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewModel = SmsLoginViewModel(manager: VaildSmsManager(),
                                           apiService: SmsLoginApiService(),
                                           dispose: dispose)
        viewModelConfig()
            .codeBtnCofngi()
            .viewModelOutputBinding()
    }
}


extension SMSLoginView{
    
    func codeBtnCofngi() -> SMSLoginView {
        codeBtn.roundCorner(radius: 30)
        codeBtn.layer.borderWidth = 1
        codeBtn.countDownChange { (btn, second) -> String in
            "\(second)s"
        }
        codeBtn.countDownFinished { (btn, second) -> String in
            if self.phoneTf.text?.length == 11{
                self.codeBtn.isUserInteractionEnabled = true
                self.codeBtn.layer.borderColor = Theam.Color.blue.cgColor
                self.codeBtn.setTitleColor(Theam.Color.blue, for: .normal)
                self.codeBtn.loadingColor = Theam.Color.blue
            }
            self.isTimeOpen = false
            return "获取"
        }
        return self
    }
    
    ///交互绑定
    func viewModelConfig() -> SMSLoginView {
        
        phoneTf.rx.text.orEmpty.asObservable().bind(to: viewModel.input.phoneNum).disposed(by: dispose)
        codeTf.rx.text.orEmpty.asObservable().bind(to: viewModel.input.vaildCode).disposed(by: dispose)
        codeBtn.rx.tap.asObservable().observeOn(MainScheduler.instance).map{
            self.codeBtn.startAnimation()
            self.isTimeOpen = true
            return  ()
        }.bind(to: viewModel.input.codeBtnAction).disposed(by: dispose)
        
        codeBtn.rx.tap.asObservable().map { _ in
            var model = CodeBtnModel()
            model.isCanAction = false
            model.borderColor =  UIColor(hexString: "#C8C8C8").cgColor
            model.titleColor = UIColor(hexString: "#C8C8C8")
            return model
        }.bind(to: codeBtnTouchEvent).disposed(by: dispose)
        
        loginBtn.rx.tap.asObservable().map{ 
            self.loginBtn.startAnimation()
            return $0
        }.bind(to: viewModel.input.loginBtnAction).disposed(by: dispose)
        
        phoneTf
            .rx
            .controlEvent([.editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                // 获取非选中状态文字范围
                let selectedRange = self.phoneTf.markedTextRange
                // 没有非选中文字，截取多出的文字
                if selectedRange == nil {
                    let text = self.phoneTf.text ?? ""
                    if text.count >= 11 {
                        let index = text.index(text.startIndex, offsetBy: 11)
                        self.phoneTf.text = String(text[..<index])
                        self.codeTf.becomeFirstResponder()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        /// 设置验证码输入范围
        codeTf
            .rx
            .controlEvent([.editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                // 获取非选中状态文字范围
                let selectedRange = self.codeTf.markedTextRange
                // 没有非选中文字，截取多出的文字
                if selectedRange == nil {
                    let text = self.codeTf.text ?? ""
                    if text.count > 6 {
                        let index = text.index(text.startIndex, offsetBy: 6)
                        self.codeTf.text = String(text[..<index])
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        return self
    }
    
    ///数据绑定
    @discardableResult
    func viewModelOutputBinding() -> SMSLoginView {
        viewModel.output.codeBtnConfigOutput.bind(to: codeBtnUIConfig).disposed(by: dispose)
        viewModel.output.loginBtnConfigOutput.bind(to: logBtnConfig).disposed(by: dispose)
        viewModel.output.getCodeOutput.bind(to: getCodeRequestResult).disposed(by: dispose)
        viewModel.output.loginRequestOutput.bind(to: logRequesrHanlde).disposed(by: dispose)
        viewModel.output.loginBtnAnimation.bind(to: loginBtnAnimation).disposed(by: dispose)
        return self
    }
}

extension SMSLoginView{
    
    ///定时器点击事件
    var codeBtnTouchEvent : Binder<CodeBtnModel>{
        return Binder(self){ view, model in
            view.codeBtn.isUserInteractionEnabled = model.isCanAction
            view.codeBtn.layer.borderColor = model.borderColor
            view.codeBtn.setTitleColor(model.titleColor, for: .normal)
            view.codeBtn.loadingColor = model.titleColor
        }
    }
    
    var codeBtnUIConfig : Binder<CodeBtnModel>{
        return Binder(self){ view, model in
            if !view.isTimeOpen{
                view.codeBtn.isUserInteractionEnabled = model.isCanAction
                view.codeBtn.layer.borderColor = model.borderColor
                view.codeBtn.setTitleColor(model.titleColor, for: .normal)
                view.codeBtn.loadingColor = model.titleColor
            }
        }
    }
    
    var logBtnConfig: Binder<LoginBtnModel>{
        return Binder(self){ vc, model in
            vc.loginBtn.isUserInteractionEnabled = model.isCanAction
            vc.loginBtn.backgroundColor = UIColor(hexString: model.backgroundColor)
            vc.loginBtn.loadingColor = UIColor.white
        }
    }
    
    var getCodeRequestResult : Binder<Bool>{
        return Binder(self){ view, state in
            if state{
                UUProgressHUD.showInfo("验证码已发送")
            }else{
                UUProgressHUD.showError(withStatus: "发送失败,请重新发送")
            }
            view.codeBtn.startCountDownWithSecond(60)
            view.codeBtn.stopAnimation()
        }
    }
    
    var loginBtnAnimation: Binder<Void> {
        return Binder(self) { view, _ in
            view.loginBtn.stopAnimation()
        }
    }
    
    var logRequesrHanlde: Binder<UULoginModel>{
        return Binder(self){view, model in
            view.loginBtn.stopAnimation()
            if model.errno != 0 {}else{
                view.viewModel.vailedManager.loginSuccessConfig(model)
                view.pushObservable.onNext(())
            }
        }
    }
}
