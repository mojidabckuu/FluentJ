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

#import "NSObject+Mutable.h"

#import "NSObject+Update.h"

#import "NSObject+KVC.h"

@implementation NSObject (FluentJ)

#pragma mark - Import

+ (id)importValue:(id)value userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error {
    return [self importValue:value context:nil userInfo:userInfo error:error];
}

+ (id)importValue:(id)value context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    if([value isKindOfClass:[NSArray class]]) {
        return [self _importValues:value context:context userInfo:userInfo error:error];
    } else {
        return [self _importValue:value context:context userInfo:userInfo error:error];
    }
}

#pragma mark - Import Private

+ (id)_importValues:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    if(![values count]) {
        return nil;
    }
    NSMutableArray *items = [NSMutableArray array];
    for(id value in values) {
        id item = [self _importValue:value context:context userInfo:userInfo error:error];
        if(item) {
            [items addObject:item];
        }
    }
    return items;
}

+ (id)_importValue:(id)value context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    if(!value) {
        return nil;
    }
    id item = [[[self class] alloc] init];
    [item updateWithValue:value context:context userInfo:userInfo error:error];
    return item;
}

#pragma mark - Update

- (void)updateWithValue:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    if(!values) {
        return;
    }
    NSSet *properties = [[self class] properties];
    NSDictionary *keys = nil;
    if([[self class] respondsToSelector:@selector(keysForKeyPaths:)]) {
        keys = [[self class] keysForKeyPaths:userInfo];
    }
    if(!keys) {
        keys = [[self class] keysWithProperties:properties];
    }
    NSArray *allKeys = [keys allKeys];
    [self willImportWithUserInfo:userInfo];
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        if(![allKeys containsObject:propertyDescriptor.name]) {
            continue;
        }
        id value = [values valueForVariableKey:keys[propertyDescriptor.name]];
        if(!value || [value isKindOfClass:[NSNull class]]) {
            continue;
        }
        BOOL isCollection = [propertyDescriptor.typeClass conformsToProtocol:@protocol(NSFastEnumeration)];
        NSValueTransformer *transformer = [[self class] transformerWithPropertyDescriptor:propertyDescriptor];
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
                
                value = [self importModelsWithValue:value property:propertyDescriptor transformer:transformer context:context userInfo:subitemUserInfo error:error];
            } else {
                id subvalue = [self valueForKey:propertyDescriptor.name];
                if(subvalue) {
                    [subvalue updateWithValue:value context:context userInfo:subitemUserInfo error:error];
                    value = nil;
                } else {
                    value = [propertyDescriptor.typeClass importValue:value context:context userInfo:subitemUserInfo error:error];
                }
            }
        }
        if(value) {
            [self setValue:value forKey:propertyDescriptor.name];
        }
    }
    [self didImportWithUserInfo:userInfo];
}

#pragma mark - Export

- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    NSSet *properties = [[self class] properties];
    
    NSDictionary *keys = nil;
    if([[self class] respondsToSelector:@selector(keysForKeyPaths:)]) {
        keys = [[self class] keysForKeyPaths:userInfo];
    }
    if(!keys) {
        keys = [[self class] keysWithProperties:properties];
    }
    NSArray *allKeys = [keys allKeys];
    
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        if(![allKeys containsObject:propertyDescriptor.name]) {
            continue;
        }
        id value = [self valueForKey:propertyDescriptor.name];
        if(!value) {
            continue;
        }
        id exportedValue = nil;
        NSValueTransformer *transformer = [[self class] transformerWithPropertyDescriptor:propertyDescriptor];
        if([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
            NSMutableArray *subitems = [NSMutableArray array];
            for(id item in value) {
                NSDictionary *subitemUserInfo = [userInfo dictionaryWithKeyPrefix:NSStringFromClass([self class])];
                id subItemjson = nil;
                if(transformer) {
                    subItemjson = [transformer reverseTransformedValue:item];
                } else {
                    subItemjson = [item exportWithUserInfo:subitemUserInfo error:error];
                }
                [subitems addObject:subItemjson];
            }
            exportedValue = subitems;
        } else {
            if(transformer) {
                exportedValue = [transformer reverseTransformedValue:value];
            } else {
                NSString *classString = NSStringFromClass([self class]);
                NSDictionary *subitemUserInfo = [userInfo dictionaryWithKeyPrefix:classString];
                exportedValue = [value exportWithUserInfo:subitemUserInfo error:error];
            }
        }
        if([exportedValue isKindOfClass:[NSArray class]]) {
            // TODO: remove stange statement
            if(![userInfo[@"flatten"] boolValue]) {
            } else {
                NSDictionary *first = [exportedValue firstObject];
                NSArray *keys = [first allKeys];
                NSString *flattenKey = keys.count > 1 ? userInfo[@"flattenKey"] : [keys firstObject];
                NSString *formatString = [NSString stringWithFormat:@"@unionOfObjects.%@", flattenKey];
                exportedValue = [exportedValue valueForKeyPath:formatString];
            }
        }
        [json setObject:exportedValue forKey:keys[propertyDescriptor.name]];
    }
    return json;
}

+ (NSMutableDictionary *)modelTransformers {
    return [NSMutableDictionary dictionary];
}

#pragma mark - Notifications

- (void)willImportWithUserInfo:(NSDictionary *)userInfo {
}

- (void)didImportWithUserInfo:(NSDictionary *)userInfo {
}

#pragma mark - Utils

- (id)importModelsWithValue:(id)value property:(FJPropertyDescriptor *)property transformer:(NSValueTransformer *)transformer context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    id subitems = [transformer transformedValue:value];
    id oldValue = [self valueForKey:property.name];
    if(![subitems count]) {
        return nil;
    }
    if([oldValue count]) {
        if([[oldValue class] isMutable]) {
            [oldValue addObjectsFromArray:subitems];
            value = nil;
        } else {
            NSMutableArray *newValues = [NSMutableArray array];
            [newValues addObjectsFromArray:[oldValue allObjects]];
            [newValues addObjectsFromArray:subitems];
            value = [[[oldValue class] alloc] initWithArray:newValues];
        }
    } else {
        value = [[property.typeClass alloc] initWithArray:subitems];
    }
    return value;
}

@end
