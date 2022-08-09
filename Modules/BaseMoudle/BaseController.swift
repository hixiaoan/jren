//
//  BaseController.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/4.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxSwift

///作为返回按钮的判断
enum JumpType {
    case PUSH
    case PRESENT
}


class BaseController: UIViewController {
    
    
      var dispose = DisposeBag()
    
      override func viewDidLoad() {
          super.viewDidLoad()

      }
      
      
      deinit {
          prints("\(self.className)释放")
      }
    
}
