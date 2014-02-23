//
//  SyncPublishViewController.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-2-21.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "SyncPublishViewController.h"
#import "SyncPublishCell.h"

@interface SyncPublishViewController ()<EventSyncPublisher>
{
    IBOutlet UITextField *_textfield;
    IBOutlet UITableView *_tableView;
    NSMutableArray * _list;
}
@end

@implementation SyncPublishViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 7) self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view from its nib.
    _list = [[NSMutableArray array] retain];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SyncPublishCell class]) bundle:nil] forCellReuseIdentifier:SyncPublishCellId];
}

#pragma mark -----------------   tableview datasouce & delegate   ----------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SyncPublishCell heightForData:_list[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SyncPublishCell * cell = [tableView dequeueReusableCellWithIdentifier:SyncPublishCellId];
    [cell setData:@{
                    @"eventName" : _list[indexPath.row],
                    }];
    return cell;
}

- (IBAction)sendButtonPressed:(id)sender {
    if(_textfield.text.length == 0){
        [_textfield becomeFirstResponder];
    }else{
        EVENT_PUBLISH(self, _textfield.text);
        [_list addObject:_textfield.text];
        [_textfield resignFirstResponder];
        _textfield.text = @"";
        [_tableView reloadData];
    }
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
    [_list release];
    [_textfield release];
    [_tableView release];
    [super dealloc];
}
@end






