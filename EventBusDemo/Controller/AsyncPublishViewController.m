//
//  PublishViewController.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-2-21.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "AsyncPublishViewController.h"
#import "AsyncSubscribeViewController.h"
#import "PublishCell.h"

@interface AsyncPublishViewController ()<EventAsyncPublisher,UITableViewDelegate>
{
    IBOutlet UITableView *_tableView;
    NSMutableArray * _list;
    IBOutlet UITextField *_textfield;
}
@end

@implementation AsyncPublishViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 7) self.automaticallyAdjustsScrollViewInsets = NO;
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PublishCell class]) bundle:nil] forCellReuseIdentifier:PublishCellId];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem * asyncSubscrbeItem = [[UIBarButtonItem alloc] initWithTitle:@"订阅异步事件" style:UIBarButtonItemStylePlain target:self  action:@selector(asyncSubscribe)];
    self.navigationItem.rightBarButtonItem = asyncSubscrbeItem;
    [asyncSubscrbeItem release];
    _list = [[NSMutableArray array] retain];
}


- (void)asyncSubscribe
{
    AsyncSubscribeViewController * subscribViewController = [[AsyncSubscribeViewController alloc] init];
    [self.navigationController pushViewController:subscribViewController animated:YES];
    [subscribViewController release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

#pragma mark -----------------   tableview datasouce & delegate   ----------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PublishCell heightForData:_list[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PublishCell * cell = [tableView dequeueReusableCellWithIdentifier:PublishCellId];
    NSString * eventName = _list[indexPath.row];
    Event * event = [[EventBus busManager] event:eventName];
    if(!event){
        [cell setData:@{
                       @"eventName" : eventName,
                       @"life" : @"0",
                           }];
    }else{
        [cell setData:@{
                        @"eventName" : event.eventName,
                        @"life" : [NSString stringWithFormat:@"%d",event.life],
                        }];
    }
    return cell;
}

- (IBAction)sendButtonPressed:(id)sender {
    if(_textfield.text.length == 0){
        [_textfield becomeFirstResponder];
    }else{
//        EVENT_PUBLISH(self, _textfield.text);
        EVENT_PUBLISH_WITHDATA(self, _textfield.text, @"hehehe");
        BOOL exists = NO;
        NSString * targetEvent = nil;
        for (NSString * eventName in _list) {
            if([eventName isEqualToString:_textfield.text]){
                targetEvent = eventName;
                exists = YES;
                break;
            }
        }
        if(exists){
            [_list removeObject:targetEvent];
        }
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
    [_tableView release];
    [_textfield release];
    [super dealloc];
}
@end





