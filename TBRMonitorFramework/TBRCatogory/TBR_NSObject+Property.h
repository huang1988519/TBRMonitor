//
//  TBR_NSObject+Property.h
//  Usage
//
//  Created by huanwh on 16/4/13.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface  NSObject (Property)
- (NSArray *)properties;
- (id)objectForProperty:(NSString *)propertyName;

-(NSString *)jsonString;
-(NSDictionary *)dictionay;
@end
