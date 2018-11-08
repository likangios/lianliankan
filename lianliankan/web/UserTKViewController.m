//
//  UserTKViewController.m
//  yezjk
//
//  Created by perfay on 2018/10/12.
//  Copyright © 2018年 luck. All rights reserved.
//

#import "UserTKViewController.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"
#import <AFNetworking.h>
@interface UserTKViewController ()<WKNavigationDelegate,UIScrollViewDelegate>

@property(nonatomic,strong) WKWebView *webView;

@property(nonatomic,strong) UIButton *confirmButton;

@property(nonatomic,assign) BOOL hasHiddenRecommond;

@property(nonatomic,assign) BOOL hasHiddenPay;


@end

@implementation UserTKViewController

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"我同意" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
        _confirmButton.layer.cornerRadius = 4;
        _confirmButton.backgroundColor = [UIColor colorWithHexString:@"181713"];
    }
    return _confirmButton;
}
- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.allowsLinkPreview = false;
        _webView.navigationDelegate = self;
        _webView.scrollView.delegate = self;
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"first"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.confirmButton];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(-40);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
//    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    if (app.yinsitiaokuanUrl.length) {
//        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:app.yinsitiaokuanUrl]]];
//    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com/p/d6f7a449162f"]]];

    [[self.confirmButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                 [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com/p/d6f7a449162f"]]];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                 [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com/p/d6f7a449162f"]]];
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];
    
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    self.webView.alpha = 0;
    [SVProgressHUD show];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    //顶部 下载APP
    [webView evaluateJavaScript:@"document.getElementsByClassName('header-wrap')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
    }];
    //底部打开APP
    [webView evaluateJavaScript:@"document.getElementsByClassName('footer-wrap')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {

    }];
    //底部 登录 打开 热门
    [webView evaluateJavaScript:@"document.getElementsByClassName('panel')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
    //顶部打卡APP
    [webView evaluateJavaScript:@"document.getElementsByClassName('app-open')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
    //中部 打开APP阅读
    [webView evaluateJavaScript:@"document.getElementsByClassName('open-app-btn')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
    //顶部 作者信息
    [webView evaluateJavaScript:@"document.getElementsByClassName('article-info')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
    
    [SVProgressHUD dismiss];
    self.webView.alpha = 1;

}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!self.hasHiddenRecommond) {
        //推荐文章 第一篇广告
        [self.webView evaluateJavaScript:@"document.getElementsByClassName('recommend-note')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            if (error == nil) {
                self.hasHiddenRecommond = YES;
            }
        }];
    }
    if (!self.hasHiddenPay) {
        //赞赏
        [self.webView evaluateJavaScript:@"document.getElementsByClassName('btn btn-pay reward-button')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            if (error == nil) {
                self.hasHiddenPay = YES;
            }
        }];
        [self.webView evaluateJavaScript:@"document.getElementsByClassName('ad')[0].style.display = 'none'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        }];
    }

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
