//
//  LLKCardsCell.m
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "LLKCardsCell.h"

@interface LLKCardsCell ()

@property(nonatomic,strong) UIImageView *guanka;

@end
@implementation LLKCardsCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4;
        self.layer.borderWidth = 1.0;
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 0;
        self.layer.shadowOffset = CGSizeMake(0, 10);
        
        
        [self.contentView addSubview:self.guankaLabel];
        [self.contentView addSubview:self.guanka];
        
        [self.guankaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        [self.guanka mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.size.mas_equalTo(40);
        }];
        
    }
    return self;
}
- (void)setIsLock:(BOOL)isLock{
    _isLock = isLock;
    self.guanka.hidden = !_isLock;
    self.guankaLabel.hidden = _isLock;
    if (isLock) {
        self.backgroundColor = [[UIColor colorWithHexString:@"cde0ce"] colorWithAlphaComponent:0.75];
        self.layer.borderColor = [UIColor colorWithHexString:@"073774"].CGColor;
        self.layer.shadowColor = [[UIColor colorWithHexString:@"a5a29b"] colorWithAlphaComponent:0.75].CGColor;
    }
    else{
        
        self.backgroundColor = [[UIColor colorWithHexString:@"cdebf3"] colorWithAlphaComponent:0.75];
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.layer.shadowColor = [[UIColor colorWithHexString:@"194d59"] colorWithAlphaComponent:0.75].CGColor;
    }
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
        _guanka.image = [UIImage imageNamed:@"suo"];
    }
    return _guanka;
}
@end
