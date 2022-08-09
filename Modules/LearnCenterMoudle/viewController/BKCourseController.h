//
//  BKCourseController.h
//  usasishu
//
//  Created by Derrick on 2018/7/2.
//  Copyright © 2018年 bike. All rights reserved.
//

#import "BKBaseViewController.h"
#import "BKTodayCourseCell.h"
#import "BKTodayCourseModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <FSCalendar/FSCalendar.h>
@interface BKCourseController : BKBaseViewController<FSCalendarDataSource,FSCalendarDelegate,UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (strong, nonatomic) UIButton *previousButton;
@property (strong, nonatomic) UIButton *nextButton;
///
@property (nonatomic, strong) UIView *dateTitleView;
///
@property (nonatomic, strong) UILabel *dateTitelLabel;
///
@property (nonatomic, strong) UITableView *tableView;
///
@property (nonatomic, strong) UIView *contenView;
/// 最后选中的日期
@property (nonatomic, strong) NSDate *lastSelectDate;
/// 当天日期
@property (nonatomic, copy) NSString *date;
///
@property (nonatomic, strong) BKTodayCourseModel *model;
///
@property (nonatomic, strong) NSMutableArray *eventArray;
///
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) FSCalendar *calendar;
///
@property (nonatomic, assign) BOOL haveData;
// 文本替换动画
- (void)animateTextChange:(CFTimeInterval)duration animationSubType:(NSString *)subtype;
// 获取本周第一天和最后一天的日期
- (NSString *)getDateFromThisWeek:(NSDate *)now ;
// 获取数据
- (void)refreshData;
@end
