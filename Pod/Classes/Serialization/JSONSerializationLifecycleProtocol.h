//
//  JSONSerializationLifecycleProtocol.h
//  Pods
//
//  Created by vlad gorbenko on 9/10/15.
//
//

#import <Foundation/Foundation.h>

@protocol JSONSerializationLifecycleProtocol <NSObject>

@optional
/**
 Transformers for value -> value
 Should return a dictionary with format @{"PROPERTY NAME" : TRANSFORMER}
 */
+ (nonnull NSDictionary *)modelTransformers;
+ (nonnull NSDictionary *)modelTransformersWithUserInfo:(nullable NSDictionary *)userInfo;
+ (nullable NSDictionary *)keysForKeyPaths:(nullable NSDictionary *)userInfo;

/**
 Utils
 */
- (void)willImportWithUserInfo:(nullable NSDictionary *)userInfo;
- (void)didImportWithUserInfo:(nullable NSDictionary *)userInfo;

@end
