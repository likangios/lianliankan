//
//  PKModel.h
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    type_none,
    type_hei,
    type_hong,
    type_mei,
    type_fang,
} PKType;

@interface PKModel : NSObject

//类型
@property(nonatomic,assign) PKType type;

//数字
@property(nonatomic,assign) NSInteger number;

//位置坐标
@property(nonatomic,assign) NSInteger index;

@property(nonatomic,assign) NSInteger x;

@property(nonatomic,assign) NSInteger y;
@end
