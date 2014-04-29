//
//  AsyncSubscribeViewController.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-4-25.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "AsyncSubscribeViewController.h"
#import "MainViewController.h"

NSString * const SEPARATOR = @";";

@interface AsyncSubscribeViewController ()<EventAsyncSubscriber>
{
    IBOutlet UITextField *_textfield;
    IBOutlet UISegmentedControl *_segmentControl;
    IBOutlet ConsoleTextView *_textView;
    IBOutlet UILabel *_titleLabel;
}
@end

@implementation AsyncSubscribeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray * viewControllers = self.navigationController.viewControllers;
    int index = [viewControllers indexOfObject:self];
    _titleLabel.text = [NSString stringWithFormat:@"%@(%d)",_titleLabel.text,index+1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventItemSelected:) name:EventBusItemSelectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldDidEndEdit) name:UITextFieldTextDidEndEditingNotification object:_textfield];
}

- (void)eventItemSelected: (NSNotification *)notification
{
    NSString * eventName = notification.userInfo[@"eventName"];
    if(eventName.length > 0){
        if(_textfield.text.length > 0){
            NSArray * components = [_textfield.text componentsSeparatedByString:SEPARATOR];
            if(components == 0) components = @[];
            NSMutableArray * eventNames = [NSMutableArray arrayWithArray: components];
            NSMutableArray * objsToRemove = [NSMutableArray array];
            for (NSString * aName in eventNames) {
                if([aName isEqualToString:eventName]){
                    [objsToRemove addObject:aName];
                }
            }
            [eventNames removeObjectsInArray:objsToRemove];
            [eventNames addObject:eventName];
            NSString * result = [ObjCUtil stringByConnectArrayComponents:eventNames UsingSeparator:SEPARATOR];
            _textfield.text = result;
        }else{
            _textfield.text = eventName;
        }
    }
}

- (void)textfieldDidEndEdit
{
    NSArray * components = [_textfield.text componentsSeparatedByString:SEPARATOR];
    if(components.count > 1){
        _textView.top = 76 + 42.0f;
        _textView.height = 190 - 42.0f;
    }else{
        _textView.top = 76.0f;
        _textView.height = 190.0f;
    }
}

#pragma mark -----------------   EventBus delegate   ----------------
- (void)eventOccurred:(NSString *)eventName event:(Event *)event
{
    NSString * message = [NSString stringWithFormat:@"Received ----->  %@",eventName];
    [_textView log:message];
}

- (void)eventsOccurred:(NSArray *)eventNames event:(NSArray *)events
{
    NSString * text = [NSString stringWithFormat:@"Received ----->  { %@ }",[ObjCUtil stringByConnectArrayComponents:eventNames UsingSeparator:@","]];
    [_textView log:text];
    NSMutableArray * firedEventNames = [NSMutableArray arrayWithCapacity:events.count];
    for (Event * event in events) {
        [firedEventNames addObject:event.eventName];
    }
    [_textView log:[NSString stringWithFormat:@"cause received  ----->  [ %@ ]",[ObjCUtil stringByConnectArrayComponents:firedEventNames UsingSeparator:@","]]];
}

- (IBAction)subscribeButtonPressed:(id)sender {
    if(_textfield.text.length == 0) return;
    EVENT_SUBSCRIBE(self, _textfield.text);
    [_textfield resignFirstResponder];
    NSString * message = [NSString stringWithFormat:@"Subscribe ----->  %@",_textfield.text];
    [_textView log:message];
    _textfield.text = @"";
}

- (IBAction)checkButtonPressed:(id)sender {
    if(_textfield.text.length == 0) return;
    NSString * message = nil;
    NSArray * eventNames = [_textfield.text componentsSeparatedByString:SEPARATOR];
    if(eventNames.count == 1){
        message = [NSString stringWithFormat:@"Check ----->  %@",_textfield.text];
        [_textView log:message];
        EVENT_CHECK(self, _textfield.text);
    }else if(eventNames.count > 1){
        NSString * separator = _segmentControl.selectedSegmentIndex == 0 ? @" | " : @" & ";
        message = [ObjCUtil stringByConnectArrayComponents:eventNames UsingSeparator:separator];
        message = [NSString stringWithFormat:@"Check ----->  %@",message];
        [_textView log:message];
        if(_segmentControl.selectedSegmentIndex == 0){
            EVENT_CHECK_ANY(self, eventNames);
        }else{
            EVENT_CHECK_ALL(self, eventNames);
        }
    }
    [_textfield resignFirstResponder];
    
    _textfield.text = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:EventBusUpdateNotification object:nil];
}

- (IBAction)preInstanceButtonPressed:(id)sender {
    NSArray * viewControllers = self.navigationController.viewControllers;
    int index = [viewControllers indexOfObject:self];
    if(index != 0){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)nextInstanceButtonPressed:(id)sender {
    NSArray * viewControllers = self.navigationController.viewControllers;
    int index = [viewControllers indexOfObject:self];
    if(index != viewControllers.count - 1){
        [self.navigationController pushViewController:viewControllers[index + 1] animated:YES];
    }else{
        AsyncSubscribeViewController * subscribeViewController = [[AsyncSubscribeViewController alloc] init];
        [self.navigationController pushViewController:subscribeViewController animated:YES];
        [subscribeViewController release];
    }
}

#pragma mark -----------------   util   ----------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_textfield release];
    [_segmentControl release];
    [_textView release];
    [_titleLabel release];
    [super dealloc];
}
@end




















