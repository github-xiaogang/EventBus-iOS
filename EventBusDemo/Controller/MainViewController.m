//
//  MainViewController.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-4-25.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "MainViewController.h"
#import "EventView.h"
#import "AsyncSubscribeViewController.h"
#import "SyncSubscribeViewController.h"
#import "AsyncPublishViewController.h"
#import "SyncPublishViewController.h"

static  const int EVENT_COUNT = 20;
static  const int EVENTVIEW_TAG = 100;
static  CGFloat const ITEM_WIDTH = 136.0f;
static  CGFloat const ITEM_HEIGHT = 88.0f;
NSString * const EventBusUpdateNotification = @"EventBusUpdateNotification";
NSString * const EventBusItemSelectedNotification = @"EventBusItemSelectedNotification";

@interface MainViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate,EventViewDelegate>
{
    IBOutlet UIPageViewController *_pageViewController;
    IBOutlet UIView *_pageControlLayout;
    IBOutlet UIView *_eventBusLayout;
    IBOutlet UIScrollView *_eventScrollView;
    NSArray * _viewControllers;
    IBOutlet UILabel *_busLabel;
    IBOutlet ConsoleTextView *_textview;
    
}
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UISwipeGestureRecognizer * swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recoverUI)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];
    //async subscribe
    AsyncSubscribeViewController * asyncSubscribeVC = [[[AsyncSubscribeViewController alloc] init] autorelease];
    UINavigationController * asyncSubscribeNavigationC = [[[UINavigationController alloc] initWithRootViewController:asyncSubscribeVC] autorelease];
    asyncSubscribeNavigationC.navigationBarHidden = YES;
    //async publish
    AsyncPublishViewController * asyncPublishVC = [[AsyncPublishViewController alloc] init];
    //sync subscribe
    SyncSubscribeViewController * syncSubscribeVC = [[SyncSubscribeViewController alloc] init];
    //sync publish
    SyncPublishViewController * syncPublishVC = [[SyncPublishViewController alloc] init];
    _viewControllers = [@[asyncSubscribeNavigationC,asyncPublishVC,syncSubscribeVC,syncPublishVC] retain];
    [_pageViewController setViewControllers:@[_viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:0];
    _pageViewController.view.left = 0;
    _pageViewController.view.top = 0;
    _pageViewController.view.width = _pageControlLayout.width;
    _pageViewController.view.height = _pageControlLayout.height;
    [self addChildViewController:_pageViewController];
    [_pageControlLayout addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    [self loadOtherUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDismiss) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventBusUI) name: EventBusUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventBusLog:) name:EventBusLogNotification object:nil];
}

- (void)loadOtherUI
{
    for (int i=0; i<EVENT_COUNT; i++) {
        EventView * eventView = [EventView newInstance];
        eventView.tag = EVENTVIEW_TAG + i;
        eventView.top = 0;
        eventView.left = i * eventView.width;
        eventView.No = i+1;
        eventView.delegate = self;
        [_eventScrollView addSubview:eventView];
        [eventView release];
    }
    [_eventScrollView setContentSize:CGSizeMake(EVENT_COUNT * ITEM_WIDTH, ITEM_HEIGHT)];
    _busLabel.text = [NSString stringWithFormat:@"事件总线(%d / %d)",0,EVENT_COUNT];
}

- (void)updateEventBusUI
{
    NSArray * events = [[EventBus busManager] allEvent];
    for (int i=0; i<events.count; i++) {
        EventView * eventView = (EventView *)[_eventScrollView viewWithTag:EVENTVIEW_TAG+i];
        Event * event = events[i];
        [eventView setData:event];
    }
    _busLabel.text = [NSString stringWithFormat:@"事件总线(%d / %d)",events.count,EVENT_COUNT];
}

#pragma mark -----------------   event view delegate   ----------------

- (void)eventViewSelected: (EventView *)eventView
{
    int index = eventView.tag - EVENTVIEW_TAG;
    NSArray * events = [[EventBus busManager] allEvent];
    Event * event = events[index];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventBusItemSelectedNotification object:nil userInfo:@{@"eventName" : event.eventName}];
}


#pragma mark -----------------   page view controller delegate   ----------------
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int currentIndex = [_viewControllers indexOfObject:viewController];
    if(currentIndex == 0) return nil;
    else return _viewControllers[currentIndex-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int currentIndex = [_viewControllers indexOfObject:viewController];
    if(currentIndex == 3) return nil;
    else return _viewControllers[currentIndex+1];
}

#pragma mark -----------------   UI   ----------------

- (void)keyboardWillShow
{
    [UIView animateWithDuration:0.25 animations:^{
        _eventBusLayout.top = 96.0f;
    }];
    NSArray * events = [[EventBus busManager] allEvent];
    for (int i=0; i<events.count; i++) {
        EventView * eventView = (EventView *)[_eventScrollView viewWithTag:EVENTVIEW_TAG+i];
        [eventView setActionAble:YES];
    }
}

- (void)keyboardWillDismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        _eventBusLayout.top = 290.0f;
    }];
    NSArray * events = [[EventBus busManager] allEvent];
    for (int i=0; i<events.count; i++) {
        EventView * eventView = (EventView *)[_eventScrollView viewWithTag:EVENTVIEW_TAG+i];
        [eventView setActionAble:NO];
    }
}

- (void)eventBusLog : (NSNotification *)notification
{
    [_textview log:notification.userInfo[EventBusLogUserInfoKey]];
}

-(void) recoverUI
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_viewControllers release];
    [_pageViewController release];
    [_pageControlLayout release];
    [_eventScrollView release];
    [_eventBusLayout release];
    [_busLabel release];
    [_textview release];
    [super dealloc];
}
@end







