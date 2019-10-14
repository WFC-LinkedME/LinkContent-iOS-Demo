//
//  SynchronousEvaluateJavaScript.h
//  LinkKeyWord
//
//  Created by admin on 2019/7/29.
//  Copyright © 2019 admin. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView(SynchronousEvaluateJavaScript)
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
@end

NS_ASSUME_NONNULL_END
