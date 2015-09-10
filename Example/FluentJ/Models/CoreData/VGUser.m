//
//  VGUser.m
//  FluentJ
//
//  Created by vlad gorbenko on 9/9/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "VGUser.h"
#import "VGCategory.h"
#import "VGItem.h"

#import <FluentJ/FluentJ.h>

@implementation VGUser

@dynamic firstName;
@dynamic lastName;
@dynamic age;
@dynamic isVIP;
@dynamic items;
@dynamic category;

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    NSString *action = userInfo[@"action"];
    if([action isEqualToString:@"index"]) {
        return @{@"firstName" : @"firstName",
                 @"isVIP" : @"isVIP",
                 @"items" : @"items",
                 @"category" : @"category",
                 @"commentsCount" : @"commentsCount"};
    }
    return @{@"firstName" : @"firstName",
             @"lastName" : @"lastName"};
}

+ (NSDictionary *)modelTransformers {
    return @{@"items" : [FJModelValueTransformer transformerWithModelClass:[VGItem class]]};
}

@end
