//
//  User.m
//  FluentJ
//
//  Created by vlad gorbenko on 9/6/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "User.h"

#import "Item.h"

#import <FluentJ/FluentJ.h>

@implementation User

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
//    NSString *action = userInfo[@"action"];
//    if([action isEqualToString:@"index"]) {
        return @{@"firstName" : @"firstName",
                 @"isVIP" : @"isVIP",
                 @"items" : @"items",
                 @"category" : @[@"category", @"category_model"],
                 @"commentsCount" : @"commentsCount"};
//    }
//    return @{@"firstName" : @"firstName",
//             @"lastName" : @"lastName"};
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name: %@, surname: %@ isVip: %@ items: %@ category: %@", self.firstName, self.lastName, self.isVIP ? @"YES" : @"NO", self.items, self.category];
}

+ (NSDictionary *)modelTransformers {
    return @{@"items" : [FJModelValueTransformer transformerWithModelClass:[Item class]]};
}

@end
