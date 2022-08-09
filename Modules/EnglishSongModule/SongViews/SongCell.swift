//
//  SongCell.swift
//  UUEnglish
//
//  Created by Asun on 2020/9/17.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public enum SongSegmentStatus {
    case songRecord
    case songSquare
    case songHistory
}

class SongCell: UICollectionViewCell {
    
    lazy var customContentView: UIView = UIView().then{
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
        $0.backgroundColor = .white
    }
    
    lazy var songImageView = UIImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    lazy var readedTagView = UIImageView().then{
        $0.image = kImage("egsong_video")
        $0.contentMode = .center
    }
    
    lazy var titleLabel = UILabel().then{
        $0.font = .init(PingFangSCMedium: 25)
        $0.textColor = .init(hexString: "534F4F")
        $0.textAlignment = .center
    }
    
    lazy var coverView = UIView().then{
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    lazy var dateLabel = UILabel().then{
        $0.textColor = .white
        $0.font = .init(PingFangSCMedium: 25)
    }
    
    lazy var userLabel = UILabel().then{
        $0.textColor = .white
        $0.font = .init(PingFangSCMedium: 21)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configCell()
        configCellConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SongCell {
    fileprivate func configCell() {
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(customContentView)
        customContentView.addSubview(songImageView)
        customContentView.addSubview(readedTagView)
        contentView.addSubview(titleLabel)
        customContentView.addSubview(coverView)
        coverView.addSubview(dateLabel)
        coverView.addSubview(userLabel)
    }
    
    fileprivate func configCellConstraints() {
        customContentView.snp.makeConstraints{
            $0.right.top.left.equalTo(contentView)
            $0.bottom.equalTo(contentView).offset(-40)
        }
        
        songImageView.snp.makeConstraints{
            $0.edges.equalTo(customContentView)
        }
        
        readedTagView.snp.makeConstraints{
            $0.center.equalTo(customContentView)
        }
        
        titleLabel.snp.makeConstraints{
            $0.left.right.equalTo(contentView)
            $0.top.equalTo(customContentView.snp.bottom).offset(10)
        }
        
        coverView.snp.makeConstraints{
            $0.left.right.bottom.equalTo(customContentView)
            $0.height.equalTo(64)
        }
        
        dateLabel.snp.makeConstraints{
            $0.left.equalTo(coverView).offset(16)
            $0.centerY.equalTo(coverView)
        }
        
        userLabel.snp.makeConstraints{
            $0.centerY.equalTo(coverView)
            $0.right.equalTo(coverView).offset(-16)
        }
    }
    
    public func bindResult(_ viewItem: SongRecordListCellViewModel) {
        viewItem.output.contentImage.bind(to: self.songImageView.rx.webImage()).disposed(by: rx.disposeBag)
        viewItem.output.dateText.bind(to: self.dateLabel.rx.text).disposed(by: rx.disposeBag)
        viewItem.output.nameText.bind(to: self.userLabel.rx.text).disposed(by: rx.disposeBag)
        viewItem.output.titleText.bind(to: self.titleLabel.rx.text).disposed(by: rx.disposeBag)
        viewItem.output.songCoverIsHidden.bind(to: self.coverView.rx.isHidden).disposed(by: rx.disposeBag)
    }
}
