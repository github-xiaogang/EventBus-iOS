//
//  ObjCUtil.m
//  ShiShangQuan
//
//  Created by 张 小刚 on 13-9-5.
//  Copyright (c) 2013年 duohuo. All rights reserved.
//

#import "ObjCUtil.h"

@implementation ObjCUtil
//是否是Array或Dictionary
+ (BOOL)isContainer: (id)obj
{
    return [obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]];
}
//将NSArray 变为 NSMutableArray  将NSDictionary 变为NSMutableDictionary
+ (id)mutableContainerObject: (id)rawObj
{
    id result = nil;
    //数组
    if ([rawObj isKindOfClass:[NSArray class]]) {
        NSMutableArray * mutableArray = [NSMutableArray array];
        NSArray * array = (NSArray *)rawObj;
        for (int i=0; i<array.count; i++) {
            id anObj = array[i];
            if([self isContainer:anObj]){
                [mutableArray addObject:[self mutableContainerObject:anObj]];
            }else{
                [mutableArray addObject:anObj];
            }
        }
        result = mutableArray;
    }else if([rawObj isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionary];
        NSDictionary * dictionary = (NSDictionary *)rawObj;
        NSArray * keys = [dictionary allKeys];
        for (int i=0; i<keys.count; i++) {
            NSString * key = keys[i];
            id anObj = dictionary[key];
            if([self isContainer:anObj]){
                mutableDictionary[key] = [self mutableContainerObject:anObj];
            }else{
                mutableDictionary[key] = anObj;
            }
        }
        result = mutableDictionary;
    }else{
        result = rawObj;
    }
    return result;
}
//[NSNull null]  -----> String
+ (id)filterNullAndNumberToString: (id)rawObj
{
    NSAssert(!rawObj || [rawObj isKindOfClass:[NSMutableArray class]] ||[rawObj isKindOfClass:[NSMutableDictionary class]], @"APIConnection Filter Json Error");
    if(![self isContainer:rawObj]) return nil;
    if([rawObj isKindOfClass:[NSArray class]]){
        NSMutableArray * array = (NSMutableArray *)rawObj;
        for (int i=0; i<array.count; i++) {
            id anObj = array[i];
            if(![self isContainer:anObj]){
                if([anObj isKindOfClass:[NSNull class]]){
                    array[i] = @"";
                }else if([anObj isKindOfClass:[NSNumber class]]){
                    array[i] = [array[i] stringValue];
                }
            }else{
                [self filterNullAndNumberToString:anObj];
            }
        }
    }else if([rawObj isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary * dictionary = (NSMutableDictionary *)rawObj;
        NSArray * keys = [dictionary allKeys];
        for (int i=0; i<keys.count; i++) {
            NSString * key = keys[i];
            id value = dictionary[key];
            if([self isContainer:value]){
                [self filterNullAndNumberToString:value];
            }else{
                if([value isKindOfClass:[NSNull class]])
                    dictionary[key] = @"";
                else if([value isKindOfClass:[NSNumber class]]){
                    dictionary[key] = [value stringValue];
                }
            }
        }
    }
    return rawObj;
}

+ (NSString *)stringByConnectArrayComponents: (NSArray *)array UsingSeparator: (NSString *)separator
{
    NSAssert([separator isKindOfClass:[NSString class]], @"separator not string");
    NSAssert([array isKindOfClass:[NSArray class]] || (array == nil), @"array not array");
    if(array.count == 0) return nil;
    NSMutableString * mutableString = [NSMutableString string];
    if(array.count > 0){
        [mutableString appendFormat:@"%@",array[0]];
    }
    if(array.count > 1){
        for (int i=1; i<array.count; i++) {
            [mutableString appendFormat:@"%@%@",separator,array[i]];
        }
    }
    if(mutableString.length == 0) mutableString = nil;
    return mutableString;
}

+ (NSString *)stringByConnectDictionryArrayComponents: (NSArray *)array componentByKey: (NSString *)key UsingSeparator: (NSString *)separator
{
    NSAssert([separator isKindOfClass:[NSString class]], @"separator not string");
    NSAssert([array isKindOfClass:[NSArray class]] || (array == nil), @"array not array");
    NSMutableArray * componentsArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary * dictionary in array) {
        NSAssert([dictionary isKindOfClass:[NSDictionary class]], @"");
        NSAssert(dictionary[key], @"");
        [componentsArray addObject:dictionary[key]];
    }
    return [self stringByConnectArrayComponents:componentsArray UsingSeparator:separator];
}



+ (NSString *)encodeStringUsingPercentEscape: (NSString *)string{
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// Decode a percent escape encoded string.
+ (NSString* ) decodeFromPercentEscapeString:(NSString *)string {
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         (__bridge CFStringRef) string,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
}

//map
+ (NSDictionary *)mapKey: (NSString *)newKey forKey: (NSString *)oldKey inDictionary: (NSDictionary *)originDictionary
{
    return [self mapKeys:@[newKey] forKeys:@[oldKey] inDictionary:originDictionary];
}

+ (NSArray *)mapKey: (NSString *)newKey forKey: (NSString *)oldKey inDictionaryArray: (NSArray *)dicArray
{
    return [self mapKeys:@[newKey] forKeys:@[oldKey] inDictionaryArray:dicArray];
}

+ (NSArray *)mapKeys: (NSArray *)newKeys forKeys: (NSArray *)oldKeys inDictionaryArray: (NSArray *)dicArray
{
    if(([dicArray isKindOfClass:[NSArray class]] && dicArray.count == 0) || (dicArray == nil)) return dicArray;
    NSAssert([dicArray isKindOfClass:[NSArray class]], @"");
    for (NSDictionary * dictionary in dicArray) {
        NSAssert([dictionary isKindOfClass:[NSDictionary class]], @"");
    }
    NSMutableArray * mutableArray = [NSMutableArray arrayWithCapacity:dicArray.count];
    for (NSDictionary * dictionary  in dicArray) {
        [mutableArray addObject:[self mapKeys:newKeys forKeys:oldKeys inDictionary:dictionary]];
    }
    return mutableArray;
}

+ (NSDictionary *)mapKeys: (NSArray *)newKeys forKeys: (NSArray *)oldKeys inDictionary: (NSDictionary *)originDictionary
{
    NSAssert([originDictionary isKindOfClass:[NSDictionary class]], @"");
    NSAssert([newKeys isKindOfClass:[NSArray class]], @"");
    NSAssert([oldKeys isKindOfClass:[NSArray class]], @"");
    NSAssert(newKeys.count == oldKeys.count, @"");
    for (int i=0; i<newKeys.count; i++) {
        NSAssert([newKeys[i] isKindOfClass:[NSString class]], @"");
        NSAssert([oldKeys[i] isKindOfClass:[NSString class]], @"");
    }
    NSMutableDictionary * mutableData = [originDictionary mutableCopy];
    for (int i=0; i<newKeys.count; i++) {
        mutableData[newKeys[i]] = mutableData[oldKeys[i]];
    }
    return [mutableData autorelease];
}

+ (NSArray *)splitArray: (NSArray *)list intoPart: (int)part
{
    NSAssert(part > 1, @"");
    int capacity = list.count / part;
    if(capacity == 0 && list.count > 0) capacity = 1;
    NSMutableArray * resultList = [NSMutableArray arrayWithCapacity:capacity];
    for (int i=0; i<capacity; i++) {
        NSMutableArray * aList = [NSMutableArray array];
        for (int j=0; j<part; j++) {
            int index = i * part + j;
            if(list.count -1 >= index){
                aList[j] = list[index];
            }
        }
        [resultList addObject:aList];
    }
    if(resultList.count == 0) resultList = nil;
    return resultList;
}


#import <CommonCrypto/CommonDigest.h>
+ (NSString *)md5:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return ret;
}

@end












