//
//  CalendarView.m
//  Schedule
//
//  Created by yuedong_chen on 16/8/29.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "CalendarView.h"
#import "DateCell.h"
#import "GameInfo.h"
#import "DateController.h"
#import "DataManager.h"
#import "Masonry.h"

#define SELFWIDTH self.frame.size.width
#define SELFHEIGHT self.frame.size.height

NSString *const CalendarCellIdentifier = @"DateCell";
NSString *const CalendarHeaderIdentifier = @"header";

@interface CalendarView ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
DataMangerDelegate
>

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSMutableArray *gameInfoList;
@property (nonatomic, strong) NSArray *weekDayArray;
@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UILabel *yearLabel;

@end

@implementation CalendarView

- (instancetype)initWithTeamId:(NSString *)teamId
{
    self = [super initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = RGBA(240, 240, 240, 1);
        self.teamId = teamId;
        self.selectedDate = [NSDate date];
        [self registerNib:[UINib nibWithNibName:CalendarCellIdentifier bundle:nil] forCellWithReuseIdentifier:CalendarCellIdentifier];
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CalendarHeaderIdentifier];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 7;
    } else {
        return 42;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CalendarCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        NSString *weekDay = [self.weekDayArray objectAtIndex:indexPath.item];
        cell.vsTeamName = weekDay;
        cell.dayColor = [UIColor whiteColor];
        cell.cornerRadius = 0.f;
        cell.nameColor = RGBA(22, 206, 255, 1);
        
    } else {
        
        NSInteger firstWeekDay = [DateController firstWeekdayInThisMonth:self.selectedDate];
        NSInteger totalDays = [DateController totaldaysInMonth:self.selectedDate];
        NSInteger dayForDate = indexPath.item - firstWeekDay + 1;
        
        cell.day =  (0 < dayForDate && dayForDate <= totalDays) ? [NSString stringWithFormat:@"%ld", (long)dayForDate] : @"";
        
        if ([cell.day integerValue] == [DateController day:[NSDate date]] && [DateController month:self.selectedDate] == [DateController month:[NSDate date]] && [DateController year:self.selectedDate] == [DateController year:[NSDate date]]) {
            cell.dayColor = [UIColor greenColor];
            cell.cornerRadius = 8.f;
        } else {
            cell.dayColor = [UIColor whiteColor];
            cell.cornerRadius = 0.f;
        }
        
        for (GameInfo *info in self.gameInfoList) {
            if (info.gameDay == dayForDate) {
                
                cell.nameColor = [UIColor colorWithRed:22.f / 255.f green:206.f / 255.f blue:255.f / 255.f alpha:1];
                if (info.isMaster) {
                    cell.vsTeamName = [NSString stringWithFormat:@"%@", info.vsTeamName];
                } else {
                    cell.vsTeamName = [NSString stringWithFormat:@"@%@", info.vsTeamName];
                }
                
                if (info.selfGoal) {
                    cell.time = [NSString stringWithFormat:@"%ld-%ld", (long)info.selfGoal, (long)info.rivalGoal];
                    if (!info.isWin) {
                        cell.timeColor = [UIColor darkGrayColor];
                    } else {
                        cell.timeColor = [UIColor redColor];
                    }
                } else {
                    cell.time = [DateController startTime:info.startTime];
                    cell.timeColor = [UIColor greenColor];
                }
                break;
            }
        }
        
        
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = nil;
    
    if (kind == UICollectionElementKindSectionHeader && indexPath.section == 0) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CalendarHeaderIdentifier forIndexPath:indexPath];
            
        headerView.backgroundColor = [UIColor colorWithRed:255.f / 255.f green:198.f / 255.f blue:81.f / 255.f alpha:1];
        
        [headerView addSubview:self.leftButton];
        [headerView addSubview:self.rightButton];
        [headerView addSubview:self.yearLabel];
        
        [self.leftButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headerView);
            make.top.mas_equalTo(headerView);
            make.bottom.mas_equalTo(headerView);
            make.width.mas_equalTo(self.leftButton.frame.size.height);
        }];
        [self.rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(headerView);
            make.top.mas_equalTo(headerView);
            make.bottom.mas_equalTo(headerView);
            make.width.mas_equalTo(self.leftButton.frame.size.height);
        }];
        [self.yearLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(headerView).offset(16);
            make.centerX.mas_equalTo(headerView);
            make.height.mas_equalTo(21);
        }];
    }
    
    return headerView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger itemWidth = (NSInteger)([UIScreen mainScreen].bounds.size.width / 7 + 1);
    if (indexPath.section == 0) {
        return CGSizeMake(itemWidth, itemWidth - 15);
    } else {
        return CGSizeMake(itemWidth, itemWidth - 10);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section) {
        return CGSizeZero;
    }
    return CGSizeMake(SELFWIDTH, 54);
}

#pragma mark - DataManagerDelegate

- (void)loadingDataFinished:(DataManager *)dataManager
{
    self.gameInfoList = dataManager.gameInfoList;
    [self reloadData];
}

- (void)loadingDatafailured:(DataManager *)dataManager error:(NSError *)error
{
    
}

#pragma mark - Action

- (IBAction)gotoPreviousMonth:(UIButton *)sender
{
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        self.selectedDate = [DateController previousMonth:self.selectedDate];
        
    } completion:nil];
}

- (IBAction)gotoNextMonth:(UIButton *)sender
{
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
        self.selectedDate = [DateController nextMonth:self.selectedDate];
    } completion:nil];
}

#pragma mark - getter

- (NSArray *)weekDayArray
{
    if (!_weekDayArray) {
        _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    }
    return _weekDayArray;
}

- (DataManager *)dataManager
{
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] initWithDelegate:self];
    }
    return _dataManager;
}

#pragma mark - getter(UI)

- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [[UIButton alloc] init];
        [_leftButton setImage:[UIImage imageNamed:@"bt_previous"] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(gotoPreviousMonth:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] init];
        [_rightButton setImage:[UIImage imageNamed:@"bt_next"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(gotoNextMonth:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UILabel *)yearLabel
{
    if (!_yearLabel) {
        _yearLabel = [[UILabel alloc] init];
        _yearLabel.font = [UIFont systemFontOfSize:17];
        _yearLabel.textColor = [UIColor darkGrayColor];
        _yearLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _yearLabel;
}

#pragma mark - setter

- (void)setTeamId:(NSString *)teamId
{
    _teamId = teamId;
    
    if (_selectedDate) {
        [self.dataManager requestWithMonth:[DateController month:self.selectedDate] year:[DateController year:self.selectedDate] andTeamId:self.teamId];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    self.yearLabel.text = [NSString stringWithFormat:@"%li－%.2ld",(long)[DateController year:selectedDate], (long)[DateController month:selectedDate]];

    if (_teamId) {
        [self.dataManager requestWithMonth:[DateController month:self.selectedDate] year:[DateController year:self.selectedDate] andTeamId:self.teamId];
    }
}

@end
