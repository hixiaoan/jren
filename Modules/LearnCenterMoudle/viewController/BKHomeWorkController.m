//
//  BKHomeWorkController.m
//  msyork
//
//  Created by Derrick on 2018/10/8.
//  Copyright © 2018年 bike. All rights reserved.
//

#import "BKHomeWorkController.h"
#import "PrefixHeader.h"
#import "BKHomeWorkStartCell.h"
#import "BKTeacherCommentsCell.h"
#import "BKCommonHomeWorkController.h"
#import "BKTopicStatusModel.h"
#import "UUEnglish-Swift.h"

@interface BKHomeWorkController ()

@property (nonatomic, strong) BKTopicStatusModel *statusModel;
@end

@implementation BKHomeWorkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"作业";

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getTopicResult];
}

- (void)createTableView {
    [super createTableView];
    self.tableView.clipsToBounds = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, -10);
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (CGRect)tableViewFrame {
    return CGRectMake(0, self.navBarBottom + 20, kScreenWidth, kScreenHeight - self.navBarBottom);
}

- (void)getTopicResult{
    NSMutableDictionary *dic =  [NSMutableDictionary dictionary];
    
    //请求类型（1:学生端查询作业状态 2:老师端查询作业状态）
    //试卷ID
    [dic setObject:@"1" forKey:@"type"];
    if (self.test_id !=nil) {
         [dic setObject:self.test_id forKey:@"id"];
    }
    dic[@"clt_id"] = self.clt_id;
    [HttpManager postWithUrlString:@"courseware/courseware.php?act=getTopicStatus" parameters:dic success:^(id  _Nullable response) {
        if (response) {
            self.statusModel = [BKTopicStatusModel mj_objectWithKeyValues:response];
//            [self.tableView reloadData];
        }
        [self.tableView reloadData];
    } failure:^(NSError * _Nullable error) {
    }];
}

#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        return 113;
    }
    return 600;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"BKHomeWorkCell1";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    UITableViewCell *cell;
    
//    section为1 判断学生的状态，有没有完成作业 1-待完成, 2-已完成

    if (indexPath.section == 0 ) {
        cell = [BKHomeWorkStartCell createViewFromNib];
        [((BKHomeWorkStartCell*)cell).topicButton addAction:^(UIButton *btn) {
            BKCommonHomeWorkController *controller = [[BKCommonHomeWorkController alloc] init];
            if (self.statusModel.status == 1) {
                controller.workType = DoHomeWork;
            }else {
                controller.workType = CheckHomeWork;
            }
            controller.moduleType = HomeworkType;
            if (self.test_id != nil) {
                controller.test_id = self.test_id;
            }
            
            controller.courseware_id = self.courseware_id;
            controller.clt_id = self.clt_id;

            [self.navigationController pushViewController:controller animated:YES];
        }];
        [((BKHomeWorkStartCell*)cell) setModel:self.statusModel];
    }else if(indexPath.section == 1 ) {
        
//      section为2 判断老师的状态，为3，表示老师已经评价
        cell = [[BKTeacherCommentsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor redColor];
        [((BKTeacherCommentsCell*)cell) setModel:self.statusModel];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath.section:%d",indexPath.section);
    return;
    if (indexPath.section == 0) {
        BKCommonHomeWorkController *controller = [[BKCommonHomeWorkController alloc] init];
        if (self.statusModel.status == 1) {
            controller.workType = DoHomeWork;
        }else {
            controller.workType = CheckHomeWork;
        }
        controller.moduleType = HomeworkType;
        controller.test_id = self.test_id;
        controller.courseware_id = self.courseware_id;
        controller.clt_id = self.clt_id;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
@end
