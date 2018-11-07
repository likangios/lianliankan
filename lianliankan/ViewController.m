//
//  ViewController.m
//  shuzihuarongdao
//
//  Created by perfay on 2018/10/17.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "ViewController.h"
#import "MGPlayerViewController.h"
#import "GuanKaViewController.h"
#import "UserTKViewController.h"
//#import "TestViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property(nonatomic,strong) UIImageView *bgImageView;

@property(nonatomic,strong) UIImageView *topIconImageView;

@property(nonatomic,strong) UIImageView *zimuIconImageView;

@end

@implementation ViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/*
 一阶：20关：4关一组* 5组   
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    [self creatSubViews];
    UIScrollView * scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(self.zimuIconImageView.mas_bottom).offset(20);
        make.bottom.mas_equalTo(-30);
    }];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    NSArray *titles = @[@"一 阶",@"二   阶",@"三 阶",@"四   阶"];
    UIButton *lastBtn;
    for (int i = 0; i< 4 ; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [scrollView addSubview:btn];
        btn.tag = i + 1;
        UIImage *image = [UIImage imageNamed:@"button1"];
        [btn setImage:image forState:UIControlStateNormal];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(300, 75));
            if (lastBtn) {
                make.top.equalTo(lastBtn.mas_bottom).offset(20);
            }
            else{
                make.top.mas_equalTo(0);
            }
        }];
        UILabel *label = [UILabel new];
        label.text = titles[i];
        label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        label.font = [UIFont boldSystemFontOfSize:30];
        label.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(btn);
            make.centerY.equalTo(btn.mas_centerY).offset(-3);
        }];
        lastBtn = btn;
        @weakify(self);
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self pushToGameMainViewControllerWithLevel:x.tag];
        }];
    }
    [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-10);
    }];
}
- (void)creatSubViews {
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.topIconImageView];
    [self.view addSubview:self.zimuIconImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.topIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(0, 0));
        make.centerX.equalTo(self.view);
    }];
    [self.zimuIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topIconImageView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(80);
    }];
}
- (void)pushToGameMainViewControllerWithLevel:(NSInteger)level{
    GuanKaViewController *game =[[GuanKaViewController alloc]init];
    game.gameLevel = level;
    [self.navigationController pushViewController:game animated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *first =  [[NSUserDefaults standardUserDefaults] valueForKey:@"first"];
    if (![first isEqualToString:@"1"]) {
        UserTKViewController *tk = [[UserTKViewController alloc]init];
        [self presentViewController:tk animated:animated completion:NULL];
    }
}
- (UIImageView *)zimuIconImageView{
    if(!_zimuIconImageView) {
        _zimuIconImageView = [UIImageView new];
        _zimuIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _zimuIconImageView.image = [UIImage imageNamed:@"_"];

    }
    return _zimuIconImageView;
}
- (UIImageView *)topIconImageView{
    if(!_topIconImageView) {
        _topIconImageView = [UIImageView new];
        _topIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _topIconImageView.image = [UIImage imageNamed:@""];

    }
    return _topIconImageView;
}
- (UIImageView *)bgImageView{
    if(!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
        _bgImageView.image = [UIImage imageNamed:@"home_bg"];

    }
    return _bgImageView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
