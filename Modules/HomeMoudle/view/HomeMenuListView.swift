//
//  HomeMenuListView.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/7.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

class HomeMenuListView: UIView {

    ///订单
    lazy var orderBtn       = UIButton.creatHomeButton(title: "订单", font: 16, titleColor: "#FFFFFF", image: "NewHomeFuncOrder")
    ///约课
    lazy var orderClassBtn  = UIButton.creatHomeButton(title: "约课", font: 16, titleColor: "#FFFFFF", image: "NewHomeFuncClass")
    ///设置
    lazy var setBtn         = UIButton.creatHomeButton(title: "设置", font: 16, titleColor: "#FFFFFF", image: "NewHomeFuncSet")
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HomeMenuListView{
    
    func setupUI() {
        
        self.addSubview(orderBtn)
        orderBtn.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(kScreenScale(72))
        }
        
        self.addSubview(orderClassBtn)
        orderClassBtn.snp.makeConstraints { (make) in
            make.centerX.top.bottom.equalToSuperview()
            make.width.equalTo(kScreenScale(72))
        }
        
        self.addSubview(setBtn)
        setBtn.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(kScreenScale(72))
        }
    }
}
