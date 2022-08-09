//
//  BKHomeWorkController.h
//  msyork
//
//  Created by Derrick on 2018/10/8.
//  Copyright © 2018年 bike. All rights reserved.
//

#import "BKBaseTableController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKHomeWorkController : BKBaseTableController

@property (nonatomic, copy) NSString *test_id; //试卷
@property (nonatomic, copy) NSString *clt_id;  //课时
@property (nonatomic, copy) NSString *courseware_id; //课件


@end

NS_ASSUME_NONNULL_END
