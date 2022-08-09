//
//  BKCourseController.m
//  usasishu
//
//  Created by Derrick on 2018/7/2.
//  Copyright © 2018年 bike. All rights reserved.
//

#import "BKCourseController.h"
#import "Macro.h"
#import "Category.h"
#import "DSHttpManager.h"
#import <Masonry/Masonry.h>
#import <MJExtension/MJExtension.h>
#import "BKAnimationRefreshHeader.h"
#import "General_Configuration.h"
#import "UIFont+Fonts.h"
#import "BKPreviewController.h"
#import "BKCheckFeedbackController.h"
#import "BKCommonHomeWorkController.h"
#import "BKHomeWorkController.h"
#import "BKWebViewController.h"
#import "UUProgressHUD.h"
#import "BKAskForLeaveController.h"
#import "BKAdjustClassAlertView.h"
#import "BKLeaveSuccessAlert.h"
#import "BKConfirmAdjustClassAlert.h"
#import "UUEnglish-Swift.h"

@interface BKCourseController ()
///
@property (nonatomic, strong) NSDictionary *confInfo;
///
@property (nonatomic, strong) NSDictionary *userInfo;
///
@property (nonatomic, strong) NSDictionary *roomInfo;
///
@property (nonatomic, copy) NSString *clt_id;
@property (strong, nonatomic) NSCalendar *gregorian;

@property (nonatomic, strong) UIButton *askLeaveBtn;

@property (nonatomic, strong) NSDateFormatter *selectFormatter;

@end

@implementation BKCourseController

- (void)viewDidLoad {
    [super viewDidLoad];

    _confInfo = @{};
    _userInfo = @{};
    _roomInfo = @{};
    _eventArray = @[].mutableCopy;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    self.selectFormatter = [[NSDateFormatter alloc] init];
    self.selectFormatter.dateFormat = @"yyyy-MM-dd";
    
    // 获取当天的日期
    _date = [[NSDate date] YYYY_MM_dd];
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    self.title = @"我的课程表";
    self.haveData = YES;
    [self initSubViews];
    [self refreshData];
}


- (void)refreshData {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"date"] = _date;
    [HttpManager postWithUrlString:@"course/classTimes.php?act=getStudentClass" parameters:params success:^(id  _Nullable response) {
        if (response) {
            self.model = [BKTodayCourseModel mj_objectWithKeyValues:response];
            for (BKClOverviewModel *overViewModel in self.model.cl_overview) {
                NSDate *eventDate = [overViewModel.cl_date date];
                NSString *eventDateStr = [self.dateFormatter stringFromDate:eventDate];
                [self.eventArray addObject:eventDateStr];
            }
            [self.tableView reloadData];
            [self.calendar reloadData];
            [self.tableView.mj_header endRefreshing];
            self.haveData = self.model.class_list.count > 0 ? YES : NO;
            [self.tableView reloadEmptyDataSet];
        }
    } failure:^(NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
        
    }];
}

- (void)initSubViews {
        
    [self.view addSubview:self.contenView];
    [self.contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(37);
        make.right.equalTo(self.view.mas_right).offset(-37);
        make.bottom.equalTo(self.view.mas_bottom).offset(-29);
        make.top.equalTo(self.view.mas_top).offset(100);
    }];
    
    [self.contenView addSubview:self.calendar];
    [self.calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contenView.mas_top).offset(84);
        make.height.mas_equalTo(300);
        make.left.equalTo(self.contenView.mas_left).offset(44);
        make.right.equalTo(self.contenView.mas_right).offset(-44);
    }];
    
    [self.contenView addSubview:self.previousButton];
    [self.contenView addSubview:self.nextButton];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contenView.mas_right).offset(-44);
        make.top.mas_equalTo(30);
    }];
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contenView.mas_left).offset(44);
        make.top.mas_equalTo(30);
    }];
    
    [self.contenView addSubview:self.dateTitleView];
    [self.dateTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contenView.mas_centerX);
        make.top.equalTo(self.contenView.mas_top).offset(55);
        make.width.equalTo(@(230));
        make.height.equalTo(@(37));
    }];
    [self.dateTitleView addSubview:self.dateTitelLabel];
    [self.dateTitelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.dateTitleView.mas_centerX);
        make.top.equalTo(self.dateTitleView.mas_top);
        make.width.equalTo(@(230));
        make.height.equalTo(@(37));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contenView.mas_top).offset(206);
        make.left.equalTo(self.contenView.mas_left).offset(41);
        make.right.equalTo(self.contenView.mas_right).offset(-41);
        make.bottom.equalTo(self.contenView.mas_bottom).offset(-20);
    }];
    [self.contenView bringSubviewToFront:self.tableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.askLeaveBtn];
}


#pragma mark - action

/// 上一周
- (void)previousClicked:(id)sender
{
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *previousMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitWeekOfMonth value:-1 toDate:currentMonth options:0];
    _lastSelectDate = previousMonth;
    [self.calendar setCurrentPage:previousMonth animated:NO];
    _date = [previousMonth YYYY_MM_dd];
    self.dateTitelLabel.text = [self getDateFromThisWeek:previousMonth];
    [self animateTextChange:0.2 animationSubType:kCATransitionFromTop];
    [self refreshData];
    // 默认选中这周的第一天
    [self.calendar selectDate:previousMonth];
}

/// 下一周
- (void)nextClicked:(id)sender
{
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitWeekOfMonth value:1 toDate:currentMonth options:0];
    _lastSelectDate = nextMonth;
    [self.calendar setCurrentPage:nextMonth animated:NO];
    _date = [nextMonth YYYY_MM_dd];
    
    self.dateTitelLabel.text = [self getDateFromThisWeek:nextMonth];
    [self animateTextChange:0.2 animationSubType:kCATransitionFromBottom];
    [self refreshData];
    [self.calendar selectDate:nextMonth];
    
}

- (void)askLeaveAction {
    BKAskForLeaveController *vc = [[BKAskForLeaveController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - setter

-(FSCalendar *)calendar{
    if (_calendar == nil) {
        _calendar = [[FSCalendar alloc] init];
        _calendar.dataSource = self;
        _calendar.delegate = self;
        _calendar.backgroundColor = [UIColor clearColor];
        /// Monday to sunday
        _calendar.firstWeekday = 2;
        _calendar.scope = FSCalendarScopeWeek;
        _calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        // 默认日期颜色
        _calendar.appearance.titleDefaultColor = [UIColor colorWithHexString:MainThemeColor];
        
        _calendar.appearance.weekdayTextColor = [UIColor colorWithHexString:@"38393A"];
        _calendar.appearance.weekdayFont = [UIFont PingFangSCMedium:20];
        // 头部日期的颜色
        _calendar.appearance.headerTitleColor = [UIColor clearColor];
        _calendar.appearance.selectionColor = [UIColor colorWithHexString:MainThemeColor];
        _calendar.appearance.headerMinimumDissolvedAlpha = 0;
        _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase;
        _calendar.appearance.titleTodayColor = [UIColor colorWithHexString:MainThemeColor];
        _calendar.appearance.todayColor = [UIColor clearColor];
        _calendar.appearance.eventOffset = CGPointMake(0, 6);
        _calendar.appearance.eventSelectionColor = [UIColor clearColor];
        _calendar.clipsToBounds = YES;
        
    }
    return _calendar;
}

- (UIButton *)previousButton{
    if (_previousButton == nil) {
        _previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previousButton.backgroundColor = [UIColor clearColor];
        [_previousButton setImage:[UIImage imageNamed:@"previousWeek"] forState:UIControlStateNormal];
        [_previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previousButton;
}

- (UIButton *)nextButton{
    if (_nextButton == nil) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.backgroundColor = [UIColor clearColor];
        [_nextButton setImage:[UIImage imageNamed:@"nextWeek"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIView *)contenView{
    if (_contenView == nil) {
        _contenView = [[UIView alloc] init];
        _contenView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.45];
        
        _contenView.layer.cornerRadius = 22.f;
        _contenView.layer.masksToBounds = YES;
    }
    return _contenView;
}

- (UIView *)dateTitleView {
    if (_dateTitleView == nil) {
        _dateTitleView = [[UIView alloc] init];
        _dateTitleView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.83];
        _dateTitleView.layer.cornerRadius = 37 * 0.5;
        _dateTitleView.layer.masksToBounds = YES;
        
    }
    return _dateTitleView;
}

- (UILabel *)dateTitelLabel {
    if (_dateTitelLabel == nil) {
        _dateTitelLabel = [[UILabel alloc] init];
        _dateTitelLabel.text = [self getDateFromThisWeek:[NSDate date]];
        _dateTitelLabel.textColor = [UIColor colorWithHexString:@"787274"];
        _dateTitelLabel.textAlignment = NSTextAlignmentCenter;
        _dateTitelLabel.font = [UIFont PingFangSCRegular:20];
        
    }
    return _dateTitelLabel;
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 190;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.allowsSelection = NO;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        [self.contenView addSubview:_tableView];
        BKAnimationRefreshHeader * header =
        [BKAnimationRefreshHeader headerWithRefreshingBlock:^{
            [self.eventArray removeAllObjects];
            [self refreshData];
        }];
        self.tableView.mj_header = header;
    }
    return _tableView;
}

- (UIButton *)askLeaveBtn {
    if (_askLeaveBtn == nil) {
        _askLeaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _askLeaveBtn.backgroundColor = [UIColor colorWithHexString:@"3D7AFF"];
        _askLeaveBtn.frame = CGRectMake(0, 0, 95, 33);
        [_askLeaveBtn setTitle:@"请假管理" forState:UIControlStateNormal];
        [_askLeaveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _askLeaveBtn.titleLabel.font = [UIFont PingFangSCMedium:12];
        _askLeaveBtn.layer.cornerRadius = 16.0;
        _askLeaveBtn.layer.masksToBounds = YES;
        [_askLeaveBtn addTarget:self action:@selector(askLeaveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _askLeaveBtn;
}

#pragma mark - util
// 获取本周第一天和最后一天的日期
- (NSString *)getDateFromThisWeek:(NSDate *)now {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:now];
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    // 获取几天是几号
    NSInteger day = [comp day];
    
    // 计算当前日期和本周的星期一和星期天相差天数
    long firstDiff,lastDiff;
    //    weekDay = 1;
    if (weekDay == 1)
    {
        firstDiff = -6;
        lastDiff = 0;
    }
    else
    {
        firstDiff = [calendar firstWeekday] - weekDay + 1;
        lastDiff = 8 - weekDay;
    }
    
    // 在当前日期(去掉时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay   fromDate:now];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay   fromDate:now];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];

    NSDateFormatter *formater1 = [[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"yyyy/MM/dd"];
    
    NSDateFormatter *formater2 = [[NSDateFormatter alloc] init];
    [formater2 setDateFormat:@"MM/dd"];
    

    return [NSString stringWithFormat:@"%@-%@",[formater1 stringFromDate:firstDayOfWeek],[formater2 stringFromDate:lastDayOfWeek]];
}

// 文本替换动画
- (void)animateTextChange:(CFTimeInterval)duration animationSubType:(NSString *)subtype{
    CATransition *trans = [[CATransition alloc] init];
    trans.type = kCATransitionPush;
    trans.subtype = subtype;
    trans.duration = duration;
    trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.dateTitelLabel.layer addAnimation:trans forKey:kCATransitionPush];
}


#pragma mark - FSCalendarDataSource
// 设置今天的样式为边框样式
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    
    NSString *key = [self.dateFormatter stringFromDate:date];
    
    NSString *now = [self.dateFormatter stringFromDate:[NSDate date]];;
    if ([key isEqualToString:now]) {
        return [UIColor colorWithHexString:MainThemeColor];
    }
    return appearance.borderDefaultColor;
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    NSDate *currentMonth = calendar.currentPage;
    NSDate *date = self.lastSelectDate == nil ? [NSDate date] : self.lastSelectDate;
    NSComparisonResult result = [date compare:currentMonth];
    NSString *subtype = @"";
    if (result == NSOrderedAscending) {
        subtype = kCATransitionFromTop;
    }else if (result == NSOrderedDescending) {
        subtype = kCATransitionFromBottom;
    }
    
    self.date = [currentMonth YYYY_MM_dd];
    self.dateTitelLabel.text = [self getDateFromThisWeek:currentMonth];
    [self animateTextChange:0.2 animationSubType:subtype];
    self.lastSelectDate = currentMonth;
    [self.calendar selectDate:currentMonth];
    [self refreshData];
}


- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    self.date = [self.selectFormatter stringFromDate:date];
    [self refreshData];
}

#pragma mark - <FSCalendarDataSource>
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    return 1;
}
- (NSArray *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter stringFromDate:date];
    if (self.eventArray.count > 0) {
        if ([self.eventArray containsObject:key]) {
            return @[[UIColor colorWithHexString:@"4A4A4A"]];
        }
    }
    return @[[UIColor clearColor]];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter stringFromDate:date];
    if ([self.eventArray containsObject:key]) {
        return @[[UIColor colorWithHexString:@"4A4A4A"]];
    }
    return @[[UIColor clearColor]];
}

- (nullable NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date{
    NSString *key = [self.dateFormatter stringFromDate:date];
    
    NSString *now = [self.dateFormatter stringFromDate:[NSDate date]];;
    if ([key isEqualToString:now]) {
        return @"今";
    }
    NSString *dateTile = [[key componentsSeparatedByString:@"-"] lastObject];
    return dateTile;
}


#pragma mark - UItableViewDataSource

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.class_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BKTodayCourseCell";
    BKTodayCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [BKTodayCourseCell createViewFromNib];
    }
    cell.data = self.model.class_list[indexPath.row];
    [cell loadContent];
    __weak __typeof(self)weakSelf = self;
    
    cell.coursewareCheckHandler = ^(BKCourseInfoModel *model){
        
        if (model.has_courseware != 1) { // 没有课件
            if (!model.has_courseware_txt.isEmpty) {
                [UUProgressHUD showWarnWithStatus:model.has_courseware_txt];
            }
            return;
        }
        
        BKPreviewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BKPreviewController"];
        controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
        controller.clt_id = model.ct_id;
        controller.courseware_id = model.courseware_id;

        [weakSelf presentViewController:controller animated:YES completion:nil];
    };
    cell.feedbackCheckHandler = ^(BKCourseInfoModel *model){
        BKCheckFeedbackController *controller = [[BKCheckFeedbackController alloc] init];
        controller.cltId = model.ct_id;
        controller.clTeacherid = model.cl_teacherid;
        [weakSelf.navigationController pushViewController:controller animated:YES];
    };
    cell.reviewVideoCheckHandler = ^(BKCourseInfoModel *model){
        if (!model.record_url.isEmpty) {
            MSWebViewController *vc = [[MSWebViewController alloc] init];
            vc.url = model.record_url;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [UUProgressHUD showWarnWithStatus:@"回顾视频还在生成中，请耐心等候"];
        }
    };
    cell.homeworkHandler = ^(BKCourseInfoModel *model) {
        HomeworkManagerController *vc = [[HomeworkManagerController alloc] init];
        vc.test_id = model.test_id;
        vc.clt_id = model.ct_id;
        vc.courseware_id = model.courseware_id;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    
    cell.adjustClassHandler = ^(BKCourseInfoModel *model) {
        if (model.class_extra_status.integerValue != 1) {
            [UUProgressHUD showWarnWithStatus:@"暂无可补课的课程"];
            return;
        }
        
        BKCourseInfoModel *oldModel = model;
        [BKAdjustClassAlertView showViewFromVc:self model:model complete:^(BKAdjustClassModel * _Nonnull model) {
            BKAdjustClassModel *adjustModel = model;
            
            [BKConfirmAdjustClassAlert showViewFromVc:self oldModel:oldModel newModel:adjustModel complete:^{
                [self submitAdjustClassOldclt:oldModel.ct_id newClt:adjustModel.clt_id];
            }];
        }];
    };
    
    cell.reportHandler = ^(BKCourseInfoModel *model) {
        if (!model.report_url.isEmpty) {
            BKWebViewController *vc = [[BKWebViewController alloc] init];
            vc.url = model.report_url;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [UUProgressHUD showWarnWithStatus:@"报告还在生成中，请耐心等候"];
            return;
        }
        
    };
    
    return cell;
}

- (void)submitAdjustClassOldclt:(NSString *)oldClt newClt:(NSString *)newClt {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"old_clt_id"] = oldClt;
    params[@"new_clt_id"] = newClt;
    [HttpManager postWithUrlString:@"student/student.php?act=postAdjustClassTime" parameters:params success:^(id  _Nullable response) {
        if (response) {
            [BKLeaveSuccessAlert showViewFromVc:self title:@"补课成功" content:@"您已成功补课" confirm:^{
                [self.tableView reloadData];
            }];
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark ----- DZNEmptyDataSet
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"empty_placeholde_image"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"今天暂无课程哦！";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont PingFangSCMedium:35.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:MainSecondColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text =  @"";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0.0;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return !self.haveData;
}


#pragma clang diagnostic pop


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
