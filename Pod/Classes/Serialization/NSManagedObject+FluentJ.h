//
//  NSManagedObject+FluentJ.h
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import <CoreData/CoreData.h>

#import "NSObject+FluentJ.h"

extern NSString *_Nonnull const FJDirectMappingKey;

@interface NSManagedObject (FluentJ)

#pragma mark - Import
+ (nullable id)importValue:(nullable id)value userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error NS_UNAVAILABLE;

#pragma mark - Projection
+ (nullable instancetype)managedObjectFromModel:(nonnull id)model context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;
+ (nullable instancetype)managedObjectFromModel:(nonnull id)model context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error persist:(BOOL)persist;
+ (nullable id)modelFromManagedObject:(nonnull NSManagedObject *)object context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;
+ (nullable NSArray *)modelsFromManagedObjects:(nonnull NSArray *)objects context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;

#pragma mark - Model finders
+ (nullable NSManagedObject *)findBy:(nonnull NSString *)by model:(nonnull id)model context:(nonnull NSManagedObjectContext *)context userInfo:(nonnull NSDictionary *)userInfo;
+ (nonnull NSManagedObject *)findOrCreateBy:(nonnull NSString *)by model:(nonnull id)model context:(nonnull NSManagedObjectContext *)context userInfo:(nonnull NSDictionary *)userInfo;

#pragma mark - Finders

+ (nullable NSManagedObject *)findBy:(nonnull NSString *)by value:(id)value entity:(NSString *)entity context:(nonnull NSManagedObjectContext *)context;
+ (NSArray *)findAllBy:(nonnull NSString *)by value:(id)value entity:(NSString *)entity context:(nonnull NSManagedObjectContext *)context;

@end
