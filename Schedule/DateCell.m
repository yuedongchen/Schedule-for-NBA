//
//  DateCell.m
//  NBASchedule2016~2017
//
//  Created by yuedong_chen on 16/8/17.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "DateCell.h"

@interface DateCell ()

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *vsTeamLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation DateCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.dayLabel.clipsToBounds = YES;
    // Initialization code
}

- (void)prepareForReuse
{
    self.dayLabel.text = @"";
    self.vsTeamLabel.text = @"";
    self.timeLabel.text = @"";
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius =cornerRadius;
    self.dayLabel.layer.cornerRadius = cornerRadius;
}

- (void)setDay:(NSString *)day
{
    _day = day;
    self.dayLabel.text = day;
}

- (void)setTime:(NSString *)time
{
    _time = time;
    self.timeLabel.text = time;
}

- (void)setVsTeamName:(NSString *)vsTeamName
{
    _vsTeamName = vsTeamName;
    self.vsTeamLabel.text = vsTeamName;
}

- (void)setDayColor:(UIColor *)dayColor
{
    _dayColor = dayColor;
    self.dayLabel.backgroundColor = dayColor;
}

- (void)setNameColor:(UIColor *)nameColor
{
    _nameColor = nameColor;
    self.vsTeamLabel.textColor = nameColor;
}

- (void)setTimeColor:(UIColor *)timeColor
{
    _timeColor = timeColor;
    self.timeLabel.textColor = timeColor;
}

@end
