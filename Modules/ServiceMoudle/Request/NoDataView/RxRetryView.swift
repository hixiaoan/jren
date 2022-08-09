//
//  RxRetryView.swift
//  UUStudent
//
//  Created by Asun on 2020/7/20.
//  Copyright © 2020 UUabc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//public class RxRetryView: UIView {
//    
//    private let contentView = UIView().then{
//        $0.backgroundColor = .clear
//    }
//    
//    private let imageView = UIImageView().then{
//        $0.isUserInteractionEnabled = true
//    }
//    
//    private let contentLabel = UILabel().then{
//        $0.font = UIFont.init(PingFangSCRegular: 16)
//        $0.textColor = Theam.FontColor.title
//        $0.textAlignment = .center
//        $0.numberOfLines = 1
//    }
//    
//    private let titleLabel = UILabel().then{
//        $0.font = UIFont.init(PingFangSCRegular: 14)
//        $0.textColor = .init(hexString: "3c3e42")
//        $0.textAlignment = .center
//        $0.numberOfLines = 1
//    }
//    
//    private lazy var retryButton: UIButton = {
//        let btn = UIButton()
//        btn.setTitleColor(UIColor.white, for: .normal)
//        btn.setBackgroundImage(UIImage.init(named: "gradient_background_corner"), for: .normal)
//        btn.titleLabel?.font = UIFont.init(PingFangSCRegular: 16)
//        btn.layer.cornerRadius = 21
//        btn.clipsToBounds = true
//        return btn
//    }()
//    
//    public var retryEmptyDataType: EmptyDataType = .Success {
//        didSet {
//            var text: String = ""
//            var imageName: String = ""
//            var btnTextName:String = ""
//            var contentText: String = ""
//            switch retryEmptyDataType {
//            case .TimeOut:
//                contentText = "网速居然这么慢🐌"
//                text = "再给我一次机会，试试看刷新页面~"
//                btnTextName = "刷新"
//            case .Network:
//                contentText = "网络竟然崩溃了😱"
//                text = "别紧张，试试看刷新页面~"
//                btnTextName = "刷新"
//            case .NoData: 
//                contentText = "哎呀，没有内容了😣"
//                text = "试试看滑动刷新页面~"
//                btnTextName = ""
//            case .Service:
//                contentText = "哎呀，崩溃了😭"
//                text = "别紧张，试试看刷新页面~"
//                btnTextName = "刷新"
//            case .NotLogin:
//                contentText = "哼，居然还没有登录😡"
//                text = "快点去登录，才能查看更多内容~"
//                btnTextName = "登录"
//            case .Success:
//                text = ""
//                imageName = ""
//                btnTextName = ""
//                contentText = ""
//            }
//            imageName = kNoDataPlaceHolder
//            updateTitleLabel(text: text)
//            updateImageNamed(name: imageName)
//            updateRetryWithHidden(btnTextCount: btnTextName.count)
//            updateRetryWithText(text: btnTextName)
//            updateRetryWithContent(text: contentText)
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addChildViews()
//        layoutChildViews()
//        bindData()
//    }
//    
//    func bindData() {
//        
//    }
//    
//    private func addChildViews() {
//        addSubview(contentView)
//        contentView.addSubview(imageView)
//        contentView.addSubview(contentLabel)
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(retryButton)
//    }
//    
//    private func layoutChildViews() {
//        contentView.snp.makeConstraints{
//            $0.center.equalToSuperview()
//            $0.size.equalTo(CGSize(width: ScreenWidth, height: ScreenHeight/2))
//        }
//        
//        imageView.snp.makeConstraints{
//            $0.centerX.top.equalTo(contentView)
//        }
//        
//        contentLabel.snp.makeConstraints{
//            $0.top.equalTo(imageView.snp.bottom).offset(20)
//            $0.centerX.equalTo(imageView)
//        }
//        
//        titleLabel.snp.makeConstraints{
//            $0.top.equalTo(contentLabel.snp.bottom).offset(12)
//            $0.centerX.equalTo(imageView)
//        }
//        
//        retryButton.snp.makeConstraints{
//            $0.top.equalTo(titleLabel.snp.bottom).offset(50)
//            $0.centerX.equalTo(imageView)
//            $0.size.equalTo(CGSize(width: 120, height: 42))
//        }
//    }
//    
//    public func getRetryBtnRxTapObserver() -> Observable<Void>{
//        return retryButton.rx.tap.debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).asObservable()
//    }
//    
//    private func updateRetryWithContent(text: String) {
//        let attributes:[NSAttributedString.Key:AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.init(PingFangSCRegular: 16),NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): Theam.FontColor.title]
//        contentLabel.textAlignment = .center
//        contentLabel.attributedText = NSAttributedString.init(string: text, attributes: attributes)
//    }
//    
//    private func updateRetryWithHidden(btnTextCount: Int) {
//        retryButton.isHidden = btnTextCount == 0
//    }
//    
//    private func updateRetryWithText(text: String) {
//        retryButton.setTitle(text, for: .normal)
//    }
//    
//    private func updateImageNamed(name: String) {
//        imageView.image = UIImage(named: name)
//    }
//    
//    private func updateTitleLabel(text: String) {
//        let attributes:[NSAttributedString.Key:AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.init(PingFangSCRegular: 14),NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): Theam.FontColor.gray1]
//        titleLabel.textAlignment = .center
//        titleLabel.attributedText = NSAttributedString.init(string: text, attributes: attributes)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
