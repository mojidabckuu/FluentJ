//
//  FJModelValueTransformer.m
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import "FJModelValueTransformer.h"

#import "NSObject+FluentJ.h"

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

#pragma mark - Lifecycle

+ (instancetype)transformerWithModelClass:(Class)modelClass {
    return [[self alloc] initWithModelClass:modelClass userInfo:@{} context:nil];
}

+ (instancetype)transformerWithModelClass:(Class)modelClass userInfo:(NSDictionary *)userInfo {
    return [[self alloc] initWithModelClass:modelClass userInfo:userInfo context:nil];
}

+ (instancetype)transformerWithModelClass:(Class)modelClass userInfo:(NSDictionary *)userInfo context:(id)context {
    return [[self alloc] initWithModelClass:modelClass userInfo:userInfo context:context];
}

- (instancetype)initWithModelClass:(Class)modelClass userInfo:(NSDictionary *)userInfo context:(id)context {
    self = [super init];
    if(self) {
        _modelClass = modelClass;
        _userInfo = userInfo;
        _context = context;
    }
    return self;
}

#pragma mark - Transformation

- (id)transformedValue:(id)value {
    return [[self modelClass] importValue:value context:self.context userInfo:self.userInfo error:nil];
}

- (id)reverseTransformedValue:(id)value {
    NSError *error = nil;
    return [value exportWithUserInfo:self.userInfo error:&error];
}

@end
