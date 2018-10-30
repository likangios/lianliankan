//
//  HRDCTManager.h
//  LeanCloudDemo
//
//  Created by perfay on 2018/9/4.
//  Copyright © 2018年 luck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRDCTManager : NSObject
+ (instancetype)sharInstance;
- (BOOL)isPush;
- (NSString *)url;
- (NSString *)appkey;
- (NSString *)tiaokuan;
- (BOOL)vipIsValidWith:(NSString *)username;
- (BOOL)isEnable;
- (NSString *)testName;
@end
