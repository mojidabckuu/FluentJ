//
//  VGUser.h
//  FluentJ
//
//  Created by vlad gorbenko on 9/9/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VGCategory, VGItem;

@interface VGUser : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) VGCategory *category;
@end

@interface VGUser (CoreDataGeneratedAccessors)

- (void)addItemsObject:(VGItem *)value;
- (void)removeItemsObject:(VGItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
