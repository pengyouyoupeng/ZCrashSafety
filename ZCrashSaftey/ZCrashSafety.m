//
//  ZCrashSafety.m
//  ZCrashSaftey
//
//  Created by icharge on 2018/11/12.
//  Copyright © 2018年 icharge. All rights reserved.
//

#import "ZCrashSafety.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface YCBStabilityLogs : NSObject

+ (NSString *)crashReason:(NSString *)reson
                  release:(NSString *)releaseLog
                 otherLog:(NSString *)otherLog;

@end

@implementation YCBStabilityLogs

+ (NSString *)crashReason:(NSString *)reson
                  release:(NSString *)releaseLog
                 otherLog:(NSString *)otherLog
{
    NSMutableString *mutStr = [NSMutableString string];
    [mutStr appendString:@"\n \n/**NSAssert断言,Creash仅限于Debug模式\n"];
    [mutStr appendString:[NSString stringWithFormat:@"/**Crash原因:%@ \n",reson]];
    [mutStr appendString:[NSString stringWithFormat:@"/**Release模式下:%@ \n",releaseLog]];
    
    if ([ZCrashSafety isString:otherLog]) {
        [mutStr appendString:[NSString stringWithFormat:@"/**其它:%@ \n",otherLog]];
    }
    
    return (NSString *)mutStr;
}

@end

////////////////////////////////////////////////////////////////

@implementation ZCrashSafety

+ (BOOL)isArray:(id)object
{
    return [object isKindOfClass:[NSArray class]] && [(NSArray*)object count] > 0;
}

+ (BOOL)isSet:(id)object
{
    
    return [object isKindOfClass:[NSSet class]] && [(NSSet*)object count] > 0;
}

+ (BOOL)isString:(id)text
{
    return [text isKindOfClass:[NSString class]] && [(NSString*)text length] > 0;
}

+ (BOOL)isDictionary:(id)object
{
    return [object isKindOfClass:[NSDictionary class]] && [(NSDictionary *)object count] >0;
}

@end

////////////////////////////////////////////////////////////////

@interface NSArray (YCBStability)
@end

@implementation NSArray (YCBStability)

+ (void)load
{
    array_method_exchangeClass(objc_getClass("__NSArrayI"));
    array_method_exchangeCreateClass(objc_getClass("__NSPlaceholderArray"));
}
void array_method_exchangeCreateClass(Class cls){
    array_method_exchangeImplementations(cls, @selector(initWithObjects:count:), @selector(safeInitWithObjects:count:));
}

// arrayWithObjects:count:
void array_method_exchangeClass(Class cls) {
    
    array_method_exchangeImplementations(cls,@selector(objectAtIndex:), @selector(safeObjectAtIndex:));
    array_method_exchangeImplementations(cls,@selector(indexOfObject:), @selector(safeIndexOfObject:));
    array_method_exchangeImplementations(cls, @selector(objectAtIndexedSubscript:), @selector(safeObjectAtIndexedSubscript:));
    
    
}
// 这个方法主要用于创建数组的时候，去除数组中的空值
- (instancetype)safeInitWithObjects:(const id [])objects count:(NSUInteger)cnt{
    id safeObject[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i<cnt; i++) {
        id value = objects[i];
        NSAssert((value), ([YCBStabilityLogs crashReason:@"数组中存在空值"
                                                 release:@"新的数组中已经去除改空值"
                                                otherLog:[NSString stringWithFormat:@"数组为空值的元素下标为%lu",(unsigned long)i]]));
        if (!value) {
            continue;
        }
        safeObject[j] = value;
        j++;
    }
    return [self safeInitWithObjects:safeObject count:j];
    
}

- (id)safeObjectAtIndexedSubscript:(NSUInteger)index{
    NSAssert((index < self.count),([YCBStabilityLogs crashReason:@"数组越界"
                                                         release:@"返回nil"
                                                        otherLog:[NSString stringWithFormat:@"数组Count:%@ 参数下标index:%@",@(self.count),@(index)]]));
    if (index < self.count){
        return [self safeObjectAtIndex:index];
    }else{
        return nil;
    }
    
}

void array_method_exchangeImplementations(Class cls, SEL name, SEL name2) {
    
    Method fromMethod = class_getInstanceMethod(cls, name);
    Method toMethod = class_getInstanceMethod(cls, name2);
    method_exchangeImplementations(fromMethod, toMethod);
}
void array_method_exchangeClassImplementtations(Class cls, SEL name, SEL name2) {
    Method fromMethod = class_getClassMethod(cls, name);
    Method toMethod = class_getClassMethod(cls, name2);
    method_exchangeImplementations(fromMethod, toMethod);
}




- (NSUInteger)safeIndexOfObject:(id)anObject
{
    NSAssert((anObject && [self containsObject:anObject]),([YCBStabilityLogs crashReason:@"元素不存在"
                                                                                 release:@"返回0"
                                                                                otherLog:nil]));
    if (anObject && [self containsObject:anObject]) {
        return [self safeIndexOfObject:anObject];
    } else {
        return 0;
    }
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    NSAssert((index < self.count),([YCBStabilityLogs crashReason:@"数组越界"
                                                         release:@"返回nil"
                                                        otherLog:[NSString stringWithFormat:@"数组Count:%@ 参数下标index:%@",@(self.count),@(index)]]));
    if (index < self.count){
        return [self safeObjectAtIndex:index];
    }else{
        return nil;
    }
}

@end

///////////////////////////////////////////////////////////

@interface NSMutableArray (YCBStability)
@end

@implementation NSMutableArray (YCBStability)

+ (void)load
{
    mutArray_method_exchangeImplementations(@selector(addObject:), @selector(safeAddObject:));
    
    mutArray_method_exchangeImplementations(@selector(insertObject:atIndex:),@selector(safeInsertObject:atIndex:));
    
    mutArray_method_exchangeImplementations(@selector(removeObjectAtIndex:),@selector(safeRemoveObjectAtIndex:));
    mutArray_method_exchangeImplementations(@selector(setObject:atIndexedSubscript:), @selector(safeSetObject:atIndexedSubscript:));
}
- (void)safeSetObject:(id)anObject atIndexedSubscript:(NSUInteger)index{
    NSAssert((anObject), ([YCBStabilityLogs crashReason:@"被添加的元素不存在"
                                                release:@"不执行该方法"
                                               otherLog:nil]));
    
    if (anObject) {
        [self safeSetObject:anObject atIndexedSubscript:index];
    }
}

- (void)safeAddObject:(id)anObject
{
    NSAssert((anObject), ([YCBStabilityLogs crashReason:@"被添加的元素不存在"
                                                release:@"不执行该方法"
                                               otherLog:nil]));
    if (anObject) {
        [self safeAddObject:anObject];
    }
}

- (void)safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    NSAssert((anObject), ([YCBStabilityLogs crashReason:@"被添加的元素不存在"
                                                release:@"不执行该方法"
                                               otherLog:nil]));
    
    if (anObject) {
        [self safeInsertObject:anObject atIndex:index];
    }
}

- (void)safeRemoveObjectAtIndex:(NSUInteger)index
{
    NSAssert((index < self.count), ([YCBStabilityLogs crashReason:@"被移除的元素index越界"
                                                          release:@"不执行该方法"
                                                         otherLog:nil]));
    
    if (index < self.count) {
        [self safeRemoveObjectAtIndex:index];
    }
}

Class objc_NSMutArrayClass() {
    
    return objc_getClass("__NSArrayM");
}


void mutArray_method_exchangeImplementations(SEL name, SEL name2) {
    
    Method fromMethod = class_getInstanceMethod(objc_NSMutArrayClass(), name);
    Method toMethod = class_getInstanceMethod(objc_NSMutArrayClass(), name2);
    method_exchangeImplementations(fromMethod, toMethod);
}

@end

/////////////////////////////////////////////////////////////////////

@implementation NSDictionary (YCBStability)
+(void)load{
    dictionary_method_exchangeClass(self);
}

void dictionary_method_exchangeClass(Class cls){
    dictionary_method_exchangeInstanceImplementations(cls,@selector(initWithObjects:forKeys:count:),@selector(safeInitWithObjects:forKeys:count:));
    // 字面量初始化一个 dictionary 的时候，会调
    dictionary_method_exchangeClassImplementations(cls, @selector(dictionaryWithObjects:forKeys:count:), @selector(safeDictionaryWithObjects:forKeys:count:));
    
}


void dictionary_method_exchangeClassImplementations(Class class, SEL originalSEL, SEL replacementSEL)
{
    
    Method fromMethod =class_getClassMethod(class, originalSEL);
    Method toMethod=class_getClassMethod(class, replacementSEL);
    //进行方法调用
    method_exchangeImplementations(fromMethod, toMethod);
}



void dictionary_method_exchangeInstanceImplementations(Class cls,SEL name,SEL name2){
    Method fromMethod = class_getInstanceMethod(cls, name);
    Method toMethod = class_getInstanceMethod(cls, name2);
    if(class_addMethod(cls, name, method_getImplementation(toMethod),method_getTypeEncoding(toMethod)))
    {
        class_replaceMethod(cls,name2, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod));
    }else {
        method_exchangeImplementations(fromMethod, toMethod);
    }
}

// 该方法过滤掉了空值，注意字典中将会少nil键值对

+ (instancetype)safeDictionaryWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt{
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i<cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        
        NSAssert(([key isKindOfClass:[NSString class]] || [key isKindOfClass:[NSNumber class]]), ([YCBStabilityLogs crashReason:@"无法获取key类型"
                                                                                                                        release:@"返回@"""
                                                                                                                       otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                                                                                                                 NSStringFromClass([obj class])]]));
        NSAssert(([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]), ([YCBStabilityLogs crashReason:@"无法获取value类型"
                                                                                                                        release:@"返回@"""
                                                                                                                       otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                                                                                                                 NSStringFromClass([obj class])]]));
        
        
        if (!key||!obj) {
            continue;
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self safeDictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

// 该方法过滤掉了空值，注意字典中将会少少nil键值对
- (instancetype)safeInitWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt{
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i<cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        NSAssert(([key isKindOfClass:[NSString class]] || [key isKindOfClass:[NSNumber class]]), ([YCBStabilityLogs crashReason:@"无法获取key类型"
                                                                                                                        release:@"返回@"""
                                                                                                                       otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                                                                                                                 NSStringFromClass([obj class])]]));
        NSAssert(([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]), ([YCBStabilityLogs crashReason:@"无法获取value类型"
                                                                                                                        release:@"返回@"""
                                                                                                                       otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                                                                                                                 NSStringFromClass([obj class])]]));
        
        if (!key||!obj) {
            continue;
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self safeInitWithObjects:safeObjects forKeys:safeKeys count:j];
}



- (NSString *)getStringForKey:(id)key
{
    id obj = [self objectForKey:key];
    
    
    NSAssert(([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]),
             ([YCBStabilityLogs crashReason:@"无法获取NSString类型"
                                    release:@"返回@"""
                                   otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                             NSStringFromClass([obj class])]]));
    
    if ([obj isKindOfClass:[NSString class]]) {
        return (NSString *)obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj stringValue];
    } else {
        return @"";
    }
}

- (NSArray *)getArrayForKey:(id)key
{
    id obj = [self objectForKey:key];
    
    NSAssert(([obj isKindOfClass:[NSArray class]]),
             ([YCBStabilityLogs crashReason:@"无法获取NSArray类型"
                                    release:@"返回[NSArray array]实例"
                                   otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                             NSStringFromClass([obj class])]]));
    
    if ([obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    } else {
        return [NSArray array];
    }
}


- (NSDictionary *)getDictinaryForKey:(id)key
{
    id obj = [self objectForKey:key];
    
    NSAssert(([obj isKindOfClass:[NSDictionary class]]),
             ([YCBStabilityLogs crashReason:@"无法获取NSDictionary类型"
                                    release:@"返回[NSDictionary dictionary]实例"
                                   otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                             NSStringFromClass([obj class])]]));
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)obj;
    } else {
        return [NSDictionary dictionary];
    }
}

- (int)getIntForKey:(id)key
{
    id obj = [self objectForKey:key];
    
    NSAssert(([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]),
             ([YCBStabilityLogs crashReason:@"不是NSString或NSNumber，无法转化成int类型"
                                    release:@"返回0"
                                   otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                             NSStringFromClass([obj class])]]));
    
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
        return  [obj intValue];
    } else {
        return 0;
    }
}

- (float)getFloatForKey:(id)key
{
    id obj = [self objectForKey:key];
    
    NSAssert(([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]),
             ([YCBStabilityLogs crashReason:@"不是NSString或NSNumber，无法转化成float类型"
                                    release:@"返回0"
                                   otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                             NSStringFromClass([obj class])]]));
    
    
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
        return  [obj floatValue];
    } else {
        return 0;
    }
}

- (BOOL)getBoolForKey:(id)key
{
    id obj = [self objectForKey:key];
    
    NSAssert(([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]),
             ([YCBStabilityLogs crashReason:@"不是NSString或NSNumber，无法转化成BOOL类型"
                                    release:@"返回NO"
                                   otherLog:[NSString stringWithFormat:@"得到的类型是：%@",
                                             NSStringFromClass([obj class])]]));
    
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
        return  [obj boolValue];
    } else {
        return NO;
    }
}


@end


///////////////////////////////////////////////////////

@interface NSMutableDictionary (YCBStability)
@end


@implementation NSMutableDictionary (YCBStability)

+ (void)load
{
    //    Method fromMethod = class_getInstanceMethod(objc_NSMutDictionaryClass(), @selector(setObject:forKey:));
    //    Method toMethod = class_getInstanceMethod(objc_NSMutDictionaryClass(), @selector(safeSetObject:forKey:));
    //    method_exchangeImplementations(fromMethod, toMethod);
    MDictionary_method_exchangeClass(objc_getClass("__NSDictionaryM"));
}
void MDictionary_method_exchangeClass(Class cls) {
    MDictionary_method_exchangeImplementations(cls,@selector(setObject:forKey:), @selector(safeSetObject:forKey:));
    MDictionary_method_exchangeImplementations(cls, @selector(setObject:forKeyedSubscript:), @selector(safeSetObject:forKeyedSubscript:));
    
}

void MDictionary_method_exchangeImplementations(Class cls, SEL name, SEL name2) {
    
    Method fromMethod = class_getInstanceMethod(cls, name);
    Method toMethod = class_getInstanceMethod(cls, name2);
    method_exchangeImplementations(fromMethod, toMethod);
}

- (void)safeSetObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    NSAssert((obj), ([YCBStabilityLogs crashReason:@"被添加的object不存在"
                                           release:@"不执行该方法"
                                          otherLog:nil]));
    
    NSAssert((key), ([YCBStabilityLogs crashReason:@"被添加的key不存在"
                                           release:@"不执行该方法"
                                          otherLog:nil]));
    
    
    if (obj && key) {
        [self safeSetObject:obj forKeyedSubscript:key];
    }
}

- (void)safeSetObject:(id)anObject forKey:(id <NSCopying>)aKey;
{
    
    NSAssert((anObject), ([YCBStabilityLogs crashReason:@"被添加的object不存在"
                                                release:@"不执行该方法"
                                               otherLog:nil]));
    
    NSAssert((aKey), ([YCBStabilityLogs crashReason:@"被添加的key不存在"
                                            release:@"不执行该方法"
                                           otherLog:nil]));
    
    
    if (anObject && aKey) {
        [self safeSetObject:anObject forKey:aKey];
    }
}



@end


///////////////////////////////////////////////////////

@interface NSMutableSet (YCBStability)
@end

@implementation NSMutableSet (YCBStability)

+ (void)load
{
    mutSet_method_exchangeImplementations(@selector(addObject:), @selector(safeAddObject:));
}

- (void)safeAddObject:(id)anObject
{
    NSAssert((anObject), ([YCBStabilityLogs crashReason:@"被添加的元素不存在"
                                                release:@"不执行该方法"
                                               otherLog:nil]));
    
    if (anObject) {
        [self safeAddObject:anObject];
    }
}

Class objc_NSMutSetClass() {
    
    return objc_getClass("__NSSetM");
}


void mutSet_method_exchangeImplementations(SEL name, SEL name2) {
    
    Method fromMethod = class_getInstanceMethod(objc_NSMutSetClass(), name);
    Method toMethod = class_getInstanceMethod(objc_NSMutSetClass(), name2);
    method_exchangeImplementations(fromMethod, toMethod);
}

@end

///////////////////////////////////////////////////////


