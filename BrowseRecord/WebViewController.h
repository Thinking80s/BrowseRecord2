//
//  WebViewController.h
//  JsCode
//
//  Created by 邓鹏 on 13-3-8.
//  Copyright (c) 2013年 com.kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenCaptureView.h"
#import "MBProgressHUD.h"

@interface WebViewController : UIViewController
{
    UITextField *searchField;
    UIWebView *web;
    UIButton *imgBtn;
    BOOL isStart;
}

@end
