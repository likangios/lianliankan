//
//  ItemButton.m
//  lianliankan
//
//  Created by perfay on 2018/10/30.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "ItemButton.h"

@implementation ItemButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setModel:(PKModel *)model{
    _model = model;
    NSString *name;
    switch (model.type) {
        case type_none:
            name = @"cardBackground";
            break;
        case type_hei:
            name = [NSString stringWithFormat:@"d%ld.jpg",_model.number];
            break;
        case type_hong:
            name = [NSString stringWithFormat:@"b%ld.jpg",_model.number];
            break;
        case type_mei:
            name = [NSString stringWithFormat:@"c%ld.jpg",_model.number];
            break;
        case type_fang:
            name = [NSString stringWithFormat:@"a%ld.jpg",_model.number];
            break;
            
        default:
            break;
    }
    [self setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
}

@end
