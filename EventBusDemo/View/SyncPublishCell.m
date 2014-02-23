//
//  SyncPublishCell.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-2-21.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "SyncPublishCell.h"
NSString * const SyncPublishCellId = @"SyncPublishCellId";
@interface SyncPublishCell()
{
    IBOutlet UILabel *_eventNameLabel;
    
}
@end

@implementation SyncPublishCell

- (void)setData: (NSDictionary *)data
{
    _eventNameLabel.text = data[@"eventName"];
}

+ (CGFloat)heightForData:(NSDictionary *)data
{
    return 44.0f;
}

- (void)dealloc {
    [_eventNameLabel release];
    [super dealloc];
}
@end
