//
//  NSManagedObject+FluentJ.h
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import <CoreData/CoreData.h>

#import "NSObject+FluentJ.h"

@interface NSManagedObject (FluentJ)

+ (id)importValue:(id)value userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error NS_UNAVAILABLE;

@end
