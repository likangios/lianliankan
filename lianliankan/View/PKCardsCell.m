//
//  PKCardsCell.m
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "PKCardsCell.h"

@interface PKCardsCell ()

@property(nonatomic,strong) UIImageView *lockImageView;

@end
@implementation PKCardsCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0;
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 0;
        self.layer.shadowOffset = CGSizeMake(-5, 5);
        self.backgroundColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.75];
        
        [self.contentView addSubview:self.guankaLabel];
        [self.contentView addSubview:self.guanka];
        [self.contentView addSubview:self.lockImageView];

        [self.guankaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        [self.guanka mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(110 * 0.5, 153 * 0.5));
        }];
        [self.lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.size.mas_equalTo(40);
        }];
        
    }
    return self;
}
- (UIImageView *)lockImageView{
    if(!_lockImageView) {
        _lockImageView = [UIImageView new];
        _lockImageView.contentMode = UIViewContentModeScaleAspectFill;
        _lockImageView.image = [UIImage imageNamed:@"suo"];
    }
    return _lockImageView;
}
- (void)setIsLock:(BOOL)isLock{
    _isLock = isLock;
    self.lockImageView.hidden = !_isLock;
    self.guankaLabel.hidden = _isLock;
}
- (UILabel *)guankaLabel{
    if (!_guankaLabel) {
        _guankaLabel = [UILabel new];
        _guankaLabel.font = [UIFont boldSystemFontOfSize:15];
        _guankaLabel.textColor = [UIColor whiteColor];
        _guankaLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _guankaLabel;
}
- (UIImageView *)guanka{
    if(!_guanka) {
        _guanka = [UIImageView new];
        _guanka.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _guanka;
}
@end
