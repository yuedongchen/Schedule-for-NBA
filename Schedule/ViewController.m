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
#import "ChangeHomeTeamViewController.h"
#import "TeamHeaderView.h"
#import "Masonry.h"
#import "CalendarView.h"

NSString *const HOME_TEAM = @"HOME_TEAM";
NSString *const TeamCollectionViewCellIdentifier = @"TeamCollectionViewCell";
NSString *const TeamHeaderViewIdentifier = @"TeamHeaderView";
NSInteger const teamWidth = 200;

@interface ViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSString *teamId;
@property (nonatomic, strong) NSMutableArray *gameInfoList;
@property (nonatomic, strong) NSArray *teamList;
@property (nonatomic, strong) FXBlurView *maskView;
@property (nonatomic, strong) UIButton *maskButton;
@property (nonatomic, strong) UICollectionView *teamCollectionView;
@property (nonatomic, strong) TeamHeaderView *headerView;
@property (nonatomic, strong) CalendarView *calendarView;

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
    
    [self addSwipe];
    
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
    
    [self.view addSubview:self.calendarView];
    
    NSInteger itemWidth = (NSInteger)([UIScreen mainScreen].bounds.size.width / 7 + 1);
    [self.calendarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(72);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(itemWidth * 7);
        make.height.mas_equalTo((itemWidth - 10) * 7 + 51.5f);
    }];
}

#pragma mark - private method (UI)

- (void)addSwipe
{
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self.calendarView action:@selector(gotoNextMonth:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self.calendarView action:@selector(gotoNextMonth:)];
    swipUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipUp];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self.calendarView action:@selector(gotoPreviousMonth:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipRight];
    
    UISwipeGestureRecognizer *swipDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self.calendarView action:@selector(gotoPreviousMonth:)];
    swipDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipDown];
}


#pragma mark - IBAction

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
    ChangeHomeTeamViewController *vc = [[ChangeHomeTeamViewController alloc] initWithDataDissmissBlock:^(NSString *teamId) {
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    TeamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TeamCollectionViewCellIdentifier forIndexPath:indexPath];
        
    NSString *key = [self.teamList objectAtIndex:indexPath.item];
    cell.image = [UIImage imageNamed:key];
    cell.name = [[DataManager teamDic] objectForKey:key];
        
    return cell;
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
    return CGSizeMake(teamWidth, 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(teamWidth, 64);
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


#pragma mark - getter

- (CalendarView *)calendarView
{
    if (!_calendarView) {
        _calendarView = [[CalendarView alloc] initWithTeamId:self.teamId];
    }
    return _calendarView;
}

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

- (NSArray *)teamList
{
    if (!_teamList) {
        _teamList = [[DataManager teamDic] allKeys];
    }
    return _teamList;
}


#pragma mark - setter

- (void)setTeamId:(NSString *)teamId
{
    _teamId = teamId;
    
    self.titleLabel.text = [[DataManager teamDic] objectForKey:teamId];
    
    self.headerView.image = [UIImage imageNamed:teamId];
    self.headerView.name = [[DataManager teamDic] objectForKey:teamId];
    self.calendarView.teamId = teamId;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

