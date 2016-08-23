//
//  CollectionViewController.h
//  Schedule
//
//  Created by yuedong_chen on 16/8/22.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface CollectionViewController : UICollectionViewController

- (id)initWithDataManager:(DataManager *)dataManager andDissmissBlock:(void (^)(NSString *teamId))blcok;

@end
