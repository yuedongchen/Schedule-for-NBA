//
//  TeamCollectionView.h
//  Schedule
//
//  Created by yuedong_chen on 16/8/31.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const teamWidth;

@interface TeamCollectionView : UICollectionView

- (instancetype)initWithFrame:(CGRect)frame andTeamId:(NSString *)teamId;

@property (nonatomic, strong) void (^didSelectBlcok)(NSString *teamId);

@end
