//
//  FJValueTransformer.h
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import <Foundation/Foundation.h>

typedef id (^FJValueTransformerBlock)(id value, BOOL *success, NSError **error);

@interface FJValueTransformer : NSValueTransformer

+ (instancetype)transformerUsingForwardBlock:(FJValueTransformerBlock)transformation;

+ (instancetype)transformerUsingReversibleBlock:(FJValueTransformerBlock)transformation;

+ (instancetype)transformerUsingForwardBlock:(FJValueTransformerBlock)forwardTransformation reverseBlock:(FJValueTransformerBlock)reverseTransformation;

@end
