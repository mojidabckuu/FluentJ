//
//  FJModelValueTransformer.m
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import "FJModelValueTransformer.h"

#import "NSObject+FluentJ.h"

@implementation FJModelValueTransformer

+ (instancetype)transformerWithModelClass:(Class)modelClass {
    return [[self alloc] initWithModelClass:modelClass];
}

+ (instancetype)transformerWithModelClass:(Class)modelClass userInfo:(NSDictionary *)userInfo {
    return [[self alloc] initWithModelClass:modelClass userInfo:userInfo];
}

- (instancetype)initWithModelClass:(Class)modelClass {
    return [self initWithModelClass:modelClass userInfo:nil];
}

- (instancetype)initWithModelClass:(Class)modelClass userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if(self) {
        _modelClass = modelClass;
        _userInfo = userInfo;
    }
    return self;
}

#pragma mark - Transformation

- (id)transformedValue:(id)value {
    return [[self modelClass] importValues:value context:self.context userInfo:self.userInfo error:nil];
}

- (id)reverseTransformedValue:(id)value {
    // TODO: realise it
    return nil;
}

@end
