//
//  ObjCUtil.h
//  ShiShangQuan
//
//  Created by 张 小刚 on 13-9-5.
//  Copyright (c) 2013年 duohuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjCUtil : NSObject

//是否是Array或Dictionary
+ (BOOL)isContainer: (id)obj;
//将NSArray 变为 NSMutableArray  将NSDictionary 变为NSMutableDictionary
+ (id)mutableContainerObject: (id)rawObj;
//[NSNull null] & NSNumber obj -----> String
+ (id)filterNullAndNumberToString: (id)rawObj;
/**
 * 把数组中的对象用separator连接起来
 */
+ (NSString *)stringByConnectArrayComponents: (NSArray *)array UsingSeparator: (NSString *)separator;
+ (NSString *)stringByConnectDictionryArrayComponents: (NSArray *)array componentByKey: (NSString *)key UsingSeparator: (NSString *)separator;

//url encode & decode
+ (NSString *)encodeStringUsingPercentEscape: (NSString *)string;
+ (NSString *) decodeFromPercentEscapeString:(NSString *)string;

//map
+ (NSDictionary *)mapKey: (NSString *)newKey forKey: (NSString *)oldKey inDictionary: (NSDictionary *)originDictionary;
+ (NSDictionary *)mapKeys: (NSArray *)newKeys forKeys: (NSArray *)oldKeys inDictionary: (NSDictionary *)originDictionary;
+ (NSArray *)mapKey: (NSString *)newKey forKey: (NSString *)oldKey inDictionaryArray: (NSArray *)dicArray;
+ (NSArray *)mapKeys: (NSArray *)newKeys forKeys: (NSArray *)oldKeys inDictionaryArray: (NSArray *)dicArray;
//将一个数组分割成
+ (NSArray *)splitArray: (NSArray *)list intoPart: (int)part;
//md5
+ (NSString *)md5:(NSString*)input;

@end
