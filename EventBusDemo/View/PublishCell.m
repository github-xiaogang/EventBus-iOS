//
//  PublishCell.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-2-21.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "PublishCell.h"
NSString * const PublishCellId = @"PublishCellId";
@interface PublishCell()
{
    IBOutlet UILabel *_eventNameLabel;
    IBOutlet UILabel *_eventLifeLabel;
}
@end

@implementation PublishCell

- (void)setData: (NSDictionary *)data
{
    _eventNameLabel.text = data[@"eventName"];
    _eventLifeLabel.text = [NSString stringWithFormat:@"%d",[data[@"life"] intValue]];
}

+ (CGFloat)heightForData:(NSDictionary *)data
{
    return 67.0f;
}

- (void)dealloc {
    [_eventNameLabel release];
    [_eventLifeLabel release];
    [super dealloc];
}
@end
