//
//  ViewController.m
//  Schedule
//
//  Created by yuedong_chen on 16/8/19.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "ViewController.h"
#import "DateCell.h"
#import "FXBlurView.h"
#import "DataManager.h"
#import "GameInfo.h"
#import "TeamCollectionViewCell.h"
#import "CollectionViewController.h"
#import "TeamHeaderView.h"

NSString *const HOME_TEAM = @"HOME_TEAM";
NSString *const SZCalendarCellIdentifier = @"DateCell";
NSString *const TeamCollectionViewCellIdentifier = @"TeamCollectionViewCell";
NSString *const TeamHeaderViewIdentifier = @"TeamHeaderView";
NSInteger const teamWidth = 200;

@interface ViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
DataMangerDelegate,
UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSString *teamId;

@property (nonatomic, strong) NSDate *today;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSArray *weekDayArray;
@property (nonatomic, strong) NSMutableArray *gameInfoList;
@property (nonatomic, strong) NSArray *teamList;
@property (nonatomic, strong) FXBlurView *maskView;
@property (nonatomic, strong) UIButton *maskButton;
@property (nonatomic, strong) UICollectionView *teamCollectionView;
@property (nonatomic, strong) TeamHeaderView *headerView;

@property (weak, nonatomic) IBOutlet UIView *calendarView;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *chageButton;
@property (weak, nonatomic) IBOutlet UIButton *gestureButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self.view insertSubview:self.maskView belowSubview:self.gestureButton];
    [self setupCollectionView];
    [self addSwipe];
    
    self.selectedDate = self.today;
    self.view.layer.contents = (id)[UIImage imageNamed:@"勇士.png"].CGImage;

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:HOME_TEAM]) {
        [self changeHomeTeamAction:self.chageButton];
        self.titleLabel.text = @"";
    } else {
        self.teamId = [[NSUserDefaults standardUserDefaults] objectForKey:HOME_TEAM];
    }
}

#pragma mark - private method (UI)

- (void)setupCollectionView
{
    NSInteger itemWidth = (NSInteger)([UIScreen mainScreen].bounds.size.width / 7 + 1);
    self.width.constant = itemWidth * 7;
    self.height.constant = (itemWidth - 10) * 7 + 51.5f;
    
    [self.collectionView registerNib:[UINib nibWithNibName:SZCalendarCellIdentifier bundle:nil] forCellWithReuseIdentifier:SZCalendarCellIdentifier];
}

- (void)addSwipe
{
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextMonth:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextMonth:)];
    swipUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipUp];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviousMonth:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipRight];
    
    UISwipeGestureRecognizer *swipDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviousMonth:)];
    swipDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipDown];
}

#pragma mark - private method

- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    
    return firstWeekday - 1;
}

- (NSInteger)totaldaysInMonth:(NSDate *)date
{
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

- (NSInteger)day:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}

- (NSInteger)month:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}

- (NSString *)startTime:(NSTimeInterval)time
{
    NSTimeInterval BeiJingTime = time;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:BeiJingTime];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:date];
    NSString *hour = [components hour] ? [NSString stringWithFormat:@"%ld", (long)[components hour]] : @"00";
    NSString *minute = [components minute] ? [NSString stringWithFormat:@"%ld", (long)[components minute]] : @"00";
    
    return [NSString stringWithFormat:@"%@:%@", hour, minute];
}

- (NSDate *)previousMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSDate*)nextMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

#pragma mark - IBAction

- (IBAction)gotoPreviousMonth:(UIButton *)sender
{
    [UIView transitionWithView:self.calendarView duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        self.selectedDate = [self previousMonth:self.selectedDate];
        
    } completion:nil];
}

- (IBAction)gotoNextMonth:(UIButton *)sender
{
    [UIView transitionWithView:self.calendarView duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
        self.selectedDate = [self nextMonth:self.selectedDate];
    } completion:nil];
}

- (IBAction)changeTeamAction:(UIButton *)sender
{
    [[UIApplication sharedApplication].keyWindow insertSubview:self.teamCollectionView aboveSubview:self.view];
    self.teamCollectionView.frame = CGRectMake(-teamWidth, 0, teamWidth, self.view.bounds.size.height);
    self.teamCollectionView.layer.cornerRadius = 0.f;
    
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:15 options:0 animations:^{
        self.view.frame = CGRectMake(teamWidth, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        self.teamCollectionView.frame = CGRectMake(0, 0, teamWidth, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        self.maskButton = [[UIButton alloc] initWithFrame:self.view.bounds];
        self.maskButton.backgroundColor = [UIColor clearColor];
        [self.maskButton addTarget:self action:@selector(hideTeamListAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.maskButton];
    }];
}

- (void)hideTeamListAction:(UIButton *)button
{
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:15 options:0 animations:^{
        self.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        self.teamCollectionView.frame = CGRectMake(-teamWidth, 0, teamWidth, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.maskButton removeFromSuperview];
    }];
}

- (IBAction)changeHomeTeamAction:(UIButton *)sender
{
    CollectionViewController *vc = [[CollectionViewController alloc] initWithDataManager:self.dataManager andDissmissBlock:^(NSString *teamId) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:HOME_TEAM]) {
            self.teamId = teamId;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.maskButton.alpha = 0;
        } completion:^(BOOL finished) {
            [self.maskButton removeFromSuperview];
        }];
        
        [[NSUserDefaults standardUserDefaults] setObject:teamId forKey:HOME_TEAM];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    vc.preferredContentSize = CGSizeMake(100, 400);
    
    vc.modalPresentationStyle = UIModalPresentationPopover;
    
    vc.popoverPresentationController.delegate = self;
    
    vc.popoverPresentationController.sourceView = sender;
    
    vc.popoverPresentationController.sourceRect = sender.bounds;
    
    [self presentViewController:vc animated:YES completion:nil];
    
    self.maskButton = [[UIButton alloc] initWithFrame:self.view.bounds];
    self.maskButton.backgroundColor = [UIColor blackColor];
    self.maskButton.alpha = 0;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:HOME_TEAM]) {
        [self.maskButton setTitle:@"请选择主队" forState:UIControlStateNormal];
        [self.maskButton setTitleEdgeInsets:UIEdgeInsetsMake(20, 10, self.view.frame.size.height - 70, 10)];
        [self.maskButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.maskButton.titleLabel setFont:[UIFont systemFontOfSize:50]];
    } else {
        [self.maskButton setTitle:@"" forState:UIControlStateNormal];
    }
    [self.view addSubview:self.maskButton];
    [UIView animateWithDuration:0.3 animations:^{
        self.maskButton.alpha = 0.4;
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.collectionView) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        if (section == 0) {
            return 7;
        } else {
            return 42;
        }
    } else {
        return 30;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        DateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SZCalendarCellIdentifier forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            
            NSString *weekDay = [self.weekDayArray objectAtIndex:indexPath.item];
            cell.vsTeamName = weekDay;
            cell.dayColor = [UIColor whiteColor];
            cell.cornerRadius = 0.f;
            cell.nameColor = [UIColor colorWithRed:22.f / 255.f green:206.f / 255.f blue:255.f / 255.f alpha:1];
            
        } else {
            
            NSInteger firstWeekDay = [self firstWeekdayInThisMonth:self.selectedDate];
            NSInteger totalDays = [self totaldaysInMonth:self.selectedDate];
            NSInteger dayForDate = indexPath.item - firstWeekDay + 1;
            
            cell.day =  (0 < dayForDate && dayForDate <= totalDays) ? [NSString stringWithFormat:@"%ld", (long)dayForDate] : @"";
            
            if ([cell.day integerValue] == [self day:self.today] && [self month:self.selectedDate] == [self month:self.today] && [self year:self.selectedDate] == [self year:self.today]) {
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
                        cell.time = [self startTime:info.startTime];
                        cell.timeColor = [UIColor greenColor];
                    }
                    break;
                }
            }
            
            
        }
        return cell;
    } else {
        TeamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TeamCollectionViewCellIdentifier forIndexPath:indexPath];
        
        NSString *key = [self.teamList objectAtIndex:indexPath.item];
        cell.image = [UIImage imageNamed:key];
        cell.name = [[self.dataManager teamDic] objectForKey:key];
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = nil;
    
    if (collectionView == self.teamCollectionView) {
        if (kind == UICollectionElementKindSectionHeader) {
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TeamHeaderViewIdentifier forIndexPath:indexPath];
            
            self.headerView.frame = headerView.bounds;
            [headerView addSubview:self.headerView];
        }
    }
    
    return headerView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.teamCollectionView) {
        NSString *key = [self.teamList objectAtIndex:indexPath.item];
        self.teamId = key;
        [self hideTeamListAction:self.maskButton];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        NSInteger itemWidth = (NSInteger)([UIScreen mainScreen].bounds.size.width / 7 + 1);
        if (indexPath.section == 0) {
            return CGSizeMake(itemWidth, itemWidth - 15);
        } else {
            return CGSizeMake(itemWidth, itemWidth - 10);
        }
    } else {
        return CGSizeMake(teamWidth, 50);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return 0.5;
    } else {
        return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        if (section == 0) {
            return UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            return UIEdgeInsetsMake(0, 0, 0, 0);
        }
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (collectionView == self.teamCollectionView) {
        return CGSizeMake(self.teamCollectionView.bounds.size.width, 72);
    } else {
        return CGSizeZero;
    }
}

#pragma mark - UIAdaptivePresentationControllerDelegate

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:HOME_TEAM]) {
        return NO;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.maskButton removeFromSuperview];
    }];
    
    return YES;
}

#pragma mark - DataManagerDelegate

- (void)loadingDataFinished:(DataManager *)dataManager
{
    self.gameInfoList = dataManager.gameInfoList;
    [self.collectionView reloadData];
}

- (void)loadingDatafailured:(DataManager *)dataManager error:(NSError *)error
{
    
}

#pragma mark - getter

- (UICollectionView *)teamCollectionView
{
    if (!_teamCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionHeadersPinToVisibleBounds = YES;
        
        _teamCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-teamWidth, 0, teamWidth, self.view.bounds.size.height) collectionViewLayout:layout];
        _teamCollectionView.dataSource = self;
        _teamCollectionView.delegate = self;
        self.teamCollectionView.clipsToBounds = YES;
        _teamCollectionView.backgroundColor = [UIColor colorWithRed:250.f / 255.f green:250.f / 255.f blue:250.f / 255.f alpha:1];
        _teamCollectionView.showsVerticalScrollIndicator = NO;
        [_teamCollectionView registerNib:[UINib nibWithNibName:TeamCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:TeamCollectionViewCellIdentifier];
        [_teamCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TeamHeaderViewIdentifier];
    }
    return _teamCollectionView;
}

- (FXBlurView *)maskView
{
    if (!_maskView) {
        _maskView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
        _maskView.dynamic = NO;
        _maskView.tintColor = [UIColor blackColor];
        _maskView.blurRadius = 40;
    }
    return _maskView;
}

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[[NSBundle mainBundle]loadNibNamed:@"TeamHeaderView" owner:self options:nil] lastObject];
    }
    return _headerView;
}

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

- (NSDate *)today
{
    if (!_today) {
        _today = [NSDate date];
    }
    return _today;
}

- (NSArray *)teamList
{
    if (!_teamList) {
        _teamList = [[self.dataManager teamDic] allKeys];
    }
    return _teamList;
}

#pragma mark - setter

- (void)setTeamId:(NSString *)teamId
{
    _teamId = teamId;
    
    self.titleLabel.text = [[self.dataManager teamDic] objectForKey:teamId];
    
    self.headerView.image = [UIImage imageNamed:teamId];
    self.headerView.name = [[self.dataManager teamDic] objectForKey:teamId];
    
    [self.dataManager requestWithMonth:[self month:self.selectedDate] year:[self year:self.selectedDate] andTeamId:self.teamId];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    self.yearLabel.text = [NSString stringWithFormat:@"%li－%.2ld",(long)[self year:selectedDate], (long)[self month:selectedDate]];
    [self.dataManager requestWithMonth:[self month:self.selectedDate] year:[self year:self.selectedDate] andTeamId:self.teamId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

