//
//  TBR_NSObject+Property.m
//  Usage
//
//  Created by huanwh on 16/4/13.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import "TBR_NSObject+Property.h"
#import <objc/runtime.h>

@implementation  NSObject (Property)
- (NSArray *)properties {
    // 获取当前类的所有属性
    unsigned int count;// 记录属性个数
    objc_property_t *properties = class_copyPropertyList(self.class, &count);
    // 遍历
    NSMutableArray *mArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        
        // An opaque type that represents an Objective-C declared property.
        // objc_property_t 属性类型
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char *cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [mArray addObject:name];
    }
    
    return mArray.copy;
}
-(id)objectForProperty:(NSString *)propertyName {
    NSString * _property = [@"_" stringByAppendingString:propertyName];
    const char * name = _property.UTF8String ;
    
    Ivar var = class_getInstanceVariable([self class], name);
    id object = object_getIvar(self, var);
    
    return [object copy];
}

-(NSString *)jsonString {
    NSArray * properties = [NSArray arrayWithArray:[self properties]];
    NSMutableDictionary * resultDic = @{}.mutableCopy;
    
    for (NSString *  key in properties) {
        resultDic[key] = [self objectForProperty:key];
    }
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"[TBR LOG]node-> jsonString\n 解析json 出错： %@",error);
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}
-(NSDictionary *)dictionay {
    NSArray * properties = [NSArray arrayWithArray:[self properties]];
    NSMutableDictionary * resultDic = @{}.mutableCopy;
    
    for (NSString *  key in properties) {
        resultDic[key] = [self objectForProperty:key];
    }
    return resultDic.copy;
}
@end
