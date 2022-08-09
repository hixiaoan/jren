//
//  HomeSetView.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/9/7.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxSwift
enum SetType {
    
    case outLogin
    case setPassword
    case textDevice
    case reload
}

class HomeSetView: UIView {
    
    let cellAction = PublishSubject<SetType>()
    fileprivate lazy var backgroundImageView = UIImageView.init(image: kImage("NewHomeFuncSetbg")).then { (make) in
        make.isUserInteractionEnabled = true
    }
    
    lazy var tableView = UITableView().then { (make) in
        make.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        make.separatorStyle = .none
        make.rowHeight = kScreenScale(180/4)
    }
    
    let dispose = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = true;
        setupUI().tableViewConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HomeSetView{
    
    func tableViewConfig(){
        Observable.just([
        "退出登录",
        "修改密码",
        "设备检测",
        "刷新",
        ]).bind(to: tableView.rx.items){ (view, row, element) in
            let cell = view.dequeueReusableCell(withIdentifier: "cell")!
            cell.selectionStyle = .none
            cell.textLabel?.text = element
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.init(PingFangSCRegular: 20)
            cell.textLabel?.textColor = UIColor.blue
            return cell
        }.disposed(by: dispose)
        
        tableView.rx.itemSelected.asObservable().map { indexPath in
            if indexPath.row == 0{
                return SetType.outLogin
            }else if indexPath.row == 1{
                return SetType.setPassword
            }else if indexPath.row == 2{
                return SetType.textDevice
            }else{
                return SetType.reload
            }
            }.bind(to: cellAction).disposed(by: dispose)
        
        tableView.rx.itemSelected.asObservable().map{_ in true}.bind(to: isHiddenAction).disposed(by: dispose)
    }
    
    var isHiddenAction: Binder<Bool>{
        return Binder(self){ view , state in
            view.isHidden = state
        }
    }
}

extension HomeSetView{
    
    @discardableResult
    func setupUI() -> HomeSetView{
        self.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kScreenScale(180))
        }
        return self
    }
    
}

class SetTableViewCell: UITableViewCell{
    
    let dispose = DisposeBag()
    lazy var button = UIButton().then { (make) in
        make.setTitle("", for: .normal)
        make.setTitleColor(UIColor.blue, for: .normal)
        make.titleLabel?.font = UIFont.init(PingFangSCRegular: 20)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier:  reuseIdentifier)
        self.isUserInteractionEnabled = true
        self.contentView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setTitle(_ title: String){
        self.button.setTitle(title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
