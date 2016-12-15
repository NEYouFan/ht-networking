//
//  HTDemoHelper.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTDemoHelper.h"
#import <objc/runtime.h>
#import "HTLog.h"

@implementation HTDemoHelper

+ (NSArray *)getPropertyList:(Class)theClass {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
    for (i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *propertyAttributeString = [[NSString alloc] initWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        NSMutableString *filedTypeString = [NSMutableString stringWithString:propertyAttributeString];
        
        NSRange range = [filedTypeString rangeOfString:@","];
        filedTypeString = (NSMutableString *)[filedTypeString substringToIndex:range.location];
        
        // 下面演示了通过RKObjectMapping获取属性类型的两种不同的方法.
        // 方法1：通过RKKeyValueCodingClassFromPropertyAttributes获取类型.
        const char *attr = property_getAttributes(property);
        if (attr) {
//            Class aClass = RKKeyValueCodingClassFromPropertyAttributes(attr);
//            NSString *aClassName = NSStringFromClass(aClass);
//            HTLogInfo(@"className: %@", aClassName);
        }
        
        // 方法2：通过RKPropertyTypeFromAttributeString(filedTypeString)获取类型;
//        NSString *filedTypeName = RKPropertyTypeFromAttributeString(filedTypeString);
//        HTLogInfo(@"%@", filedTypeName);
        
        [dic setObject:filedTypeString forKey:propertyNameString];
    }
    
    free(properties);
    
    return [dic allKeys];
}

+ (NSDictionary *)propertiesOf:(NSURLRequest *)object
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([NSMutableURLRequest class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [object valueForKey:(NSString *)propertyName];
        if (propertyValue) {
            [props setObject:propertyValue forKey:propertyName];
        } else {
            [props setObject:[NSNull null] forKey:propertyName];
        }
        
    }
    free(properties);
    return props;
}

@end
