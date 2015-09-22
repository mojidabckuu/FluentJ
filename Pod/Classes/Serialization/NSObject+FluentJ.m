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
        NSString *propertyName = propertyDescriptor.name;
        if(![allKeys containsObject:propertyName]) {
            continue;
        }
        id value = [values valueForVariableKey:keys[propertyName]];
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
                id subvalue = [self valueForKey:propertyName];
                if(subvalue) {
                    [subvalue updateWithValue:value context:context userInfo:subitemUserInfo error:error];
                    value = nil;
                } else {
                    value = [propertyDescriptor.typeClass importValue:value context:context userInfo:subitemUserInfo error:error];
                }
            }
        }
        if(value) {
            [self setValue:value forKey:propertyName];
        }
    }
    [self didImportWithUserInfo:userInfo];
}

#pragma mark - Export

- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSArray *valuesToExport = nil;
    BOOL isCollection = [self conformsToProtocol:@protocol(NSFastEnumeration)];
    if(isCollection) {
        valuesToExport = (NSArray *)self;
    } else {
        valuesToExport = @[self];
    }
    
    NSDictionary *keys = nil;
    if([[self class] respondsToSelector:@selector(keysForKeyPaths:)]) {
        keys = [[[valuesToExport firstObject] class] keysForKeyPaths:userInfo];
    }
    
    NSMutableArray *jsonValues = [NSMutableArray array];
    
    for(id valueToExport in valuesToExport) {
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        NSSet *properties = [[valueToExport class] properties];
        
        NSDictionary *keys = nil;
        if([[self class] respondsToSelector:@selector(keysForKeyPaths:)]) {
            keys = [[valueToExport class] keysForKeyPaths:userInfo];
        }
        if(!keys) {
            keys = [[valueToExport class] keysWithProperties:properties];
        }
        NSArray *allKeys = [keys allKeys];
        
        for(FJPropertyDescriptor *propertyDescriptor in properties) {
            NSString *propertyName = propertyDescriptor.name;
            if(![allKeys containsObject:propertyName]) {
                continue;
            }
            id value = [valueToExport valueForKey:propertyName];
            if(!value) {
                continue;
            }
            id exportedValue = nil;
            NSValueTransformer *transformer = [[valueToExport class] transformerWithPropertyDescriptor:propertyDescriptor];
            if([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
                NSMutableArray *subitems = nil;
                if(transformer) {
                    subitems = [transformer reverseTransformedValue:value];
                } else {
                    subitems = [NSMutableArray array];
                    for(id item in value) {
                        NSDictionary *subitemUserInfo = [userInfo dictionaryWithKeyPrefix:NSStringFromClass([self class])];
                        id subItemjson = [item exportWithUserInfo:subitemUserInfo error:error];
                        [subitems addObject:subItemjson];
                    }
                }
                exportedValue = subitems;
            } else {
                if(transformer) {
                    exportedValue = [transformer reverseTransformedValue:value];
                } else {
                    NSString *classString = NSStringFromClass([valueToExport class]);
                    NSDictionary *subitemUserInfo = [userInfo dictionaryWithKeyPrefix:classString];
                    exportedValue = [value exportWithUserInfo:subitemUserInfo error:error];
                }
            }
            if([exportedValue isKindOfClass:[NSArray class]]) {
                // TODO: remove stange statement
            }
            [json setObject:exportedValue forKey:keys[propertyName]];
        }
        [jsonValues addObject:json];
    }
    
    if(!isCollection) {
        return [jsonValues lastObject];
    }
    if(![userInfo[@"flatten"] boolValue]) {
    } else {
        NSDictionary *first = [jsonValues firstObject];
        NSArray *dictionaryKeys = [first allKeys];
        NSString *flattenKey = dictionaryKeys.count > 1 ? keys[userInfo[@"flattenKey"]] : [dictionaryKeys firstObject];
        NSString *formatString = [NSString stringWithFormat:@"@unionOfObjects.%@", flattenKey];
        jsonValues = [jsonValues valueForKeyPath:formatString];
    }
    return jsonValues;}

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
