//
//  AsyncPublishViewController.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-4-25.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "AsyncPublishViewController.h"
#import "MainViewController.h"

@interface AsyncPublishViewController ()<EventAsyncPublisher>
{
    IBOutlet UITextField *_textfield;
    IBOutlet ConsoleTextView *_textView;
}
@end

@implementation AsyncPublishViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)publishButtonPressed:(id)sender {
    if(_textfield.text.length == 0) return;
     EVENT_PUBLISH(self, _textfield.text);
    [_textfield resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventBusUpdateNotification object:nil];
    
    NSString * message = [NSString stringWithFormat:@"Publish ----->  %@",_textfield.text];
    [_textView log:message];
    
    _textfield.text = @"";
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
