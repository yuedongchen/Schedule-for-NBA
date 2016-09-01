//
//  ViewController.m
//  Schedule
//
//  Created by yuedong_chen on 16/8/19.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "ViewController.h"
#import "FXBlurView.h"
#import "ChangeHomeTeamViewController.h"
#import "Masonry.h"
#import "CalendarView.h"
#import "TeamCollectionView.h"

NSString *const HOME_TEAM = @"HOME_TEAM";

@interface ViewController () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSString *teamId;

@property (nonatomic, strong) FXBlurView *maskView;
@property (nonatomic, strong) UIButton *maskButton;
@property (nonatomic, strong) TeamCollectionView *teamCollectionView;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view addSubview:self.calendarView];
    
    NSInteger itemWidth = (NSInteger)(SCREENWIDTH / 7 + 1);
    [self.calendarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(72);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(itemWidth * 7);
        make.height.mas_equalTo((itemWidth - 10) * 7 + 51.5f);
    }];
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
        self.view.frame = CGRectMake(teamWidth, self.view.frame.origin.y, SCREENWIDTH, SCREENHEIGHT);
        self.teamCollectionView.frame = CGRectMake(0, 0, teamWidth, SCREENHEIGHT);
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
        self.view.frame = CGRectMake(0, self.view.frame.origin.y, SCREENWIDTH, SCREENHEIGHT);
        self.teamCollectionView.frame = CGRectMake(-teamWidth, 0, teamWidth, SCREENHEIGHT);
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
        [self.maskButton setTitleEdgeInsets:UIEdgeInsetsMake(20, 10, SCREENHEIGHT - 70, 10)];
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

- (TeamCollectionView *)teamCollectionView
{
    if (!_teamCollectionView) {
        _teamCollectionView = [[TeamCollectionView alloc] initWithFrame:CGRectMake(-teamWidth, 0, teamWidth, self.view.bounds.size.height) andTeamId:self.teamId];
        
        __block typeof(self) weakSelf = self;
        _teamCollectionView.didSelectBlcok = ^(NSString *teamId) {
            weakSelf.teamId = teamId;
            [weakSelf hideTeamListAction:weakSelf.maskButton];
        };
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


#pragma mark - setter

- (void)setTeamId:(NSString *)teamId
{
    _teamId = teamId;
    
    self.titleLabel.text = [[DataManager teamDic] objectForKey:teamId];

    self.calendarView.teamId = teamId;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

