//
//  VGCategory.h
//  FluentJ
//
//  Created by vlad gorbenko on 9/9/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VGUser;

@interface VGCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) VGUser *user;

@end
