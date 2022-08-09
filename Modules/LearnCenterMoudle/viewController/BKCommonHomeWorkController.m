//
//  BKCommonHomeWorkController.m
//  UUEnglish
//
//  Created by Aibo on 2018/10/29.
//  Copyright © 2018年 uuabc. All rights reserved.
//    

#import "BKCommonHomeWorkController.h"
#import "BKHomeWorkQuestionCell.h"
#import "DSHttpManager.h"
#import "PrefixHeader.h"
#import "CLPlayerView.h"
#import "BKBaseAlertView.h"

#import "UUEnglish-Swift.h"

@interface BKCommonHomeWorkController () <TableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) NSMutableArray *uploadArray;
/**CLplayer*/
@property (nonatomic, weak) CLPlayerView *playerView;

/**记录Cell*/
@property (nonatomic, assign) UITableViewCell *cell;
@property (nonatomic, copy) NSString *btnTitle;
@property (nonatomic, copy) NSString *levelNum;
@end

@implementation BKCommonHomeWorkController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.moduleType == LevelType) {
        self.title = @"水平测试";
        self.btnTitle = @"提交";
    }else {
        self.title = @"作业管理";
        self.btnTitle = @"完成";
    }

    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.titleLabel.font = [UIFont PingFangSCMedium:16];
    self.submitButton.layer.cornerRadius = 17;
    self.submitButton.clipsToBounds = YES;
    [self.submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [self.submitButton setBackgroundImage:[UIImage coloreImage:[UIColor colorWithHexString:@"A1BFFF"]] forState:UIControlStateNormal];
    self.submitButton.userInteractionEnabled = NO;
    self.submitButton.frame = CGRectMake(0, 0, 95, 34);
    
//    [self.navigationController.navigationItem.rightBarButtonItem addSubview:self.submitButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.submitButton];
    
//    [self.submitButton mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(48);
//        make.right.equalTo(self.view).offset(-23);
//        make.width.equalTo(@95);
//        make.height.equalTo(@34);
//    }];
    if (self.workType == CheckHomeWork) {
        self.submitButton.hidden = YES;
    }
    self.dataList = [NSMutableArray array];
    self.uploadArray = [NSMutableArray array];
    
    [kNOTIFICATION_DEFAULT addObserverForName:kSelectAnswerNotiNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        BKHomeWorkModel *selectMode = note.object;

        NSInteger answerNum = 0;
        for (BKHomeWorkModel *model in self.dataList) {
            if ([selectMode.content_id isEqualToString:model.content_id]) {
                model.answer = selectMode.answer;
            }
            if (model.answer == -1) {
                answerNum++;
            }
        }
        if (answerNum == 0) {
            [self.submitButton setBackgroundImage:[UIImage coloreImage:[UIColor colorWithHexString:@"D93730"]] forState:UIControlStateNormal];
            self.submitButton.userInteractionEnabled = YES;
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.submitButton addAction:^(UIButton *btn) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.btnTitle isEqualToString:@"完成"]) {
            NSInteger answerNum = 0;
            for (BKHomeWorkModel *model in strongSelf.dataList) {
               if (model.answer == model.content_body.correct_option) {
                    answerNum++;
                }
            }
            
            NSString *content = [NSString stringWithFormat:@"总共%ld题，您答对%ld道，答错%ld道。", strongSelf.dataList.count, answerNum, strongSelf.dataList.count - answerNum];
            strongSelf.btnTitle = @"提交给老师";
            
            [BKBaseAlertView showAlertViewFromVc:strongSelf title:@"反馈" content:content cancelBtnTitle:nil confirmBtnTitle:@"知道了" confirmHandler:^{
                [strongSelf.submitButton setTitle:strongSelf.btnTitle forState:UIControlStateNormal];
                strongSelf.workType = CheckHomeWork;
                [strongSelf.tableView reloadData];
            }];
            
        } else {
            if (self.moduleType == LevelType) {
                [strongSelf submitLevelResult];
            } else {
                [strongSelf submitResult];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.moduleType == LevelType) {
        [self getLevelData];
    }else {
       [self getTopicResult];
    }
     
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [_playerView destroyPlayer];
}

- (void)createTableView {
    [super createTableView];
    [self.tableView registerClass:[BKHomeWorkQuestionCell class] forCellReuseIdentifier:@"BKHomeWorkQuestionCell"];
    self.tableView.layer.cornerRadius = 15;
    self.tableView.clipsToBounds = YES;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, -10);
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
}

- (CGRect)tableViewFrame {
    return CGRectMake(80, self.navBarBottom + 40, kScreenWidth - 80*2, kScreenHeight - self.navBarBottom - 80);
}
//获取作业
- (void)getTopicResult {
    
    [UUHud showHudInView:self.view];
    NSMutableDictionary *dic =  [NSMutableDictionary dictionary];
    //试卷id
    dic[@"id"] = self.test_id ;
    dic[@"clt_id"] = self.clt_id;
    dic[@"type"] = @(self.workType);
    
    [HttpManager postWithUrlString:@"homework/studentHomework.php?act=getHomeworkDetails" parameters:dic success:^(id  _Nullable response) {
        if (response) {
            [self.dataList removeAllObjects];
            NSArray *temArr = response[@"list"];
            NSMutableArray *models = [[NSMutableArray alloc] init];
            for (NSDictionary * dic in temArr) {
             BKHomeWorkModel *item = [BKHomeWorkModel mj_objectWithKeyValues:dic[@"content"]];
                item.answer = -1;
                if (![dic[@"finished_info"] isKindOfClass:[NSNull class]]){
                    item.answer = [(NSString *)dic[@"finished_info"][@"answer"] intValue];
                }
                [models addObject:item];
            }
            [self.dataList addObjectsFromArray:models];
//            NSArray *temArr = [BKHomeWorkModel mj_objectArrayWithKeyValuesArray:response[@"topic_content"]];
//
//            [self.dataList addObjectsFromArray:temArr];
        }
        [UUHud hideHudInView:self.view];
        [self.tableView reloadData];
    } failure:^(NSError * _Nullable error) {
        [UUHud hideHudInView:self.view];
    }];
}
//获取水平测试
- (void)getLevelData {
    
    [UUHud showHudInView:self.view];
    NSMutableDictionary *dic =  [NSMutableDictionary dictionary];
    [HttpManager postWithUrlString:@"courseware/topic.php?act=getLevelTestTopic" parameters:dic success:^(id  _Nullable response) {
        if (response) {
            [self.dataList removeAllObjects];
            NSArray *temArr = [BKHomeWorkModel mj_objectArrayWithKeyValuesArray:response[@"topic_content"]];
            
            self.test_id = response[@"topic_id"];
            [self.dataList addObjectsFromArray:temArr];
            [self.tableView reloadData];
        }
        [UUHud hideHudInView:self.view];
    } failure:^(NSError * _Nullable error) {
        [UUHud hideHudInView:self.view];
    }];
}

// 提交作业答案
- (void)submitResult {
    
    NSMutableArray *uploadArray = [NSMutableArray array];
    for (BKHomeWorkModel *model in self.dataList) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:model.content_id forKey:@"id"];
        [dic setObject:[NSNumber numberWithInt:model.answer] forKey:@"answer"];
        [dic setObject:[NSNumber numberWithInt:model.content_body.correct_option] forKey:@"standard_answer"];
        [uploadArray addObject:dic];
    }
    if (uploadArray.count == 0) {
        return;
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:uploadArray options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonStr];
    NSRange range = {0,jsonStr.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    NSMutableDictionary *dic =  [NSMutableDictionary dictionary];
    //试卷id
    [dic setObject:self.test_id forKey:@"test_id"];
    //课件id
    [dic setObject:self.courseware_id forKey:@"courseware_id"];
    //课程id
    [dic setObject:self.clt_id forKey:@"clt_id"];
    [dic setObject:mutStr forKey:@"result"];
    
    [UUHud showHudInView:self.view];
    [HttpManager postWithUrlString:@"courseware/courseware.php?act=createTopicResult" parameters:dic success:^(id  _Nullable response) {
        if (response) {
            self.workType = CheckHomeWork;
            self.submitButton.hidden = YES;
            [self.tableView reloadData];
        }
        [UUHud hideHudInView:self.view];
    } failure:^(NSError * _Nullable error) {
        [UUHud hideHudInView:self.view];
    }];
}
// 提交水平测试答案
- (void)submitLevelResult {
    NSInteger answerNum = 0;
    NSMutableArray *uploadArray = [NSMutableArray array];
    for (BKHomeWorkModel *model in self.dataList) {
        if (model.answer == model.content_body.correct_option) {
            answerNum++;
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"answer"]  = @(model.answer);
        dic[@"standard_answer"]  = @(model.content_body.correct_option);
        dic[@"id"]  = model.content_id;
        [uploadArray addObject:dic];
    }
    if (uploadArray.count == 0) {
        return;
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:uploadArray options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonStr];
    NSRange range = {0,jsonStr.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    NSMutableDictionary *dic =  [NSMutableDictionary dictionary];
    dic[@"topic_id"] = self.test_id;
    dic[@"correct_num"] = @(answerNum);
    dic[@"result"] = mutStr;
    
    [UUHud showHudInView:self.view];
    [HttpManager postWithUrlString:@"courseware/topic.php?act=createLevelTestResult" parameters:dic success:^(id  _Nullable response) {
        if (response) {
            self.levelNum = response[@"final_level"];
            NSString *content = [NSString stringWithFormat:@"总共%ld题，您答对%ld道，答错%ld道", self.dataList.count, answerNum, self.dataList.count - answerNum];
            
            BKBaseAlertView *alertView = [BKBaseAlertView showAlertViewFromVc:self title:@"提示" content:content cancelBtnTitle:nil confirmBtnTitle:@"知道了" confirmHandler:^{
                self.workType = CheckHomeWork;
                self.submitButton.hidden = YES;
                [self.tableView reloadData];
            }];
            [alertView setDetailStr:[NSString stringWithFormat:@"当前等级为L%@",self.levelNum]];            
        }
        [UUHud hideHudInView:self.view];
    } failure:^(NSError * _Nullable error) {
        [UUHud hideHudInView:self.view];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BKHomeWorkQuestionCell";
//    BKHomeWorkQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    BKHomeWorkQuestionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[BKHomeWorkQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BKHomeWorkModel *model = [self.dataList objectAtIndex:indexPath.row];
    cell.delegate = self;
    if (self.workType == CheckHomeWork) {
        cell.userInteractionEnabled = YES;
    }else {
        cell.userInteractionEnabled = YES;
    }
    [cell setModel:model index:indexPath.row workType:self.workType];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

//cell离开tableView时调用
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //因为复用，同一个cell可能会走多次
    if ([_cell isEqual:cell]) {
        //区分是否是播放器所在cell,销毁时将指针置空
        [_playerView destroyPlayer];
        _cell = nil;
    }
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"indexPath.section:%d",indexPath.row);
}

#pragma mark - 点击播放代理
- (void)tableViewCellPlayVideoWithCell:(BKHomeWorkQuestionCell *)cell{
    //记录被点击的Cell
    _cell = cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BKHomeWorkModel *model = self.dataList[indexPath.row];
    //销毁播放器
    [_playerView destroyPlayer];
    CLPlayerView *playerView = [[CLPlayerView alloc] init];
    _playerView = playerView;
    [cell.contentView addSubview:_playerView];
    
    [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 判断是音频还是视频
        if ([model.content_body.content_media_type containsString:@"audio"]) {
            make.left.equalTo(cell.questionView.imageView).offset(-200);
            make.height.width.equalTo(@20);
        } else if ([model.content_body.content_media_type containsString:@"video"]) {
            make.top.left.right.bottom.equalTo(cell.questionView.imageView);
        }
    }];
    
    //视频地址
    NSString *url = model.content_body.content_media;
    _playerView.url = [NSURL URLWithString:url];
    
    [_playerView updateWithConfig:^(CLPlayerViewConfig *config) {
        config.topToolBarHiddenType = TopToolBarHiddenSmall;
        config.fullStatusBarHiddenType = FullStatusBarHiddenFollowToolBar;
        //        config.smallGestureControl = YES;
    }];
    //播放
    [_playerView playVideo];
    //返回按钮点击事件回调
    [_playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    //播放完成回调
    [_playerView endPlay:^{
        //销毁播放器
        [self->_playerView destroyPlayer];
        self->_playerView = nil;
        self->_cell = nil;
        NSLog(@"播放完成");
    }];
}
@end
