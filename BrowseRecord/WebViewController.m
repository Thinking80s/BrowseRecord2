//
//  WebViewController.m
//  JsCode
//
//  Created by 邓鹏 on 13-3-8.
//  Copyright (c) 2013年 com.kevin. All rights reserved.
//

#import "WebViewController.h"
#import "ListViewController.h"
#import "ScreenCaptureView.h"
#import "MTStatusBarOverlay.h"
#import "JDStatusBarNotification.h"

@interface WebViewController () <UITextFieldDelegate,UIWebViewDelegate,ScreenCaptureViewDelegate>
{
    //MTStatusBarOverlay *overlay;
    UIBarButtonItem *reload;
    UIBarButtonItem *stop;
    UIBarButtonItem *space;
    UIBarButtonItem *space1;
    UIBarButtonItem *space2;
    UIBarButtonItem *back;
    UIBarButtonItem *forward;
    UIBarButtonItem *format;
}
@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    ScreenCaptureView *view = [[ScreenCaptureView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    view.delegate = self;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    web = [[UIWebView alloc] init];
    [web setBackgroundColor:[UIColor whiteColor]];
    web.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [web setOpaque:NO];
    web.scalesPageToFit = YES;
    web.delegate = self;
    web.contentMode = UIViewContentModeScaleToFill;
    web.multipleTouchEnabled = YES;
    [self.view addSubview:web];
    [web release];
    [self.navigationController setToolbarHidden:NO];
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20, 30)];
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.delegate = self;
    searchField.text = @"http://";
    searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchField.keyboardType = UIKeyboardTypeURL;
    searchField.returnKeyType = UIReturnKeyGo;
    searchField.font = [UIFont fontWithName:@"Helvetica" size:15];
    searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchField.borderStyle = UITextBorderStyleRoundedRect;
    searchField.textAlignment = NSTextAlignmentLeft;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.clearsOnBeginEditing = NO;
    searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.navigationItem.titleView = searchField;
    
    reload = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)] autorelease];
    stop = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(detail:)] autorelease];
    space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
    space.width = 35;
    space1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
    space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
    space2.width = 35;
    back = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:101 target:self action:@selector(back)] autorelease];
    forward = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:102 target:self action:@selector(forward)] autorelease];
    format = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(format)];
    [self setToolbarItems:[NSArray arrayWithObjects:reload, space, back ,space, forward,  space1, format, space2, stop, nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name:@"MPMoviePlayerDidExitFullscreenNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRecord) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)stopRecord
{
    if (isStart) {
        reload = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)] autorelease];
        stop = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(detail:)] autorelease];
        space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
        space.width = 35;
        space1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
        space2.width = 35;
        back = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:101 target:self action:@selector(back)] autorelease];
        forward = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:102 target:self action:@selector(forward)] autorelease];
        format = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(format)];
        [self setToolbarItems:[NSArray arrayWithObjects:reload, space, back ,space, forward,  space1, format, space2, stop, nil]];
        [self.view performSelector:@selector(stopRecording) withObject:nil];
        [JDStatusBarNotification dismiss];
        //[overlay hide];
        isStart = false;
    }
}

- (void)exitFullScreen:(NSNotification*)notification
{
    [self detail:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MPMoviePlayerDidExitFullscreenNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    web.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.navigationController setToolbarHidden:NO animated:NO];
//    overlay = [MTStatusBarOverlay sharedInstance];
//    overlay.animation = MTStatusBarOverlayAnimationFallDown;
//    overlay.detailViewMode = MTDetailViewModeHistory;
}

- (void)recordingFinished:(NSString *)url
{
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *data = [NSMutableArray arrayWithArray:[dfs objectForKey:@"videos"]];
    [data insertObject:url atIndex:0];
    [dfs setObject:data forKey:@"videos"];
    [dfs synchronize];
}

- (void)format
{
    if (![searchField.text isEqualToString:@"http://"] && ![searchField.text isEqualToString:@""]) {
        if (![self validateUrl:searchField.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"info",nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"confirm",nil) otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            return;
        }
        
        if (isStart) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"end", nil);
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
            [JDStatusBarNotification dismiss];
            //[overlay hide];
            
            reload = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)] autorelease];
            stop = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(detail:)] autorelease];
            space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
            space.width = 35;
            space1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
            space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
            space2.width = 35;
            back = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:101 target:self action:@selector(back)] autorelease];
            forward = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:102 target:self action:@selector(forward)] autorelease];
            format = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(format)];
            [self setToolbarItems:[NSArray arrayWithObjects:reload, space, back ,space, forward,  space1, format, space2, stop, nil]];
            
            [self.view performSelector:@selector(stopRecording) withObject:nil];
            [self detail:YES];
        }else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"start", nil);
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
            
            reload = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)] autorelease];
            stop = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(detail:)] autorelease];
            space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
            space.width = 35;
            space1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
            space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
            space2.width = 35;
            back = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:101 target:self action:@selector(back)] autorelease];
            forward = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:102 target:self action:@selector(forward)] autorelease];
            format = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(format)];
            [self setToolbarItems:[NSArray arrayWithObjects:reload, space, back ,space, forward,  space1, format, space2, stop, nil]];
            
            [self.view performSelector:@selector(startRecording) withObject:nil afterDelay:1];
            
            [JDStatusBarNotification showWithStatus:NSLocalizedString(@"record", nil)];
            [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
            //[overlay postMessage:NSLocalizedString(@"record", nil) animated:YES];
        }
        isStart = !isStart;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"info",nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"confirm",nil) otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (BOOL)validateUrl: (NSString *) candidate {
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (BOOL)isValidURL:(NSString *)url
{
    NSURL *_url = [NSURL URLWithString: url];
    NSURLRequest *req = [NSURLRequest requestWithURL: _url];
    NSHTTPURLResponse *res = nil;
    NSError *err = nil;
    [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    return err!=nil && [res statusCode]!=404;
}

- (void)detail:(BOOL)animation
{
    ListViewController *list = [[ListViewController alloc] init];
    [self.navigationController pushViewController:list animated:animation];
    [list release];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)back{
    [web goBack];
}

- (void)forward{
    [web goForward];
}

- (void)reload
{
    [web reload];
}

- (void)stopLoad
{
    [web stopLoading];
}

- (void)loadUrl:(NSString *)url
{
    NSURL* _url = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:_url];
    [web loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"%@",error);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text) {
        if (![self validateUrl:searchField.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"info",nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"confirm",nil) otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }else{
            [self performSelector:@selector(loadUrl:) withObject:textField.text];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"info",nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"confirm",nil) otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    [textField resignFirstResponder];
    return true;
}

- (void)dealloc
{
    //[overlay release];
    [web release];
    web.delegate = nil;
    [imgBtn release];
    [searchField release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
