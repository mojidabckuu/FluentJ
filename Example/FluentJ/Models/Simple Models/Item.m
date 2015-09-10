//
//  Item.m
//  FluentJ
//
//  Created by vlad gorbenko on 9/6/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "Item.h"

@implementation Item

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    return @{@"name" : @"name"};
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name: %@", self.name];
}

@end
