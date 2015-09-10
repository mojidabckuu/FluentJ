//
//  NSObject+FluentJ.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "NSObject+FluentJ.h"

#import "NSObject+Properties.h"

#import "FJPropertyDescriptor.h"

#import "FJValueTransformer.h"
#import "FJModelValueTransformer.h"
#import "NSValueTransformer+PredefinedTransformers.h"
#import "NSObject+PredefinedTransformers.h"

#import "NSDictionary+Init.h"

@implementation NSObject (FluentJ)

+ (id)importValues:(id)values userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    return [self importValues:values context:nil userInfo:userInfo error:error];
}

+ (id)importValues:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSMutableArray *items = [NSMutableArray array];
    for(id value in values) {
        id item = [self importValue:value userInfo:userInfo error:error];
        [items addObject:item];
    }
    return items;
}

+ (id)importValue:(id)value userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    return [self importValue:value context:nil userInfo:userInfo error:error];
}

+ (id)importValue:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSDictionary *keys = [[self class] keysForKeyPaths:userInfo];
    NSArray *allKeys = [keys allKeys];
    id item = [[[self class] alloc] init];
    for(FJPropertyDescriptor *propertyDescriptor in [[self class] properties]) {
        if(![allKeys containsObject:propertyDescriptor.name]) {
            continue;
        }
        [item willImport];
        id value = values[keys[propertyDescriptor.name]];
        BOOL isCollection = [propertyDescriptor.typeClass conformsToProtocol:@protocol(NSFastEnumeration)];
        NSValueTransformer *transformer = [self transformerWithPropertyDescriptor:propertyDescriptor];
        if(transformer && !isCollection) {
            value = [transformer transformedValue:value];
        } else {
            NSDictionary *subitemUserInfo = [userInfo dictionaryWithKeyPrefix:NSStringFromClass([self class])];
            if(isCollection) {
                NSAssert(transformer, ([NSString stringWithFormat:@"You should provide transformer for property: %@", propertyDescriptor.name]));
                if([transformer isKindOfClass:FJModelValueTransformer.class]) {
                    FJModelValueTransformer *modelTransformer = (FJModelValueTransformer *)transformer;
                    modelTransformer.userInfo = subitemUserInfo;
                    modelTransformer.context = context;
                }
                id subitems = [transformer transformedValue:value];
                id oldValue = [item valueForKey:propertyDescriptor.name];
                if([oldValue count]) {
                    [oldValue addObjectsFromArray:subitems];
                    value = nil;
                } else {
                    value = [[propertyDescriptor.typeClass alloc] initWithArray:subitems];
                }
            } else {
                value = [propertyDescriptor.typeClass importValue:value userInfo:subitemUserInfo error:error];
            }
        }
        if(value) {
            [item setValue:value forKey:propertyDescriptor.name];
        }
    }
    [item didImport];
    return item;
}

- (id)exportValuesWithKeys:(NSArray *)keys {
    return nil;
}

- (id)exportValuesWithKeys:(NSArray *)keys error:(NSError **)error {
    return nil;
}

+ (NSMutableDictionary *)modelTransformers {
    return [NSMutableDictionary dictionary];
}

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    return @{};
}

#pragma mark - Notifications

- (void)willImport {
}

- (void)didImport {
}

@end
