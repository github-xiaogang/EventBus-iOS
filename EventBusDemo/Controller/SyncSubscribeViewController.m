//
//  SyncSubscribeViewController.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-4-25.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "SyncSubscribeViewController.h"
#import "MainViewController.h"

@interface SyncSubscribeViewController ()<EventSyncSubscriber>
{
    IBOutlet UITextField *_textfield;
    IBOutlet ConsoleTextView *_textView;
    
}
@end

@implementation SyncSubscribeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)subscribeButtonPressed:(id)sender {
    if(_textfield.text.length == 0) return;
    NSString * message = [NSString stringWithFormat:@"Subscribe ----->  %@",_textfield.text];
    [_textView log:message];
    EVENT_SUBSCRIBE(self, _textfield.text);
    [_textfield resignFirstResponder];
    
    _textfield.text = @"";
}

#pragma mark -----------------   EventBus delegate   ----------------
- (void)eventOccurred:(NSString *)eventName event:(Event *)event
{
    NSString * message = [NSString stringWithFormat:@"Received ----->  %@",eventName];
    [_textView log:message];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_textfield release];
    [_textView release];
    [super dealloc];
}
@end
