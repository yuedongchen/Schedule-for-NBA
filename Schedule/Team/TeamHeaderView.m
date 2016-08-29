//
//  TeamHeaderView.m
//  Schedule
//
//  Created by yuedong_chen on 16/8/22.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "TeamHeaderView.h"
#import "FXBlurView.h"

@interface TeamHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) FXBlurView *maskView;

@end

@implementation TeamHeaderView

- (void)awakeFromNib
{
    [self insertSubview:self.maskView belowSubview:self.nameLabel];
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameLabel.text = name;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.backImageView.image = image;
    self.imageView.image = image;
    
    [self.maskView removeFromSuperview];
    self.maskView = nil;
    [self insertSubview:self.maskView belowSubview:self.nameLabel];
}

- (FXBlurView *)maskView
{
    if (!_maskView) {
        _maskView = [[FXBlurView alloc] initWithFrame:self.bounds];
        _maskView.dynamic = NO;
        _maskView.tintColor = [UIColor blackColor];
        _maskView.blurRadius = 40;
    }
    return _maskView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
