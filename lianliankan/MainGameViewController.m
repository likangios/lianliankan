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

@property(nonatomic,strong) UIButton *refreshButton;



@property(nonatomic,strong) UIView *containView;
@property(nonatomic,strong) UIImageView *bgImageView;

@property(nonatomic,strong) NSMutableArray *allItemButton;

@property(nonatomic,strong) NSMutableArray *selectButton;

@property(nonatomic,assign) NSInteger selectedCount;

@property(nonatomic,strong) UIProgressView *progressView;

@property(nonatomic,assign) NSInteger hasRemoveCount;

@end

@implementation MainGameViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self YDD_cancelTimer];
}
dispatch_source_t timer;
- (void)YDD_cancelTimer{
    if (timer) {
        dispatch_source_cancel(timer);
        timer = nil;
    }
}
- (void)YDD_resumeTimer{
    [self YDD_cancelTimer];
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
            [self YDD_cancelTimer];

            UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Game Over" message:@"时间到了！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *back = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction *next = [UIAlertAction actionWithTitle:@"再来一把" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.hasRemoveCount = 0;
                self.progressView.progress = 1.0;
                [self YDD_resumeTimer];
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
    [self YDD_resumeTimer];
    
    @weakify(self);
    [RACObserve(self, selectedCount) subscribeNext:^(NSNumber * x) {
        @strongify(self);
        if (x.integerValue == 2) {
            ItemButton *firstItem = self.selectButton[0];
            ItemButton *secondItem = self.selectButton[1];
            
            if (firstItem.model.type == secondItem.model.type && firstItem.model.number == secondItem.model.number) {
                //花色 一样 判断 是否有 共同列的
                NSArray *hArr = [self getEmptyItemHorizontalWithCurrentItem:firstItem];
                NSArray *hArr2 = [self getEmptyItemHorizontalWithCurrentItem:secondItem];
                
                NSArray *vArr = [self getEmptyItemVerticalWithCurrentItem:firstItem];
                NSArray *vArr2 = [self getEmptyItemVerticalWithCurrentItem:secondItem];
                

                if ([self getSameIndexYItemWithArr:hArr Array:hArr2]) {
                    NSLog(@"找到 共同 列 可以 消");
                    firstItem.model.type = type_none;
                    secondItem.model.type = type_none;
                    [firstItem  update];
                    [secondItem  update];
                    self.hasRemoveCount ++;
                }
                else if ([self getSameIndexXItemWithArr:vArr Array:vArr2]) {
                    NSLog(@"找到 共同 行 可以 消");
                    firstItem.model.type = type_none;
                    secondItem.model.type = type_none;
                    [firstItem  update];
                    [secondItem  update];
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
            
            UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"恭喜过关" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *back = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction *next = [UIAlertAction actionWithTitle:@"下一关" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.hasRemoveCount = 0;
                self.progressView.progress = 1.0;
                [self YDD_resumeTimer];
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
- (ItemButton *)getItemButtonWithPoint_x:(int)x  Point_y:(int)y{
    NSInteger  tag = (x << 8)|y;
    ItemButton *item = [self.containView  viewWithTag:tag];
    return item;
}
//查找 两行 直接  共同列
-(NSArray *)getSameIndexYItemWithArr:(NSArray *)arr1 Array:(NSArray *)arr2{
    ItemButton *beginItem = nil;
    ItemButton *endItem = nil;
    for (ItemButton *fItem in arr1) {
        for (ItemButton *sItem in arr2) {
            if (fItem.model.y == sItem.model.y) {
                NSMutableArray *array = [NSMutableArray array];
                for (int x = MIN(fItem.model.x, sItem.model.x); x < MAX(fItem.model.x, sItem.model.x); x ++) {
                    ItemButton *centerItem = [self getItemButtonWithPoint_x:x Point_y:fItem.model.y];
                    if (centerItem != fItem && centerItem != sItem) {
                        [array addObject:centerItem];
                    }
                }
                BOOL allEmpty = [array bk_all:^BOOL(ItemButton *obj) {
                    return  obj.model.type == type_none;
                }];
                if (array.count == 0 || allEmpty) {
                    beginItem = fItem;
                    endItem = sItem;
                    break;
                }
            }
        }
    }
    if (beginItem && endItem) {
        return @[beginItem,endItem];
    }
    else{
        return nil;
    }
}
//查找 两列 直接 共同行
-(NSArray *)getSameIndexXItemWithArr:(NSArray *)arr1 Array:(NSArray *)arr2{
    ItemButton *beginItem = nil;
    ItemButton *endItem = nil;
    for (ItemButton *fItem in arr1) {
        for (ItemButton *sItem in arr2) {
            if (fItem.model.x == sItem.model.x) {
                NSMutableArray *array = [NSMutableArray array];
                for (int y = MIN(fItem.model.y, sItem.model.y); y < MAX(fItem.model.y, sItem.model.y); y ++) {
                    ItemButton *centerItem = [self getItemButtonWithPoint_x:fItem.model.x Point_y:y];
                    if (centerItem != fItem && centerItem != sItem) {
                        [array addObject:centerItem];
                    }
                }
                BOOL allEmpty = [array bk_all:^BOOL(ItemButton *obj) {
                    return  obj.model.type == type_none;
                }];
                if (array.count == 0 || allEmpty) {
                    beginItem = fItem;
                    endItem = sItem;
                    break;
                }
            }
        }
    }
    if (beginItem && endItem) {
        return @[beginItem,endItem];
    }
    else{
        return nil;
    }
}

//垂直方向查找空格子
- (NSMutableArray *)getEmptyItemVerticalWithCurrentItem:(ItemButton *)currentItem{
    NSMutableArray *array = [NSMutableArray array];
    int button_x = currentItem.model.x;
    NSInteger currentIndex = [self.allItemButton indexOfObject:currentItem];
    for (int i = button_x; i >= 0; i--) {
        ItemButton *item = self.allItemButton[currentIndex];
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
        ItemButton *item = self.allItemButton[currentIndex];
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
- (NSMutableArray *)getEmptyItemHorizontalWithCurrentItem:(ItemButton *)currentItem{
    
    NSMutableArray *array = [NSMutableArray array];
    int button_y = currentItem.model.y;
    NSInteger currentIndex = [self.allItemButton indexOfObject:currentItem];
    for (int i = button_y; i >= 0; i--) {
        ItemButton *item = self.allItemButton[currentIndex];
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
        ItemButton *item = self.allItemButton[currentIndex];
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
    for (ItemButton * item in self.containView.subviews) {
        [item removeFromSuperview];
    }
    NSInteger count = [self getMapCount];
    CGSize buttonSize = CGSizeMake(CGRectGetWidth(self.containView.frame)/(count - 1), CGRectGetWidth(self.containView.frame)/(count - 1)*153/110);
    for (int i= 0; i< count; i++) {
        for (int j= 0; j< count; j++) {
            ItemButton *item = [ItemButton buttonWithType:UIButtonTypeCustom];
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
    for (ItemButton *button  in self.allItemButton) {
        button.model = self.gameData[index];
        index ++;
    }
}
#pragma mark - action
- (void)itemClickAction:(ItemButton *)button{
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
    
    NSMutableArray *types = [NSMutableArray array];
    NSMutableArray *numbers = [NSMutableArray array];
    NSMutableArray *buttonsArray = [NSMutableArray array];
    [self.allItemButton enumerateObjectsUsingBlock:^(ItemButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (button.model.type != type_none) {
            [buttonsArray addObject:button];
            [types addObject:@(button.model.type)];
            [numbers addObject:@(button.model.number)];
        }
    }];
    [buttonsArray enumerateObjectsUsingBlock:^(ItemButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
