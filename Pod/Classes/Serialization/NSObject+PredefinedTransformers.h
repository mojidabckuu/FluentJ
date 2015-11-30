//
//  NSObject+PredefinedTransformers.h
//  Pods
//
//  Created by vlad gorbenko on 9/10/15.
//
//

#import <Foundation/Foundation.h>

@class FJPropertyDescriptor;

@interface NSObject (PredefinedTransformers)

+ (nonnull NSValueTransformer *)transformerWithPropertyDescriptor:(nonnull FJPropertyDescriptor *)propertyDescriptor userInfo:(nullable NSDictionary *)userInfo;

@end
