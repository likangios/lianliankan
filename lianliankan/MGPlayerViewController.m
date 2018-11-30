//
//  MGPlayerViewController.m
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "MGPlayerViewController.h"
#import "PKModel.h"
#import "PKCustomButton.h"

static  CFTimeInterval animalTime = 0.2;

@interface MGPlayerViewController ()<CAAnimationDelegate>

@property(nonatomic,strong) NSMutableArray *gameData;

@property(nonatomic,strong) UIButton *backButton;

@property(nonatomic,strong) UIButton *refreshButton;



@property(nonatomic,strong) UIView *containView;
@property(nonatomic,strong) UIImageView *bgImageView;

@property(nonatomic,strong) NSMutableArray *allItemButton;

@property(nonatomic,strong) NSMutableArray *selectButton;

@property(nonatomic,assign) NSInteger selectedCount;

@property(nonatomic,strong) UIProgressView *progressView;

@property(nonatomic,assign) NSInteger hasRemoveCount;

@property(nonatomic,strong) UIImageView *starImageView;

@end

@implementation MGPlayerViewController
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.starImageView.hidden = YES;
}
- (void)animationDidStart:(CAAnimation *)anim{
    self.starImageView.hidden = NO;
}
- (UIImageView *)starImageView{
    if(!_starImageView) {
        _starImageView = [UIImageView new];
        _starImageView.contentMode = UIViewContentModeScaleAspectFill;
        _starImageView.image = [UIImage imageNamed:@"star"];
        _starImageView.hidden = YES;
        
    }
    return _starImageView;
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self cancelTimer];
}
dispatch_source_t timer;
- (void)cancelTimer{
    if (timer) {
        dispatch_source_cancel(timer);
        timer = nil;
    }
}
- (void)ResumeTimer{
    [self cancelTimer];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer,DISPATCH_TIME_NOW,0.1*NSEC_PER_SEC, 0); //每0.1秒执行
    dispatch_source_set_event_handler(timer, ^{
        [self updateTime];
    });
    dispatch_resume(timer);
}
- (void)updateTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress -= 0.0005;
        NSLog(@"self.progressView.progress:%f",self.progressView.progress);
        if (self.progressView.progress <= 0.0) {
            [self cancelTimer];

            UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Game Over" message:@"时间到了！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *back = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction *next = [UIAlertAction actionWithTitle:@"再来一把" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.hasRemoveCount = 0;
                self.progressView.progress = 1.0;
                [self ResumeTimer];
                [self initGameMap];
                [self initGameData];
                [self updateItemButtonModel];
            }];
            [alert addAction:back];
            [alert addAction:next];
            [self presentViewController:alert animated:YES completion:NULL];
        }
    });
}
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]init];
        _progressView.progressTintColor = [UIColor greenColor];
        _progressView.progress = 1.0;
        _progressView.layer.cornerRadius = 2.5;
        _progressView.layer.masksToBounds = YES;
    }
    return _progressView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.allItemButton = [NSMutableArray array];
    self.selectButton = [NSMutableArray array];
    self.selectedCount = 0;
    
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSInteger count = [self getMapCount];
    CGSize buttonSize = CGSizeMake(kSCREEN_WIDTH/(count - 1), kSCREEN_WIDTH/(count - 1)*153/110);
    [self.view addSubview:self.containView];
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.mas_equalTo(kSCREEN_WIDTH);
        make.height.mas_equalTo(buttonSize.height * count);
    }];
    [self.containView layoutIfNeeded];
    [self initGameData];
    [self initGameMap];
    [self updateItemButtonModel];
    [self.containView addSubview:self.starImageView];
    [self.starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(100);
        make.center.equalTo(self.view);
    }];
    
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25);
        make.top.mas_equalTo(25);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.view addSubview:self.refreshButton];
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-25);
        make.top.mas_equalTo(25);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(60);
        make.height.mas_equalTo(5);
        make.top.mas_equalTo(10);
    }];
    [self ResumeTimer];
    
    @weakify(self);
    [RACObserve(self, selectedCount) subscribeNext:^(NSNumber * x) {
        @strongify(self);
        if (x.integerValue == 2) {
            PKCustomButton *firstItem = self.selectButton[0];
            PKCustomButton *secondItem = self.selectButton[1];
            
            if (firstItem.model.type == secondItem.model.type && firstItem.model.number == secondItem.model.number) {
                //花色 一样 判断 是否有 共同列的
                NSArray *hArr = [self getEmptyItemHorizontalWithCurrentItem:firstItem];
                NSArray *hArr2 = [self getEmptyItemHorizontalWithCurrentItem:secondItem];
                
                NSArray *vArr = [self getEmptyItemVerticalWithCurrentItem:firstItem];
                NSArray *vArr2 = [self getEmptyItemVerticalWithCurrentItem:secondItem];
                
                NSArray *guaijiaodian1 = [self getSameIndexYItemWithArr:hArr Array:hArr2];
                NSArray *guaijiaodian2 = [self getSameIndexXItemWithArr:vArr Array:vArr2];

                if (guaijiaodian1 && guaijiaodian1.count) {
                    NSMutableArray *animalsItems = [NSMutableArray arrayWithArray:guaijiaodian1];
                    if (![animalsItems containsObject:firstItem]) {
                        [animalsItems insertObject:firstItem atIndex:0];
                    }
                    if (![animalsItems containsObject:secondItem]) {
                        [animalsItems addObject:secondItem];
                    }
                    [self beginAnimations:animalsItems];
                    NSLog(@"找到 共同 列 可以 消");
                    firstItem.model.type = type_none;
                    secondItem.model.type = type_none;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animalsItems.count * animalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [firstItem  update];
                        [secondItem  update];
                    });
                    self.hasRemoveCount ++;
                }
                else if (guaijiaodian2 && guaijiaodian2.count) {
                    NSLog(@"找到 共同 行 可以 消");
                    NSMutableArray *animalsItems = [NSMutableArray arrayWithArray:guaijiaodian2];
                    if (![animalsItems containsObject:firstItem]) {
                        [animalsItems insertObject:firstItem atIndex:0];
                    }
                    if (![animalsItems containsObject:secondItem]) {
                        [animalsItems addObject:secondItem];
                    }
                    [self beginAnimations:animalsItems];

                    firstItem.model.type = type_none;
                    secondItem.model.type = type_none;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animalsItems.count * animalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [firstItem  update];
                        [secondItem  update];
                    });
                    self.hasRemoveCount ++;
                }
                else{
                    NSLog(@"不可以 消");
                }
                
            }
            else{
                NSLog(@"扑克 不一样 重新 选");
            }
            [self.selectButton removeAllObjects];
        }
    }];
    [RACObserve(self, hasRemoveCount) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        NSInteger count = pow([self getMapCount]-2, 2)/2.0;
        if (x.integerValue == count) {
            self.index ++;
            // 同步关卡
            NSUserDefaults *defau = [NSUserDefaults standardUserDefaults];
            NSString *level = [NSString stringWithFormat:@"%d",self.gameLevel];
            [defau setObject:@(self.index + 1) forKey:level];
            [defau synchronize];
            //暂停计时器
            [self cancelTimer];
            UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"恭喜过关" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *back = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction *next = [UIAlertAction actionWithTitle:@"下一关" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.hasRemoveCount = 0;
                self.progressView.progress = 1.0;
                [self ResumeTimer];
                [self initGameMap];
                [self initGameData];
                [self updateItemButtonModel];
            }];
            [alert addAction:back];
            if (self.index < 12) {
                [alert addAction:next];
            }
            [self presentViewController:alert animated:YES completion:NULL];
        }
        
    }];
}
- (PKCustomButton *)getItemButtonWithPoint_x:(int)x  Point_y:(int)y{
    NSInteger  tag = (x << 8)|y;
    PKCustomButton *item = [self.containView  viewWithTag:tag];
    return item;
}
- (void)beginAnimations:(NSMutableArray *)items{
    CAAnimationGroup *group = [CAAnimationGroup animation];
    PKCustomButton *button = items.firstObject;
    NSMutableArray *groupAnimation = [NSMutableArray array];
    self.starImageView.center = button.center;
    for (int i = 1; i<items.count; i++) {
        PKCustomButton *button = items[i];
        CABasicAnimation *Ani = [self movepoint:button.center duration:animalTime];
        Ani.beginTime = animalTime * (i-1);
        [groupAnimation addObject:Ani];
    }
    group.animations =groupAnimation;
    group.duration = (items.count - 1) * animalTime;
    group.delegate = self;
    group.removedOnCompletion = NO;
    group.autoreverses = NO;
    group.fillMode=kCAFillModeForwards;
    [self.starImageView.layer addAnimation:group forKey:@"move"];
}

-(CABasicAnimation *)movepoint:(CGPoint)point duration:(CFTimeInterval)duration //点移动
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"position"];
    animation.toValue=[NSValue valueWithCGPoint:point];
    animation.removedOnCompletion=NO;
    animation.duration = duration;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}
//查找 两行 直接  共同列
-(NSArray *)getSameIndexYItemWithArr:(NSArray *)arr1 Array:(NSArray *)arr2{
    PKCustomButton *beginItem = nil;
    PKCustomButton *endItem = nil;
    for (PKCustomButton *fItem in arr1) {
        for (PKCustomButton *sItem in arr2) {
            if (fItem.model.y == sItem.model.y && fItem.model.x != sItem.model.x) {
                NSMutableArray *array = [NSMutableArray array];
                for (int x = MIN(fItem.model.x, sItem.model.x); x < MAX(fItem.model.x, sItem.model.x); x ++) {
                    PKCustomButton *centerItem = [self getItemButtonWithPoint_x:x Point_y:fItem.model.y];
                    if (centerItem != fItem && centerItem != sItem) {
                        [array addObject:centerItem];
                    }
                }
                BOOL allEmpty = [array bk_all:^BOOL(PKCustomButton *obj) {
                    return  obj.model.type == type_none;
                }];
                if (array.count == 0 || allEmpty) {
                    beginItem = fItem;
                    endItem = sItem;
                    goto b;
                }
            }
        }
    }
b:{
    if (beginItem && endItem) {
        return @[beginItem,endItem];
    }
    else{
        return nil;
    }
}
    return nil;
}
//查找 两列 直接 共同行
-(NSArray *)getSameIndexXItemWithArr:(NSArray *)arr1 Array:(NSArray *)arr2{
    PKCustomButton *beginItem = nil;
    PKCustomButton *endItem = nil;
    for (PKCustomButton *fItem in arr1) {
        for (PKCustomButton *sItem in arr2) {
            if (fItem.model.x == sItem.model.x && fItem.model.y != sItem.model.y) {
                NSMutableArray *array = [NSMutableArray array];
                for (int y = MIN(fItem.model.y, sItem.model.y); y < MAX(fItem.model.y, sItem.model.y); y ++) {
                    PKCustomButton *centerItem = [self getItemButtonWithPoint_x:fItem.model.x Point_y:y];
                    if (centerItem != fItem && centerItem != sItem) {
                        [array addObject:centerItem];
                    }
                }
                BOOL allEmpty = [array bk_all:^BOOL(PKCustomButton *obj) {
                    return  obj.model.type == type_none;
                }];
                if (array.count == 0 || allEmpty) {
                    beginItem = fItem;
                    endItem = sItem;
                    goto b;
                }
            }
        }
    }
    
    b:{
    if (beginItem && endItem) {
        return @[beginItem,endItem];
    }
        return nil;
    }
    return nil;

}

//垂直方向查找空格子
- (NSMutableArray *)getEmptyItemVerticalWithCurrentItem:(PKCustomButton *)currentItem{
    NSMutableArray *array = [NSMutableArray array];
    int button_x = currentItem.model.x;
    NSInteger currentIndex = [self.allItemButton indexOfObject:currentItem];
    for (int i = button_x; i >= 0; i--) {
        PKCustomButton *item = self.allItemButton[currentIndex];
        if (item == currentItem || item.model.type == type_none) {
            [array addObject:item];
        }
        else{
            break;
        }
        currentIndex -= [self getMapCount];
    }
    currentIndex = [self.allItemButton indexOfObject:currentItem];
    for (int i = button_x; i < [self getMapCount]; i++) {
        PKCustomButton *item = self.allItemButton[currentIndex];
        if (item == currentItem) {
//            NSLog(@"当前item 不用重复加入");
        }else if (item.model.type == type_none) {
            [array addObject:item];
        }
        else{
            break;
        }
        currentIndex += [self getMapCount];
    }
    return array;
}
//水平方向查找空格子
- (NSMutableArray *)getEmptyItemHorizontalWithCurrentItem:(PKCustomButton *)currentItem{
    
    NSMutableArray *array = [NSMutableArray array];
    int button_y = currentItem.model.y;
    NSInteger currentIndex = [self.allItemButton indexOfObject:currentItem];
    for (int i = button_y; i >= 0; i--) {
        PKCustomButton *item = self.allItemButton[currentIndex];
        if (item == currentItem || item.model.type == type_none) {
            [array addObject:item];
        }
        else{
            break;
        }
        currentIndex --;
    }
    currentIndex = [self.allItemButton indexOfObject:currentItem];
    for (int i = button_y; i < [self getMapCount]; i++) {
        PKCustomButton *item = self.allItemButton[currentIndex];
        if (item == currentItem) {
//            NSLog(@"当前item 不用重复加入");
        }else if (item.model.type == type_none) {
            [array addObject:item];
        }
        else{
            break;
        }
        currentIndex ++;
    }
    return array;
    
}
- (void)initGameMap{
    self.allItemButton = [NSMutableArray array];
    self.selectButton = [NSMutableArray array];
    for (PKCustomButton * item in self.containView.subviews) {
        [item removeFromSuperview];
    }
    NSInteger count = [self getMapCount];
    CGSize buttonSize = CGSizeMake(CGRectGetWidth(self.containView.frame)/(count - 1), CGRectGetWidth(self.containView.frame)/(count - 1));
    for (int i= 0; i< count; i++) {
        for (int j= 0; j< count; j++) {
            PKCustomButton *item = [PKCustomButton buttonWithType:UIButtonTypeCustom];
            item.layer.borderColor = [UIColor blackColor].CGColor;
            item.layer.borderWidth = 1.0;
            item.tag =  (i << 8)|j;
            [self.containView addSubview:item];
            if (j == 0 || j == count - 1) {
                item.frame = CGRectMake(MAX(j*buttonSize.width - buttonSize.width/2.0, 0), i*buttonSize.height, buttonSize.width/2.0, buttonSize.height);
            }
            else{
                item.frame = CGRectMake(MAX(j*buttonSize.width - buttonSize.width/2.0, 0), i*buttonSize.height, buttonSize.width, buttonSize.height);
            }
            @weakify(self);
            [[item rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self itemClickAction:x];
            }];
            [self.allItemButton addObject:item];
        }
    }
}
- (void)updateItemButtonModel{
    NSInteger  index = 0;
    for (PKCustomButton *button  in self.allItemButton) {
        button.model = self.gameData[index];
        index ++;
    }
}
#pragma mark - action
- (void)itemClickAction:(PKCustomButton *)button{
    if (button.model.type == type_none) {
        return;
    }
    if ([self.selectButton containsObject:button]) {
        return;
    }
    int button_x = (button.model.index >> 8 & 0xF);
    int button_y = (button.model.index & 0x0f);
    NSLog(@"click:(%d,%d)",button_x,button_y);
    
    [self.selectButton addObject:button];
    self.selectedCount = self.selectButton.count;
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
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (arc4random()%2) {
            return obj1 < obj2;
        }
        else{
         return obj1 > obj2;
        }
    }];
    NSInteger itemCount = [self getMapCount];
    for (int i= 0; i< itemCount; i++) {
        for (int j= 0; j< itemCount; j++) {
            PKModel *model;
            if (i == 0 || i == itemCount - 1 || j == 0 || j == itemCount - 1) {
                model = [self getRandomModelWithType:type_none Number:0];
            }
            else{
                model = array.firstObject;
                [array removeObjectAtIndex:0];
            }
            model.index = (i << 8)|j;
            [self.gameData addObject:model];
        }
    }
    NSLog(@"gameData:%@",self.gameData);
}
- (PKModel *)getRandomModelWithType:(PKType)type Number:(NSInteger)number{
    PKModel *model = [[PKModel alloc]init];
    model.type = type;
    model.number = number;
    return model;
}

#pragma mark - lazy init
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
-(UIView *)containView{
    if (!_containView) {
        _containView = [UIView new];
        _containView.backgroundColor = [UIColor clearColor];
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
- (UIButton *)refreshButton{
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setImage:[UIImage imageNamed:@"shuaxin"] forState:UIControlStateNormal];
        @weakify(self);
        [[_refreshButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self refreshAction];
        }];
    }
    return _refreshButton;
}
- (void)refreshAction{
    self.progressView.progress -= 0.15;
    NSMutableArray *types = [NSMutableArray array];
    NSMutableArray *numbers = [NSMutableArray array];
    NSMutableArray *buttonsArray = [NSMutableArray array];
    [self.allItemButton enumerateObjectsUsingBlock:^(PKCustomButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (button.model.type != type_none) {
            [buttonsArray addObject:button];
            [types addObject:@(button.model.type)];
            [numbers addObject:@(button.model.number)];
        }
    }];
    [buttonsArray enumerateObjectsUsingBlock:^(PKCustomButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PKModel *model = obj.model;
        NSInteger  index = arc4random()%types.count;
        NSNumber *type = types[index];
        NSNumber *numb = numbers[index];
        model.type = type.integerValue;
        model.number = numb.integerValue;
        obj.model = model;
        [types removeObjectAtIndex:index];
        [numbers removeObjectAtIndex:index];
    }];
    NSLog(@"sdfgdsfdsc");
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
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
