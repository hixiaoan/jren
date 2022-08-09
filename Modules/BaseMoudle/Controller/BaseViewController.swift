//
//  FCBaseViewController.swift
//  FutureCity_Swift
//
//  Created by Derrick on 2018/9/4.
//  Copyright © 2018年 bike. All rights reserved.
//

import UIKit
import Alamofire


class BaseViewController: UIViewController {
    
    var dispose = DisposeBag()
    
    lazy var imgView: UIImageView = {
        let img = UIImageView.init(frame: self.view.bounds)
        img.image = UIImage(named: "backImg")
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        return img
    }()
    
    @objc public var navBarBottom: CGFloat = {
        return 64
    }()
    
    @objc public var tabBarTop: CGFloat = {
        return 49
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        wr_setNavBarBackgroundAlpha(0)
        
        wr_setNavBarShadowImageHidden(true)
        wr_setNavBarBarTintColor(Theam.Color.background)
        wr_setNavBarTitleColor(Theam.FontColor.title)
        self.navigationController?.navigationBar.wr_setTranslationY(20.0)
        self.view.addSubview(self.imgView)
    }
    
    
    /// MARK: - 子类实现的方法
    @objc public func loadNewData(){
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UUProgressHUD.dismiss()
    }
    
    deinit {
        print("\(self.className) 销毁 ~~~" )
    }
    
}
