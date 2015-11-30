//
//  DetailViewController.m
//  JsCode
//
//  Created by 邓鹏 on 13-3-9.
//  Copyright (c) 2013年 com.kevin. All rights reserved.
//

#import "DetailViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MediaPlayer/MediaPlayer.h>

@interface DetailViewController () <UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    MPMoviePlayerController *moviePlayer;
}

@end

@implementation DetailViewController

@synthesize url,content;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:YES animated:NO];
    self.title = NSLocalizedString(@"show",nil);
    UIBarButtonItem *share = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shared)] autorelease];
    self.navigationItem.rightBarButtonItem = share;
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.url]];
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    [moviePlayer setFullscreen:NO];
    [self.view addSubview:moviePlayer.view];
    [moviePlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRecord) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    moviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)stopRecord
{
    [self.navigationController popViewControllerAnimated:YES];
}

//当点击Done按键或者播放完毕上一曲/下一曲时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification
{
    MPMoviePlayerController *_mp = [theNotification object];
    NSLog(@"%ld",(long)_mp.playbackState);
    if ((long)_mp.playbackState == 0) {
        [_mp setContentURL:[NSURL fileURLWithPath:self.url]];
        [_mp stop];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_mp];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)shared
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        NSArray *activityItems = [[NSArray alloc] initWithObjects: NSLocalizedString(@"shareTitle",nil), @"", [NSURL fileURLWithPath:self.url], nil];
        UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        [self presentViewController:act animated:YES completion: nil];
        
        [act setCompletionHandler:^(NSString *act, BOOL done){
            if ( done ){
                UIAlertView *Alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"shareSuccess",nil) message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"confirm",nil) otherButtonTitles:nil];
                [Alert show];
                [Alert release];
            }
        }];
        [activityItems release];
        [act release];
    }else{
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",nil) destructiveButtonTitle: nil otherButtonTitles:NSLocalizedString(@"share",nil), nil];
        [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSArray *str = [self.url componentsSeparatedByString:@"_"];
        [controller setSubject:[NSString stringWithFormat:@"%@ - %@.mp4",NSLocalizedString(@"name",nil), [str objectAtIndex:1]]];
        NSData *data = [NSData dataWithContentsOfFile: self.url];
        //[controller setMessageBody:NSLocalizedString(@"name",nil) isHTML:YES];
        [controller addAttachmentData:data mimeType:@"mp4" fileName:[NSString stringWithFormat:@"%@.mp4",[str objectAtIndex:1]]];
        if (controller) [self presentModalViewController:controller animated:YES];
        [controller release];
    }else if(buttonIndex == 1){
        /*UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
         pasteboard.string = self.url;
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"copysuccess",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"confirm",nil) otherButtonTitles:nil, nil];
         [alert show];
         [alert release];*/
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (error == nil){
        NSString *msg;
        switch (result)
        {
            case MFMailComposeResultCancelled:
                msg = NSLocalizedString(@"maincancel",nil);
                break;
            case MFMailComposeResultSaved:
                msg = NSLocalizedString(@"mainsuccess",nil);
                break;
            case MFMailComposeResultSent:
                msg = NSLocalizedString(@"mainsend",nil);
                break;
            case MFMailComposeResultFailed:
                msg = NSLocalizedString(@"mainfail",nil);
                break;
            default:
                break;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"confirm",nil) otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [moviePlayer release];
    [content release];
    [url release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
