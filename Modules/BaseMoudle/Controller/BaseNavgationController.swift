//
//  FCBaseNavgationController.swift
//  FutureCity_Swift
//
//  Created by Derrick on 2018/9/5.
//  Copyright © 2018年 bike. All rights reserved.
//

import UIKit
import RxSwift

class BaseNavgationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.shadowImage = UIImage()
        var attrs:[NSAttributedString.Key : Any] = [:]
        attrs[NSAttributedString.Key.font] = UIFont(PingFangSCRegular: 30)
        attrs[NSAttributedString.Key.foregroundColor] = Theam.FontColor.title
        self.navigationBar.titleTextAttributes = attrs
    }
    
    /// 拦截push
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back_arrow"), style: .plain, target: self, action: #selector(popBack))
        }
        super.pushViewController(viewController, animated: true)
    }
    
    /// 拦截present
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if self.viewControllers.count > 0 {
            viewControllerToPresent.hidesBottomBarWhenPushed = true
            viewControllerToPresent.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back_arrow"), style: .plain, target: self, action: #selector(dismissBack))
        }
        if self.viewControllers.count > 0 , let homeCon = self.viewControllers.first , homeCon.isKind(of: NewHomeController.self) {
            homeCon.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)

    }
    
    @objc func popBack() {
        self.view.endEditing(true)
        self.popViewController(animated: true)
    }
    
    @objc func dismissBack() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
