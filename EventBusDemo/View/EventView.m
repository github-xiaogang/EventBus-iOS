//
//  EventView.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-4-25.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "EventView.h"
@interface EventView()
{
    IBOutlet UILabel *_eventNameLabel;
    IBOutlet UILabel *_lifeLabel;
    IBOutlet UILabel *_NoLabel;
    IBOutlet UIView *_actionLayout;
}
@end

@implementation EventView

- (void)setData: (id)data
{
    Event * event = (Event *)data;
    _eventNameLabel.text = event.eventName;
    _lifeLabel.text = [NSString stringWithFormat:@"%d",event.life];
}

- (void)setNo:(int)No
{
    _No = No;
    _NoLabel.text = [NSString stringWithFormat:@"%d",_No];
}

- (void)setActionAble:(BOOL)actionAble
{
    _actionAble = actionAble;
    _actionLayout.hidden = !actionAble;
}

- (IBAction)contentButtonPressed:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(eventViewSelected:)]){
        [_delegate eventViewSelected:self];
    }
}

+ (EventView *)newInstance
{
    return [[[NSBundle mainBundle] loadNibNamed:@"EventView" owner:nil options:nil][0] retain];
}

- (void)dealloc {
    [_eventNameLabel release];
    [_lifeLabel release];
    [_NoLabel release];
    [_actionLayout release];
    [super dealloc];
}
@end
