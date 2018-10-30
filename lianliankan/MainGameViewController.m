//
//  MainGameViewController.m
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "MainGameViewController.h"
#import "PKModel.h"
#import "ItemButton.h"

@interface MainGameViewController ()

@property(nonatomic,strong) NSMutableArray *gameData;
@property(nonatomic,strong) UIButton *backButton;

@property(nonatomic,strong) UIView *containView;

@end

@implementation MainGameViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(UIView *)containView{
    if (!_containView) {
        _containView = [UIView new];
        _containView.backgroundColor = [UIColor randomColor];
    }
    return _containView;
}
- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"arrow_left"] forState:UIControlStateNormal];
        @weakify(self);
        [[_backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self backAction];
        }];
    }
    return _backButton;
}
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25);
        make.top.mas_equalTo(25);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.view addSubview:self.containView];
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(80, 0, 50, 0));
    }];
    [self.containView layoutIfNeeded];
    [self initGameData];
    [self initGameMap];
    
}
- (UIImage *)getRandomImage{
    NSInteger type = arc4random()%4;
    NSInteger number = arc4random()%13 + 1;
    NSString *name;
    switch (type) {
        case 0:
            name = [NSString stringWithFormat:@"a%ld.jpg",number];
            break;
        case 1:
            name = [NSString stringWithFormat:@"b%ld.jpg",number];
            break;
        case 2:
            name = [NSString stringWithFormat:@"a%ld.jpg",number];
            break;
        case 3:
            name = [NSString stringWithFormat:@"b%ld.jpg",number];
            break;
            
        default:
            break;
    }
    return [UIImage imageNamed:name];
}
- (void)initGameMap{
    NSInteger count = [self getMapCount];

    CGSize buttonSize = CGSizeMake(CGRectGetWidth(self.containView.frame)/(count - 1), CGRectGetWidth(self.containView.frame)/(count - 1)*153/110);
    for (int i= 0; i< count; i++) {
        for (int j= 0; j< count; j++) {
            
            ItemButton *item = [ItemButton buttonWithType:UIButtonTypeCustom];
            item.backgroundColor = [UIColor randomColor];
            PKModel *model = self.gameData[i*count+j];
            model.index = (i << 8)|j;
            item.layer.borderColor = [UIColor blackColor].CGColor;
            item.layer.borderWidth = 1.0;
            [self.containView addSubview:item];
            if (j == 0 || j == count - 1) {
                item.frame = CGRectMake(MAX(j*buttonSize.width - buttonSize.width/2.0, 0), i*buttonSize.height, buttonSize.width/2.0, buttonSize.height);
            }
            else{
                item.frame = CGRectMake(MAX(j*buttonSize.width - buttonSize.width/2.0, 0), i*buttonSize.height, buttonSize.width, buttonSize.height);
            }
            [[item rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                [self itemClickAction:x];
            }];
        }
    }
}
#pragma mark - action
- (void)itemClickAction:(ItemButton *)button{
    if (button.model.type == type_none) {
        return;
    }
    int button_x = (button.model.index >> 8 & 0xF);
    int button_y = (button.model.index & 0x0f);
    NSLog(@"click:(%d,%d)",button_x,button_y);
    
}
- (NSInteger)getMapCount{
    if (self.index < 4) {
       return 8;
    }
    else if (self.index < 8){
        return 10;
    }
    else{
     return 12;
    }
    
}
- (void)initGameData{
    self.gameData = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = pow([self getMapCount]-2, 2)/2.0;
    while (count) {
        PKType  type =  arc4random()%self.gameLevel + 1;
        NSInteger  number  = arc4random()%13 + 1;
        [array addObject:[self getRandomModelWithType:type Number:number]];
        [array addObject:[self getRandomModelWithType:type Number:number]];
        count --;
    }
    NSLog(@"gameData:%@",self.gameData);
}
- (PKModel *)getRandomModelWithType:(PKType)type Number:(NSInteger)number{
    PKModel *model = [[PKModel alloc]init];
    model.type = type;
    model.number = number;
    return model;
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
