//
//  VGItem.h
//  FluentJ
//
//  Created by vlad gorbenko on 9/9/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VGItem;

@interface VGItem : NSManagedObject

@property (nonatomic, retain) NSNumber * name;
@property (nonatomic, retain) VGItem *user;

@end
