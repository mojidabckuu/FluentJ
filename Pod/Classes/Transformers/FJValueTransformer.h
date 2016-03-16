//
//  FJValueTransformer.h
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import <Foundation/Foundation.h>

typedef __nullable id (^FJValueTransformerBlock)(id _Nullable value, BOOL * _Nonnull success, NSError * _Nullable * _Nullable error);
typedef __nullable id (^FJValueTransformBlock)(id _Nullable value, NSDictionary<NSString *, id> * _Nonnull userInfo, NSError * _Nullable * _Nullable error);

@interface FJValueTransformer : NSValueTransformer

@property (nonnull, nonatomic, strong, readonly) NSDictionary *userInfo;

+ (nonnull instancetype)transformerUsingForwardBlock:(nonnull FJValueTransformerBlock)transformation  __attribute__ ((deprecated));
+ (nonnull instancetype)transformerUsingForwardBlock:(_Nonnull FJValueTransformBlock)transformation userInfo:(nullable NSDictionary<NSString *, id> *)userInfo;

+ (nonnull instancetype)transformerUsingReversibleBlock:(nonnull FJValueTransformerBlock)transformation  __attribute__ ((deprecated));
+ (nonnull instancetype)transformerUsingReversibleBlock:(nonnull FJValueTransformBlock)transformation userInfo:(nullable NSDictionary<NSString *, id> *)userInfo;

+ (nonnull instancetype)transformerUsingForwardBlock:(nonnull FJValueTransformerBlock)forwardTransformation reverseBlock:(nonnull FJValueTransformerBlock)reverseTransformation  __attribute__ ((deprecated));
+ (nonnull instancetype)transformerUsingForwardBlock:(nonnull FJValueTransformBlock)forwardTransformation reverseBlock:(nonnull FJValueTransformBlock)reverseTransformation userInfo:(nullable NSDictionary<NSString *, id> *)userInfo;

@end
