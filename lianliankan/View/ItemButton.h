//
//  ItemButton.h
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKModel.h"
@interface ItemButton : UIButton

@property(nonatomic,strong) PKModel *model;

- (void)update;
@end
