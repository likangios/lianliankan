
//
//  GuanKaViewController.m
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "GuanKaViewController.h"
#import "PKCardsView.h"
#import "MGPlayerViewController.h"

@interface GuanKaViewController ()

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIImageView *bgImageView;

@property(nonatomic,strong) UIButton *fanhuiButton;

@property(nonatomic,strong) PKCardsView *cardView;


@end

@implementation GuanKaViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc]init];
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.bounces = NO;
        _mainScrollView.alwaysBounceHorizontal = YES;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _mainScrollView;
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

- (UIButton *)fanhuiButton{
    if (!_fanhuiButton) {
        _fanhuiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fanhuiButton setImage:[UIImage imageNamed:@"arrow_left"] forState:UIControlStateNormal];
        @weakify(self);
        [[_fanhuiButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self backAction];
        }];
    }
    return _fanhuiButton;
}
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cardView.currentIndex = [self getLevelIndex];
}
- (NSInteger)getLevelIndex{
    NSUserDefaults *defau = [NSUserDefaults standardUserDefaults];
    NSString *level = [NSString stringWithFormat:@"%d",self.gameLevel];
    NSNumber *index = [defau objectForKey:level];
    if (index == nil) {
        [defau setObject:@(1) forKey:level];
        return 1;
    }
    return index.integerValue;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self creatSubViews];

    for (int i = 0; i< 1; i++) {
        PKCardsView *view = [[PKCardsView alloc]init];
        view.currentIndex = 1;
        [self.mainScrollView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kSCREEN_WIDTH * i);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(kSCREEN_WIDTH);
            make.centerY.equalTo(self.mainScrollView.mas_centerY);
            if (i == 2) {
                make.right.mas_equalTo(0);
            }
        }];
        @weakify(self);
        [view.cellSelected  subscribeNext:^(NSNumber  *index) {
            @strongify(self);
            [self tiaozhuandaoGameVc:index];
        }];
        self.cardView = view;
    }
    self.cardView.currentIndex = [self getLevelIndex];
}

- (void)creatSubViews {
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.view addSubview:self.fanhuiButton];
    [self.fanhuiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25);
        make.top.mas_equalTo(25);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(80);
        make.bottom.mas_equalTo(-60);
    }];
}

- (void)tiaozhuandaoGameVc:(NSNumber *)index{
    MGPlayerViewController *main = [[MGPlayerViewController alloc]init];
    main.gameLevel = self.gameLevel;
    main.index = index.integerValue;
    [self.navigationController pushViewController:main animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
