//
//  GameInfo.m
//  NBASchedule2016~2017
//
//  Created by yuedong_chen on 16/8/19.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "GameInfo.h"

@implementation GameInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.vsTeamId = @"";
        self.vsTeamName = @"";
    }
    return self;
}

@end
