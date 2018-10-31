//
//  PKModel.m
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "PKModel.h"

@implementation PKModel

- (int)x{
    int button_x = (self.index >> 8 & 0xF);
    return button_x;
}
-(int)y{
    int button_y = (self.index & 0x0f);
    return button_y;
}
@end
