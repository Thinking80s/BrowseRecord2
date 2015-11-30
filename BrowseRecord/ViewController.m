//
//  ViewController.m
//  BrowseRecord
//
//  Created by 邓鹏 on 13-11-28.
//  Copyright (c) 2013年 com.kevin. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    WebViewController *webController = [[WebViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webController];
    nav.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    nav.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:nav.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
