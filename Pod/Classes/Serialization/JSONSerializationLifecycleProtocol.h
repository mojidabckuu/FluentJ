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
+ (NSDictionary *)modelTransformers;
+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo;

/**
 Utils
 */
- (void)willImport;
- (void)didImport;

@end
