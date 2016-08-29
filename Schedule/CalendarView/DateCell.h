//
//  DateCell.h
//  NBASchedule2016~2017
//
//  Created by yuedong_chen on 16/8/17.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateCell : UICollectionViewCell

@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *vsTeamName;
@property (nonatomic, strong) UIColor *dayColor;
@property (nonatomic, strong) UIColor *nameColor;
@property (nonatomic, strong) UIColor *timeColor;
@property (nonatomic, assign) CGFloat cornerRadius;

@end
