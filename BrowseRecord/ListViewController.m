//
//  ListViewController.m
//  JsCode
//
//  Created by 邓鹏 on 13-3-8.
//  Copyright (c) 2013年 com.kevin. All rights reserved.
//

#import "ListViewController.h"
#import "DetailViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImageScale.h"
#import <AVFoundation/AVFoundation.h>

#define EXPAND_HEIGHT ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ? 0 : 0

@interface ListViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation ListViewController

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
    self.title = NSLocalizedString(@"all", nil);
    [super viewDidLoad];
    table = [[[UITableView alloc] initWithFrame:CGRectMake(0, EXPAND_HEIGHT, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain] autorelease];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
    UIBarButtonItem *_edit = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                            target:self action:@selector(edit)] autorelease];
    self.navigationItem.rightBarButtonItem = _edit;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(activeReload)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)activeReload
{
    [table reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self activeReload];
}

- (void)edit
{
    table.editing = YES;
    [table setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = nil;
    UIBarButtonItem *_done = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                            target:self action:@selector(done)] autorelease];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.rightBarButtonItem = _done;
}

- (void)done
{
    [table setEditing:NO animated:YES];
    table.editing = NO;
    UIBarButtonItem *_edit = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                            target:self action:@selector(edit)] autorelease];
    
    [self.navigationItem setHidesBackButton:NO];
    self.navigationItem.rightBarButtonItem = _edit;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUserDefaults  *dfs = [NSUserDefaults standardUserDefaults];
    return [[dfs objectForKey:@"videos"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * showUserInfoCellIdentifier = @"Cell";
	UITableViewCell * cell = [table dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:showUserInfoCellIdentifier]
				autorelease];
	}
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [dfs objectForKey:@"videos"];
	cell.textLabel.text = [[[arr objectAtIndex:indexPath.row] componentsSeparatedByString:@"_"] objectAtIndex:1];
    //cell.textLabel.numberOfLines = 2;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.imageView.image = [self getThumb:[arr objectAtIndex:indexPath.row]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self getFileSize:[arr objectAtIndex:indexPath.row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailViewController *detail = [[DetailViewController alloc] init];
    NSUserDefaults  *dfs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [dfs objectForKey:@"videos"];
    detail.url = [arr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUserDefaults  *dfs = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[dfs objectForKey:@"videos"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager removeItemAtPath:[arr objectAtIndex:[indexPath row]] error:NULL]) {
            [arr removeObjectAtIndex:[indexPath row]];
            [dfs setObject:arr forKey:@"videos"];
        }
        [dfs synchronize];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSString *)getFileSize:(NSString *)url
{
    NSDictionary *file = [[NSFileManager defaultManager] attributesOfItemAtPath:url error:nil];
    int size = (int)[file fileSize]/1024;
    return size >= 1024 ? [NSString stringWithFormat:@"%iM",size/1024] : [NSString stringWithFormat:@"%iKB",size];
}

- (UIImage *)getThumb:(NSString *)url
{
    NSURL *videoURL = [NSURL fileURLWithPath:url];
    UIImage *thumbnail = [[self class] thumbnailImageForVideo:videoURL atTime:0.0f];
    thumbnail = [thumbnail scaleToSize:CGSizeMake(90, 150)];
    return thumbnail;
}

//获取视屏缩略图
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:videoURL options:nil] autorelease];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[[UIImage alloc] initWithCGImage:thumbnailImageRef] autorelease] : nil;
    
    return thumbnailImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    table.delegate = nil;
    [super dealloc];
}

@end
