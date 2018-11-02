//
//  LLKCardsView.m
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "LLKCardsView.h"
#import "LLKCardsCell.h"

@interface LLKCardsView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic,strong) NSArray  *dataArray;

@end

@implementation LLKCardsView

- (RACSubject *)cellSelected{
    if (!_cellSelected) {
        _cellSelected = [RACSubject subject];
    }
    return _cellSelected;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(110 * 0.5, 153 * 0.5);
        layout.minimumLineSpacing = 20.0;
        layout.minimumInteritemSpacing = 10.0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
        [_collectionView registerClass:[LLKCardsCell class] forCellWithReuseIdentifier:@"LLKCardsCell"];
//        _collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}
- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    [self.collectionView reloadData];
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 13;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LLKCardsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LLKCardsCell" forIndexPath:indexPath];
    cell.guankaLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    cell.guanka.image = [UIImage imageNamed:[NSString stringWithFormat:@"d%ld",indexPath.row+1]];
    cell.isLock = YES;
    if (indexPath.row < self.currentIndex) {
        cell.isLock = NO;
    }
    return  cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.currentIndex) {
        if (self.cellSelected) {
            [self.cellSelected sendNext:@(indexPath.row)];
        }
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"先解锁前面关卡"];
    }
}

@end
