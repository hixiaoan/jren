//
//  BKCommonHomeWorkController.h
//  UUEnglish
//
//  Created by Aibo on 2018/10/29.
//  Copyright © 2018年 uuabc. All rights reserved.
//

#import "BKBaseTableController.h"
#import "BKHomeWorkModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKCommonHomeWorkController : BKBaseTableController

//试卷ID
@property (nonatomic, copy) NSString *test_id;
//课件ID
@property (nonatomic, copy) NSString *courseware_id;
@property (nonatomic, copy) NSString *clt_id;
//请求类型（1-查询学生作业2-查询学生作业完成结果3-查询老师作业批注）
@property (nonatomic, copy) NSString *type;
//作业类型(1:做作业； 2:查看作业)
@property (nonatomic, assign) HomeWorkType workType;
//用于区别水平测试还是做作业
@property (nonatomic, assign) ModuleType moduleType;

@end

NS_ASSUME_NONNULL_END
