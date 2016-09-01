//
//  TeamCollectionView.m
//  Schedule
//
//  Created by yuedong_chen on 16/8/31.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "TeamCollectionView.h"
#import "DataManager.h"
#import "TeamCollectionViewCell.h"
#import "TeamHeaderView.h"

NSString *const TeamCollectionViewCellIdentifier = @"TeamCollectionViewCell";
NSString *const TeamHeaderViewIdentifier = @"TeamHeaderView";
NSInteger const teamWidth = 200;

@interface TeamCollectionView ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *teamId;
@property (nonatomic, strong) NSArray *teamList;
@property (nonatomic, strong) TeamHeaderView *headerView;

@end

@implementation TeamCollectionView

- (instancetype)initWithFrame:(CGRect)frame andTeamId:(NSString *)teamId
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionHeadersPinToVisibleBounds = YES;
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.teamId = teamId;
        self.dataSource = self;
        self.delegate = self;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:250.f / 255.f green:250.f / 255.f blue:250.f / 255.f alpha:1];
        self.showsVerticalScrollIndicator = NO;
        [self registerNib:[UINib nibWithNibName:TeamCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:TeamCollectionViewCellIdentifier];
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TeamHeaderViewIdentifier];
    }
    return self;
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
    
    if (kind == UICollectionElementKindSectionHeader) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TeamHeaderViewIdentifier forIndexPath:indexPath];
            
        self.headerView.frame = headerView.bounds;
        [headerView addSubview:self.headerView];
    }
    
    return headerView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.teamList objectAtIndex:indexPath.item];
    self.teamId = key;
    
    if (self.didSelectBlcok) {
        self.didSelectBlcok(key);
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
    return CGSizeMake(teamWidth, 72);
}

#pragma mark - getter

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
    
    self.headerView.image = [UIImage imageNamed:teamId];
    self.headerView.name = [[DataManager teamDic] objectForKey:teamId];
}

@end
