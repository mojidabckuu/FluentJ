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

/**
 JSON -> Model using specified context
 */
+ (id)importValue:(id)value context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError *)error;
+ (id)importValues:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError *)error;

@end
