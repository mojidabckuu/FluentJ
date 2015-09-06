//
//  FJValueTransformer.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "FJValueTransformer.h"

@interface FJReversibleValueTransformer : FJValueTransformer
@end

@interface FJValueTransformer ()

@property (nonatomic, copy, readonly) FJValueTransformerBlock forwardBlock;
@property (nonatomic, copy, readonly) FJValueTransformerBlock reverseBlock;

@end

@implementation FJValueTransformer

#pragma mark Lifecycle

+ (instancetype)transformerUsingForwardBlock:(FJValueTransformerBlock)forwardBlock {
    return [[self alloc] initWithForwardBlock:forwardBlock reverseBlock:nil];
}

+ (instancetype)transformerUsingReversibleBlock:(FJValueTransformerBlock)reversibleBlock {
    return [self transformerUsingForwardBlock:reversibleBlock reverseBlock:reversibleBlock];
}

+ (instancetype)transformerUsingForwardBlock:(FJValueTransformerBlock)forwardBlock reverseBlock:(FJValueTransformerBlock)reverseBlock {
    return [[FJReversibleValueTransformer alloc] initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

- (id)initWithForwardBlock:(FJValueTransformerBlock)forwardBlock reverseBlock:(FJValueTransformerBlock)reverseBlock {
    NSParameterAssert(forwardBlock != nil);
    
    self = [super init];
    if (self == nil) return nil;
    
    _forwardBlock = [forwardBlock copy];
    _reverseBlock = [reverseBlock copy];
    
    return self;
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
    return NO;
}

+ (Class)transformedValueClass {
    return NSObject.class;
}

- (id)transformedValue:(id)value {
    NSError *error = nil;
    BOOL success = YES;
    
    return self.forwardBlock(value, &success, &error);
}

- (id)transformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
    NSError *error = nil;
    BOOL success = YES;
    
    id transformedValue = self.forwardBlock(value, &success, &error);
    
    if (outerSuccess != NULL) *outerSuccess = success;
    if (outerError != NULL) *outerError = error;
    
    return transformedValue;
}

@end

@implementation FJReversibleValueTransformer

#pragma mark Lifecycle

- (id)initWithForwardBlock:(FJValueTransformerBlock)forwardBlock reverseBlock:(FJValueTransformerBlock)reverseBlock {
    NSParameterAssert(reverseBlock != nil);
    return [super initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)reverseTransformedValue:(id)value {
    NSError *error = nil;
    BOOL success = YES;
    
    return self.reverseBlock(value, &success, &error);
}

- (id)reverseTransformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
    NSError *error = nil;
    BOOL success = YES;
    
    id transformedValue = self.reverseBlock(value, &success, &error);
    
    if (outerSuccess != NULL) *outerSuccess = success;
    if (outerError != NULL) *outerError = error;
    
    return transformedValue;
}

@end

