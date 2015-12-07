//
//  Category.m
//  FluentJ
//
//  Created by vlad gorbenko on 9/9/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "UserCategory.h"

@implementation UserCategory

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    return @{@"name" : @"name"};
}

+ (BOOL)customClass {
    return YES;
}

@end
