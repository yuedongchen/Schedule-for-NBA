//
//  DateController.h
//  Schedule
//
//  Created by yuedong_chen on 16/8/29.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateController : NSObject

+ (NSInteger)firstWeekdayInThisMonth:(NSDate *)date;

+ (NSInteger)totaldaysInMonth:(NSDate *)date;

+ (NSInteger)day:(NSDate *)date;

+ (NSInteger)month:(NSDate *)date;

+ (NSInteger)year:(NSDate *)date;

+ (NSString *)startTime:(NSTimeInterval)time;

+ (NSDate *)previousMonth:(NSDate *)date;

+ (NSDate*)nextMonth:(NSDate *)date;

@end
