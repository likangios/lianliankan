//
//  HRDCTManager.m
//  LeanCloudDemo
//
//  Created by perfay on 2018/9/4.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "HRDCTManager.h"
#import <AVOSCloud/AVOSCloud.h>

static HRDCTManager *shareInstance;

static CGFloat Second_Day = 24 * 60 * 60;


@implementation HRDCTManager

+ (instancetype) sharInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[HRDCTManager alloc]init];
    });
    [shareInstance luckTempMethodHelloworld];
    return shareInstance;
}
-(void)luckTempMethodHelloworld{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"luckMethod"];
    if ([number.stringValue isEqualToString:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@2 forKey:@"luckMethod"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"luckMethod"];
    }
}
- (BOOL)isPush{
    AVObject *classObject = [AVObject objectWithClassName:@"PushContro"];
    [classObject refresh];
    NSArray *object = [classObject objectForKey:@"results"];
    if (object.count) {
        NSNumber *isPush = [object[0] objectForKey:@"isPush"];
        return isPush.boolValue;
    }
    return  NO;
}
- (NSString *)url{
    AVObject *classObject = [AVObject objectWithClassName:@"PushContro"];
    [classObject refresh];
    NSArray *object = [classObject objectForKey:@"results"];
    NSString *url;
    if (object.count) {
        url = [object[0] objectForKey:@"url"];
    }
    return  url;
}
- (NSString *)appkey{
    AVObject *classObject = [AVObject objectWithClassName:@"PushContro"];
    [classObject refresh];
    NSArray *object = [classObject objectForKey:@"results"];
    NSString *appkey;
    if (object.count) {
        appkey = [object[0] objectForKey:@"appkey"];
    }
    return  appkey;
}
- (NSString *)tiaokuan{
    AVObject *classObject = [AVObject objectWithClassName:@"PushContro"];
    [classObject refresh];
    NSArray *object = [classObject objectForKey:@"results"];
    NSString *tiaokuan;
    if (object.count) {
        tiaokuan = [object[0] objectForKey:@"tiaokuan"];
    }
    return  tiaokuan;
}
- (BOOL)vipIsValidWith:(NSString *)username{
    NSError *error;
    AVUser *user = [AVUser logInWithUsername:username password:@"123456" error:&error];
    user = [AVUser currentUser];
    NSNumber *diff = [user objectForKey:@"diff"];
    NSDate *creatData = user.createdAt;
    NSDate *now = [NSDate date];
    if(now.timeIntervalSince1970 > (creatData.timeIntervalSince1970 + diff.intValue * Second_Day )){
        return NO;
    }
    else{
        return YES;
    }
}
- (BOOL)isEnable{
    NSError *error;
    AVUser *user = [AVUser logInWithUsername:@"123456" password:@"123456" error:&error];
    user = [AVUser currentUser];
    NSNumber *able = [user objectForKey:@"enable"];
    return able.boolValue;
}
- (NSString *)testName{
    AVUser *user = [AVUser currentUser];
    NSString *name = [user objectForKey:@"TestName"];
    return name;
}

@end
