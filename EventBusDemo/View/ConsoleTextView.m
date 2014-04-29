//
//  ConsoleTextView.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-4-25.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "ConsoleTextView.h"

@implementation ConsoleTextView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UILongPressGestureRecognizer * deleteGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(clearLog)];
    [self addGestureRecognizer:deleteGesture];
    [deleteGesture release];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    //scroll to bottom
    if(self.text.length > 0){
        NSRange range;
        range.location = text.length - 1;
        range.length = 1;
        [self scrollRangeToVisible:range];
    }
}

- (void)log: (NSString *)message
{
    self.text = [NSString stringWithFormat:@"%@%@\n",self.text,message];
}

- (void)clearLog
{
    self.text = @"";
}

@end









