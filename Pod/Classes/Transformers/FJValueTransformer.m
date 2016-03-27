//
//  FJValueTransformer.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "FJValueTransformer.h"

#import <objc/runtime.h>

@interface FJReversibleValueTransformer : FJValueTransformer
@end

@interface FJValueTransformer ()

@property (nonatomic, copy, readonly) FJValueTransformerBlock forwardBlock;
@property (nonatomic, copy, readonly) FJValueTransformerBlock reverseBlock;

@property (nonatomic, copy, readonly) FJValueTransformBlock forwardTransformBlock;
@property (nonatomic, copy, readonly) FJValueTransformBlock reverseTransformBlock;

@end

@implementation FJValueTransformer

#pragma mark - Lifecycle

+ (instancetype)transformerUsingForwardBlock:(FJValueTransformBlock)forwardBlock userInfo:(NSDictionary *)userInfo {
    NSParameterAssert(forwardBlock != nil);
    return [[FJReversibleValueTransformer alloc] initWithForwardBlock:forwardBlock reverseBlock:nil userInfo:userInfo];
}

+ (instancetype)transformerUsingReversibleBlock:(FJValueTransformBlock)reversibleBlock userInfo:(NSDictionary *)userInfo {
    NSParameterAssert(reversibleBlock != nil);
    return [[FJReversibleValueTransformer alloc] initWithForwardBlock:nil reverseBlock:reversibleBlock userInfo:userInfo];
}

+ (instancetype)transformerUsingForwardBlock:(FJValueTransformBlock)forwardBlock reverseBlock:(FJValueTransformBlock)reverseBlock userInfo:(NSDictionary *)userInfo {
    NSParameterAssert(reverseBlock != nil);
    NSParameterAssert(forwardBlock != nil);
    return [[FJReversibleValueTransformer alloc] initWithForwardBlock:forwardBlock reverseBlock:reverseBlock userInfo:userInfo];
}

- (id)initWithForwardBlock:(nullable FJValueTransformBlock)forwardBlock reverseBlock:(nullable FJValueTransformBlock)reverseBlock userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self == nil) return nil;
    
    _forwardTransformBlock = [forwardBlock copy];
    _reverseTransformBlock = [reverseBlock copy];
    self.userInfo = userInfo;
    
    return self;
}

#pragma mark - Deprecated

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

#pragma mark - Accessors

- (NSDictionary *)userInfo {
    return objc_getAssociatedObject(self, @selector(userInfo));
}

#pragma mark - Modifiers

- (void)setUserInfo:(NSDictionary *)userInfo {
    objc_setAssociatedObject(self, @selector(userInfo), userInfo, OBJC_ASSOCIATION_RETAIN);
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
    
    if(self.forwardTransformBlock) {
        return self.forwardTransformBlock(value, self.userInfo, &error);
    }
    return self.forwardBlock(value, &success, &error);
}

- (id)transformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
    NSError *error = nil;
    BOOL success = YES;
    
    id transformedValue = nil;
    if(self.forwardTransformBlock) {
        transformedValue = self.forwardTransformBlock(value, self.userInfo, &error);
        success = error == nil;
    } else {
        transformedValue = self.forwardBlock(value, &success, &error);
    }
    
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
    if(self.reverseTransformBlock) {
        return self.reverseTransformBlock(value, self.userInfo, &error);
    }
    return self.reverseBlock(value, &success, &error);
}

- (id)reverseTransformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
    NSError *error = nil;
    BOOL success = YES;
    
    id transformedValue = nil;
    if(self.reverseTransformBlock) {
        transformedValue = self.reverseTransformBlock(value, self.userInfo, &error);
        success = error == nil;
    } else {
        transformedValue = self.reverseBlock(value, &success, &error);
    }
    
    if (outerSuccess != NULL) *outerSuccess = success;
    if (outerError != NULL) *outerError = error;
    
    return transformedValue;
}

@end

