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
    NSSet *properties = [[self class] properties];
    NSDictionary *keys = [[self class] keysForKeyPaths:userInfo] ?: [self keysWithProperties:properties];
    NSArray *allKeys = [keys allKeys];
    id item = [[[self class] alloc] init];
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        if(![allKeys containsObject:propertyDescriptor.name]) {
            continue;
        }
        [item willImport];
        id value = values[keys[propertyDescriptor.name]];
        if([value isKindOfClass:[NSNull class]]) {
            continue;
        }
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

#pragma mark - Notifications

- (void)willImport {
}

- (void)didImport {
}

#pragma mark - Serialization methods

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    return nil;
}

#pragma mark - Utils

+ (NSDictionary *)keysWithProperties:(NSSet *)properties {
    NSMutableDictionary *keys = [NSMutableDictionary dictionary];
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        [keys setValue:propertyDescriptor.name forKey:propertyDescriptor.name];
    }
    return keys;
}

@end
