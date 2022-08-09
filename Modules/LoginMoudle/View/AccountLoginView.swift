//
//  AcountLoginView.swift
//  UUEnglish
//
//  Created by Derrick on 2019/8/15.
//  Copyright © 2019 uuabc. All rights reserved.
//

import UIKit

class AccountLoginView: UIView,NibLoadable {

    @IBOutlet weak var forgetBtn: UIButton!
    @IBOutlet weak var showPasswBtn: UIButton!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var pwdTf: UITextField!
    @IBOutlet weak var loginBtn: LoadingButton!
    var forgetPwdHandle: (()->())?
//    var viewModel: LoginViewModel = LoginViewModel()
    fileprivate var viewModel : AccountLoginViewModel!
    fileprivate let dispose = DisposeBag()
    lazy var pushObservable = PublishSubject<Void>()
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModelConfig()
            .viewModelOutputBinding()
    }
    
    func viewModelConfig() -> AccountLoginView {
        
        viewModel = AccountLoginViewModel.init(apiService: AccountApiService(), tool: AccountVaildTool(), dispose: dispose)
        phoneTf.rx.text.orEmpty.bind(to: viewModel.intput.phoneNum).disposed(by: dispose)
        pwdTf.rx.text.orEmpty.bind(to: viewModel.intput.passwordNum).disposed(by: dispose)
        showPasswBtn.rx.tap.asObservable().bind(to: showPasswordHandle).disposed(by: dispose)
        loginBtn.rx.tap.asObservable().map{_ in self.loginBtn.startAnimation()}.bind(to: viewModel.intput.logBtnAction).disposed(by: dispose)
        
        /// 设置账号输入范围
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
                        self.pwdTf.becomeFirstResponder()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        /// 设置密码输入范围
        pwdTf
            .rx
            .controlEvent([.editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                // 获取非选中状态文字范围
                let selectedRange = self.pwdTf.markedTextRange
                // 没有非选中文字，截取多出的文字
                if selectedRange == nil {
                    let text = self.pwdTf.text ?? ""
                    if text.count > 16 {
                        let index = text.index(text.startIndex, offsetBy: 16)
                        self.pwdTf.text = String(text[..<index])
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        return self
    }
    
    @discardableResult
    func viewModelOutputBinding() -> AccountLoginView {
        viewModel.output.loginBntConfig.bind(to: loginBtnUI).disposed(by: dispose)
        viewModel.output.phoneTextConfig.bind(to: phoneTextConfig).disposed(by: dispose)
        viewModel.output.loginRequestOutput.bind(to: loginRequestHandle).disposed(by: dispose)
        viewModel.output.loginBtnAnimation.bind(to: loginBtnAnimation).disposed(by: dispose)
        return self
    }
}

extension AccountLoginView{
    
    var phoneTextConfig : Binder<String>{
        return Binder(self){ view, text in
            if text.length > 0{
                 view.phoneTf.text = text
                 view.viewModel.intput.phoneNum.onNext(text)
            }
        }
    }
    
    var loginBtnUI:Binder<LoginBtnModel>{
        return Binder(self){ view, model in
            view.loginBtn.isUserInteractionEnabled = model.isCanAction
            view.loginBtn.backgroundColor = UIColor(hexString: model.backgroundColor)
            view.loginBtn.loadingColor = UIColor.white
        }
    }
    
    var showPasswordHandle : Binder<Void>{
        return Binder(self){ view,_ in
            view.showPasswBtn.isSelected = !view.showPasswBtn.isSelected
            view.pwdTf.isSecureTextEntry = !view.showPasswBtn.isSelected
        }
    }
    
    var loginBtnAnimation: Binder<Void> {
        return Binder(self) { view, _ in
            view.loginBtn.stopAnimation()
        }
    }
    
    var loginRequestHandle: Binder<UULoginModel>{
        return Binder(self){ view, model in
            if model.errno == 0 {
              view.viewModel.vailedManager.loginSuccessConfig(model)
              view.pushObservable.onNext(())
            }
            view.loginBtn.stopAnimation()
        }
    }
}

