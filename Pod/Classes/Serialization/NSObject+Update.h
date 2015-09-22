//
//  NSObject+Update.h
//  Pods
//
//  Created by vlad gorbenko on 9/13/15.
//
//

#import <Foundation/Foundation.h>

@class FJPropertyDescriptor;

@protocol NSObjectImportProtocol <NSObject>

@optional
- (nullable id)importModelsWithValue:(nullable id)value property:(nullable FJPropertyDescriptor *)property transformer:(nullable NSValueTransformer *)transformer context:(nullable id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable*__nullable)error;

@end

@interface NSObject (Update)

@end
