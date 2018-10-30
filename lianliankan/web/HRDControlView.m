//
//  HRDControlView.m
//  yezjk
//
//  Created by perfay on 2018/10/11.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "HRDControlView.h"

@interface HRDControlView ()



@end
@implementation HRDControlView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self creatSubView];
        [self shuzihuarongdaomethod];
    }
    return self;
}
-(void)shuzihuarongdaomethod{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"helloworld"];
    if ([number.stringValue isEqualToString:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@2 forKey:@"helloworld"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"helloworld"];
    }
}
- (void)creatSubView{
    NSArray *imgs = @[@"szhrdbv1",@"szhrdbv2",@"szhrdbv3",@"szhrdbv4",@"szhrdbv5"];
    UIButton *lastBtn;
    for (int i = 0; i<imgs.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imgs[i]] forState:UIControlStateNormal];
        btn.tag = i+1;
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * button) {
            if (self.buttonClick) {
                self.buttonClick(button.tag);
            }
        }];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            if (lastBtn) {
                make.width.mas_equalTo(lastBtn.mas_width);
                make.left.equalTo(lastBtn.mas_right);
            }
            else{
                make.left.mas_equalTo(0);
            }
        }];
        lastBtn = btn;
    }
    [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
    }];

}
@end
