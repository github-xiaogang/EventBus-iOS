//
//  MainViewController.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-2-23.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "MainViewController.h"
#import "AsyncSubscribeViewController.h"
#import "SyncSubscribeViewController.h"
#import "AsyncPublishViewController.h"
#import "SyncPublishViewController.h"

@interface MainViewController ()
{
    IBOutlet UITableView *_tableView;
    NSArray * _list;
}
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 7) self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view from its nib.
    _list = [@[
               @"Async Subscriber",
               @"Sync Subscriber",
               @"Async Publisher",
               ] copy];
}

#pragma mark -----------------   tableview datasouce & delegate   ----------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellId = @"CellId";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId] autorelease];
    }
    cell.textLabel.text = _list[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController * targetViewController = nil;
    switch (indexPath.row) {
        case 0:
            targetViewController = [[[AsyncSubscribeViewController alloc] init] autorelease];
            break;
        case 1:
            targetViewController = [[[SyncSubscribeViewController alloc] init] autorelease];
            break;
        case 2:
            targetViewController = [[[AsyncPublishViewController alloc] init] autorelease];
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:targetViewController animated:YES];
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_list release];
    [_tableView release];
    [super dealloc];
}
@end
