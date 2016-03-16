//
//  FJValueTransformer.h
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import <Foundation/Foundation.h>

typedef id (^FJValueTransformerBlock)(id value, BOOL *success, NSError **error);
typedef id (^FJValueTransformBlock)(id value, NSDictionary *userInfo, NSError **error);

@interface FJValueTransformer : NSValueTransformer

@property (nonatomic, strong, readonly) NSDictionary *userInfo;

+ (instancetype)transformerUsingForwardBlock:(FJValueTransformerBlock)transformation  __attribute__ ((deprecated));
+ (instancetype)transformerUsingForwardBlock:(FJValueTransformBlock)transformation userInfo:(NSDictionary *)userInfo;

+ (instancetype)transformerUsingReversibleBlock:(FJValueTransformerBlock)transformation  __attribute__ ((deprecated));
+ (instancetype)transformerUsingReversibleBlock:(FJValueTransformBlock)transformation userInfo:(NSDictionary *)userInfo;

+ (instancetype)transformerUsingForwardBlock:(FJValueTransformerBlock)forwardTransformation reverseBlock:(FJValueTransformerBlock)reverseTransformation  __attribute__ ((deprecated));
+ (instancetype)transformerUsingForwardBlock:(FJValueTransformBlock)forwardTransformation reverseBlock:(FJValueTransformBlock)reverseTransformation userInfo:(NSDictionary *)userInfo;

@end
