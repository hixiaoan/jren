//
//  HomeworkManagerController.swift
//  UUEnglish
//
//  Created by iOSDeveloper on 2020/10/14.
//  Copyright © 2020 uuabc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@objcMembers class HomeworkManagerController: BaseTableController {
    
    var test_id: String?
    var statusModel = BKTopicStatusModel()
    
    var viewModel: HomeworkManagerViewModel!
    lazy var clt_id: String = ""
    lazy var courseware_id: String = ""
    lazy var requestObsevable = PublishSubject<(String,String)>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "作业"
        setViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestObsevable.onNext((self.clt_id,self.test_id ?? ""))
    }
    
    override func createTableView() {
        super.createTableView()
        self.tableView?.clipsToBounds = true;
        self.tableView?.isScrollEnabled = false;
        self.tableView?.separatorColor = UIColor.clear
        self.tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        self.tableView?.rowHeight = UITableView.automaticDimension
        self.tableView?.backgroundColor = .clear
    }
    
    override func tableViewFrame() -> CGRect {
        CGRect(x: 0, y: self.navBarBottom + 20, width: kScreenWidth, height: kScreenHeight - self.navBarBottom)
    }
    
    @discardableResult
    func setViewModel() -> HomeworkManagerController {
        viewModel = HomeworkManagerViewModel(autoRequestObservable: requestObsevable , dispose: dispose)
        viewModel.responseData.bind(to: handleResponse).disposed(by: dispose)
        return self
    }
    
    var handleResponse: Binder<HomeworkManagerModel>{
        return Binder(self){vc, model in
            vc.statusModel.status = model.status
            vc.statusModel.remark = model.remark
            vc.statusModel.remark_image = model.remark_image
            vc.tableView?.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String = "BKHomeWorkCell1"
        var cell : UITableViewCell
            
        //    section为1 判断学生的状态，有没有完成作业 1-待完成, 2-已完成
            if (indexPath.section == 0 ) {
                cell = BKHomeWorkStartCell.createViewFromNib()
                (cell as! BKHomeWorkStartCell).topicButton.addAction { (btn) in
                    
                    let controller  = BKCommonHomeWorkController()
                    if (self.statusModel.status == 1) {
                        controller.workType = .DoHomeWork;
                    }else {
                        controller.workType = .CheckHomeWork;
                    }
                    controller.moduleType = .HomeworkType;
                    if (self.test_id != nil) {
                        controller.test_id = self.test_id!;
                    }
                    
                    controller.courseware_id = self.courseware_id;
                    controller.clt_id = self.clt_id;

                    self.navigationController?.pushViewController(controller, animated: true)
                }
                 (cell as! BKHomeWorkStartCell).dataModel(self.statusModel)
            }else{
                
                cell = BKTeacherCommentsCell.init(style: .default, reuseIdentifier: identifier)
        //      section为2 判断老师的状态，为3，表示老师已经评价
                cell.backgroundColor = .red
                (cell as! BKTeacherCommentsCell).configModel(self.statusModel)
            }
        cell.selectionStyle = .none;
        cell.backgroundColor = .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if (indexPath.section == 0) {
            return 113;
        }
        return 600;
    }
    
}


class HomeworkManagerViewModel {
    
    let responseData = PublishSubject<HomeworkManagerModel>()
    let apiService = HomeworkManagerService()
    var requestError : Binder<Void>{
        return Binder(self){_,_ in
            print("请求失败")
        }
    }
    init(autoRequestObservable:Observable<(String,String)>,dispose: DisposeBag) {
        apiService.reuqestData.elements.hideLoading().bind(to: responseData).disposed(by: dispose)
        apiService.reuqestData.errors.hideLoading().map { _ in}.bind(to: requestError).disposed(by: dispose)
        autoRequestObservable.showLoading().map { tuples -> [String : Any] in
            var dic = [String : Any]()
            dic["clt_id"] = tuples.0
            dic["type"] = "1"
            if tuples.1.length > 0{
                dic["id"] = tuples.1
            }
            return dic
        }.bind(to: apiService.reuqestData.inputs).disposed(by: dispose)
    }
    
}

class HomeworkManagerService {

    lazy var reuqestData = Action<[String: Any],HomeworkManagerModel>.init { (dic) -> Observable<HomeworkManagerModel> in
        RxProvider.instance.rx.requestEducation(url: LearnCenterApi.homeListUrl, parameters: dic).asObservable().mapObject(HomeworkManagerModel.self, "jsondata")
    }
    
}

struct HomeworkManagerModel: HandyJSON{
    var status: Int = 0
    var remark: String = ""
    var remark_image = [String]()
}
