//
//  HRDControlView.h
//  yezjk
//
//  Created by perfay on 2018/10/11.
//  Copyright © 2018年 luck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRDControlView : UIView
@property(nonatomic,copy) void (^buttonClick)(NSInteger index);
@end
