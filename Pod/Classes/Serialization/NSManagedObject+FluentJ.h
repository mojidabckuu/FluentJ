//
//  NSManagedObject+FluentJ.h
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import <CoreData/CoreData.h>

#import "NSObject+FluentJ.h"

extern NSString *const FJDirectMappingKey;

@interface NSManagedObject (FluentJ)

+ (nullable id)importValue:(nullable id)value userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error NS_UNAVAILABLE;

+ (nullable NSManagedObject *)managedObjectFromModel:(nonnull id)model context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;

+ (nullable id)modelFromManagedObject:(nonnull NSManagedObject *)object context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;

+ (nullable NSManagedObject *)findBy:(nonnull NSString *)by model:(nonnull id)model context:(nonnull NSManagedObjectContext *)context userInfo:(nonnull NSDictionary *)userInfo;
+ (nonnull NSManagedObject *)findOrCreateBy:(nonnull NSString *)by model:(nonnull id)model context:(nonnull NSManagedObjectContext *)context userInfo:(nonnull NSDictionary *)userInfo;

@end
