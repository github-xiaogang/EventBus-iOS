//
//  GeneralTableCell.h
//  ShiShangQuan
//
//  Created by 张 小刚 on 13-9-9.
//  Copyright (c) 2013年 duohuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralTableCell : UITableViewCell

- (void)setData: (id)data;
+ (CGFloat)heightForData: (id)data;

@end


@protocol GeneralTableCellDelegate <NSObject>
@optional
- (void)faceImagePressedForCell: (GeneralTableCell *)cell;
- (void)deleteRequestForCell: (GeneralTableCell *)cell;
@end
