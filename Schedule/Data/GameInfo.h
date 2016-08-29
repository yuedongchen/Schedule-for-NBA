//
//  GameInfo.h
//  NBASchedule2016~2017
//
//  Created by yuedong_chen on 16/8/19.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameInfo : NSObject

@property (nonatomic, assign) NSInteger gameDay;

@property (nonatomic, assign) NSInteger isWin;
@property (nonatomic, assign) NSInteger isMaster;
@property (nonatomic, assign) NSInteger rivalGoal;
@property (nonatomic, assign) NSInteger selfGoal;
@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, strong) NSString *vsTeamId;
@property (nonatomic, strong) NSString *vsTeamName;

@end
