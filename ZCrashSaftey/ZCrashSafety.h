//
//  ZCrashSafety.h
//  ZCrashSaftey
//
//  Created by icharge on 2018/11/12.
//  Copyright © 2018年 icharge. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 参考了YCBStability
Debug模式:依旧会Crash，但是我们加入了日志，方便追踪Crash信息

Release模式:我们将返回一个nil，防止Crash
*/
@interface ZCrashSafety : NSObject
/** 判断是否是非空:count+class */
+ (BOOL)isArray:(id)object;

+ (BOOL)isSet:(id)object;

+ (BOOL)isString:(id)text;

+ (BOOL)isDictionary:(id)object;
@end

@interface NSDictionary (ZCrashSafety)

- (NSString *)getStringForKey:(id)key;

- (NSArray *)getArrayForKey:(id)key;

- (NSDictionary *)getDictinaryForKey:(id)key;

- (int)getIntForKey:(id)key;

- (float)getFloatForKey:(id)key;

- (BOOL)getBoolForKey:(id)key;

@end
