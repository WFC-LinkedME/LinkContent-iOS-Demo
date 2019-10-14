//
//  ViewController.m
//  LinkKeyWord
//
//  Created by admin on 2019/7/29.
//  Copyright © 2019 admin. All rights reserved.
//

#import "LMWebViewController.h"
#import <WebKit/WebKit.h>
#import <AdSupport/AdSupport.h>

#define IDFA [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]

@interface LMWebViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic ,strong) WKWebView *webView;
@property (nonatomic,strong,readwrite) UIBarButtonItem *returnButton;

@end

@implementation LMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"LinkContent";
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    [self returnButton];
    [self.view addSubview:self.webView];
        
    NSString * url = [NSString stringWithFormat:@"http://content.linkedme.cc/feed/index.html?app_key=7e289a2484f4368dbafbd1e5c7d06903&device_type=0&device_id=%@",IDFA];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:req];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    //在详情页添加返回按钮并注入JS
    if (self.webView.canGoBack) {
        NSString *scriptURL = @"https://content.linkedme.cc/feed/content_sdk.js";
        NSString *requestURL = [scriptURL stringByAppendingFormat:@"?%@", @(arc4random() % 999)];

        NSString *appKey = @"7e289a2484f4368dbafbd1e5c7d06903";
        NSString *js = [NSString stringWithFormat:@"var linkedmeScript = document.createElement('script');linkedmeScript.src='%@';document.getElementsByTagName('head')[0].appendChild(linkedmeScript);linkedmeScript.onload=function(){ initLinkContent(%@,'%@','%@').exposure()};",requestURL,appKey,IDFA,@"0"];
        
        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable object, NSError * _Nullable error){
            NSLog(@"------error = %@ object = %@",error,object);
        }];
      }
}

- (UIBarButtonItem *)returnButton {
    if (!_returnButton) {
        _returnButton = [[UIBarButtonItem alloc] init];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"首页" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button sizeToFit];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        button.frame = CGRectMake(20, 0, 40, 40);
        _returnButton.customView = button;
        self.navigationItem.leftBarButtonItem = _returnButton;
    }
    return _returnButton;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    
    if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
            [[UIApplication sharedApplication] openURL:URL options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO} completionHandler:^(BOOL success) {
                if (success) {
                    //上报统计
                    NSLog(@"open app success!");
                }
            }];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)back{
//    self.navigationItem.leftBarButtonItem
    [self.webView goBack];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}



@end
