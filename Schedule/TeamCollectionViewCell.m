//
//  TeamCollectionViewCell.m
//  Schedule
//
//  Created by yuedong_chen on 16/8/22.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "TeamCollectionViewCell.h"

@interface TeamCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightCons;

@end

@implementation TeamCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.heightCons.constant = 0.5f;
    // Initialization code
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameLabel.text = name;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

@end
