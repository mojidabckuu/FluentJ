//
//  JSONSerializationProtocol.h
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import <Foundation/Foundation.h>

@protocol JSONSerializationProtocol <NSObject>

/**
 Convert JSON -> Model
 */
+ (nullable id)importValue:(nullable id)value userInfo:(nullable NSDictionary *)userInfo error:(NSError  *__nullable __autoreleasing *__nullable)error;

/**
 JSON -> Model using specified context
 */
+ (nullable id)importValue:(nullable id)value context:(nullable id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;

/**
 Update Model using JSON
 */
- (void)updateWithValue:(nullable NSDictionary<NSString *, id> *)values context:(nullable id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;

/**
 Convert Model -> JSON
 */
- (nullable id)exportWithUserInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;

/**
 Convert Values -> JSON
 */
+ (nullable id)exportValue:(nullable id)value userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error;

@end
