//
//  User.h
//  FluentJ
//
//  Created by vlad gorbenko on 9/6/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;
@class UserCategory;

@interface User : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, assign) BOOL isVIP;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UserCategory *category;

@property (nonatomic, assign) NSInteger commentsCount;

@end
