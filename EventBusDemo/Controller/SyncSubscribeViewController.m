//
//  SyncSubscribeViewController.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-2-21.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "SyncSubscribeViewController.h"
#import "AsyncPublishViewController.h"
#import "SyncPublishViewController.h"
#import "SubscribeCell.h"
@interface SyncSubscribeViewController ()<EventSyncSubscriber>
{
    IBOutlet UITableView *_tableView;
    IBOutlet UITextField *_textfield;
    NSMutableArray * _list;
}
@end

@implementation SyncSubscribeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 7) self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem * syncPublishItem = [[UIBarButtonItem alloc] initWithTitle:@"产生同步事件" style:UIBarButtonItemStylePlain target:self action:@selector(syncPublish)];
    self.navigationItem.rightBarButtonItem = syncPublishItem;
    [syncPublishItem release];
    _list = [[NSMutableArray array] retain];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SubscribeCell class]) bundle:nil] forCellReuseIdentifier:SubscribeCellId];
}

- (void)asyncPublish
{
    AsyncPublishViewController * publishViewController = [[AsyncPublishViewController alloc] init];
    [self.navigationController pushViewController:publishViewController animated:YES];
    [publishViewController release];
}

- (void)syncPublish
{
    SyncPublishViewController * publishViewController = [[SyncPublishViewController alloc] init];
    [self.navigationController pushViewController:publishViewController animated:YES];
    [publishViewController release];
}

#pragma mark -----------------   tableview datasouce & delegate   ----------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SubscribeCell heightForData:_list[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubscribeCell * cell = [tableView dequeueReusableCellWithIdentifier:SubscribeCellId];
    [cell setData:_list[indexPath.row]];
    return cell;
}

- (IBAction)subscribeButtonPressed:(id)sender {
    if(_textfield.text.length > 0){
        NSLog(@"SyncSubscribe   subscribe  -------->  %@",_textfield.text);
        EVENT_SUBSCRIBE(self, _textfield.text);
        _textfield.text = @"";
    }
}

- (void)eventOccurred:(NSString *)eventName event:(Event *)event
{
    NSLog(@"SyncSubscribe   received  -------->  %@",eventName);
    NSDictionary * data = @{
                            @"eventName" : eventName,
                            @"life" : [NSString stringWithFormat:@"%d",event.life],
                            };
    [_list addObject:data];
    [_tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_textfield resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    for (NSDictionary * event in _list) {
        EVENT_UNSUBSCRIBE(self, event[@"eventName"]);
    }
    [_list release];
    [_tableView release];
    [_textfield release];
    [super dealloc];
}
@end









