//
//  Home0ppointmentClassView.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/8.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit

class HomeOppointmentClassView: UIView {

    
    fileprivate lazy var backgroundImageView = UIImageView.init(image: kImage("NewHomeCourseBg"))
    fileprivate lazy var titleLable = UILabel.createMediumLable(text: "dsdsdsd", font: 19, colorStr: "#ffffff")
    fileprivate lazy var logImageView = UIImageView.init(image: kImage("NewHomeCourseContentIcon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}


extension HomeOppointmentClassView{
    
    func setupUI() {
        
        self.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        backgroundImageView.addSubview(titleLable)
        titleLable.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kScreenScale(30))
            make.left.equalToSuperview().offset(kScreenScale(19))
            make.right.equalToSuperview().offset(kScreenScale(-10))
        }
        
        backgroundImageView.addSubview(logImageView)
        logImageView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLable.snp.bottom).offset(kScreenScale(20))
            make.left.equalToSuperview().offset(kScreenScale(30))
        }
    }
}
