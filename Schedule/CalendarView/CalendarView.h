//
//  CalendarView.h
//  Schedule
//
//  Created by yuedong_chen on 16/8/29.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarView : UICollectionView

@property (nonatomic, strong) NSString *teamId;

- (instancetype)initWithTeamId:(NSString *)teamId;

- (IBAction)gotoPreviousMonth:(UIButton *)sender;
- (IBAction)gotoNextMonth:(UIButton *)sender;

@end
