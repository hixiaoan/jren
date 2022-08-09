//
//  WKWebConroller.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/9.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

class WKWebController: BaseViewController, WKNavigationDelegate {
    
    
    fileprivate var bridge : WKWebViewJavascriptBridge!
    
    fileprivate var webView = WKWebView()
    
    fileprivate var isCustom : Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiconfig().controllerConfig()
    }
    
    @objc init(title:String, url:String, customNaviBar:Bool) {
        
        self.isCustom = customNaviBar
        
        super.init(nibName: nil, bundle: nil)

        self.title = title
      
        if let loadUrl = URL(string: url), !url.isEmpty {
            webView.load(URLRequest(url: loadUrl))
        } else {
            print("URL为空或者不是合法URl")
        }
    }
    
    @objc convenience init(title:String, url: String) {
        self.init(title:title, url: url, customNaviBar: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isCustom {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
}


extension WKWebController{
    
    func controllerConfig(){
        
        self.imgView.isHidden = true
        
        self.wr_setNavBarBackgroundAlpha(0)
        
        self.wr_setNavBarShadowImageHidden(true)
        
        bridge = WKWebViewJavascriptBridge.init(for: webView)
        
        bridge.setWebViewDelegate(self)
        
        webView.navigationDelegate = self
        
        self.navigationItem.leftBarButtonItem?.rx.tap.bind(to: leftButtonItemAction).disposed(by: dispose)
        
        self.modalPresentationStyle = .fullScreen
    }
}

extension WKWebController{
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
//        UUHud.showHud(inView: self.view)
    }
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        
    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
//        UUHud.hideHud(inView: self.view)
    }
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        
    }
}

extension WKWebController{
    
    var leftButtonItemAction : Binder<Void>{
        return Binder(self){vc,_ in
            if vc.webView.canGoBack{
                vc.webView.goBack()
            }else{
                vc.view.endEditing(true)
                vc.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension WKWebController{
    func uiconfig() -> WKWebController{
        if self.isCustom {
            self.view.addSubview(webView)
            webView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.size.height)! + 20)
            }
        }else{
            self.view.addSubview(webView)
            webView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        return self
    }
}
