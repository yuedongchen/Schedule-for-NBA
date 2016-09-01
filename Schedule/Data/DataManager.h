//
//  DataManager.h
//  NBASchedule2016~2017
//
//  Created by yuedong_chen on 16/8/17.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;

@protocol DataMangerDelegate <NSObject>

@optional
- (void)loadingDataFinished:(NSArray *)gameInfoList;
- (void)loadingDatafailured:(DataManager *)dataManager error:(NSError *)error;

@end

@interface DataManager : NSObject

@property (nonatomic, weak) id<DataMangerDelegate> delegate;

- (id)initWithDelegate:(id<DataMangerDelegate>)delegate;
- (void)requestWithMonth:(NSInteger)month year:(NSInteger)year andTeamId:(NSString *)tid;
+ (NSDictionary *)teamDic;

@end
