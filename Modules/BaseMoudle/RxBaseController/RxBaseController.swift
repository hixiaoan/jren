//
//  BaseController.swift
//  UUStudent
//
//  Created by Asun on 2020/7/17.
//  Copyright © 2020 UUabc. All rights reserved.
//

import UIKit
import Then
import RxSwift
import RxCocoa

class RxBaseController: UIViewController {
    
    @objc public var navBarHeight: CGFloat = {
        return 64
    }()
    
    @objc public var tabBarHeight: CGFloat = {
        return 49
    }()
    
    var dispose = DisposeBag()
    
    lazy var imgView: UIImageView = {
        let img = UIImageView.init(frame: self.view.bounds)
        img.image = UIImage(named: "backImg")
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        return img
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        wr_setNavBarBackgroundAlpha(0)
        wr_setNavBarShadowImageHidden(true)
        wr_setNavBarBarTintColor(Theam.Color.background)
        wr_setNavBarTitleColor(Theam.FontColor.title)
        self.navigationController?.navigationBar.wr_setTranslationY(20.0)
        self.view.insertSubview(imgView, at: 0)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UUProgressHUD.dismiss()
    }
    
    
    /// 关闭控制器方法
    func close() {
        
    }
    
    /// MARK: - 子类实现的方法
    @objc public func loadNewData(){
        
    }
    
    deinit {
        print("\(self.className) 销毁 ~~~" )
    }
    
}


