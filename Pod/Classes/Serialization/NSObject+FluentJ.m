//
//  NSObject+FluentJ.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "NSObject+FluentJ.h"

#import "NSObject+Properties.h"
#import "NSObject+Definition.h"

#import "FJPropertyDescriptor.h"

#import "FJValueTransformer.h"
#import "FJModelValueTransformer.h"
#import "NSValueTransformer+PredefinedTransformers.h"
#import "NSObject+PredefinedTransformers.h"

#import "NSDictionary+Init.h"

#import "NSObject+Mutable.h"

#import "NSObject+Update.h"

#import "NSObject+KVC.h"

#import "FluentJConfiguration.h"

NSString *const APIObjectKey = @"APIObjectKey";

@interface NSObject(Empty)

- (BOOL)isEmpty;

@end

@implementation NSObject(Empty)

- (BOOL)isEmpty {
    return false;
}

@end

@implementation NSArray(Empty)

- (BOOL)isEmpty {
    return self.count == 0;
}

@end

@implementation NSDictionary(Empty)

- (BOOL)isEmpty {
    return self.count == 0;
}

@end

@implementation NSString(Empty)

- (BOOL)isEmpty {
    return self.length == 0;
}

@end

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
        return values;
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
    [item willImportWithUserInfo:userInfo];
    [item updateWithValue:value context:context userInfo:userInfo error:error];
    [item didImportWithUserInfo:userInfo];
    return item;
}

#pragma mark - Update

- (void)updateWithValue:(NSDictionary<NSString *, id> *)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
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
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        NSString *propertyName = propertyDescriptor.name;
        if(![allKeys containsObject:propertyName]) {
            continue;
        }
        id value = [values valueForVariableKey:keys[propertyName]];
        if(!value) {
            continue;
        }
        if([value isKindOfClass:[NSNull class]] && !propertyDescriptor.isReadOnly) {
            [self setValue:nil forKey:propertyName];
            continue;
        }
        BOOL isCollection = [propertyDescriptor.typeClass conformsToProtocol:@protocol(NSFastEnumeration)];
        NSMutableDictionary *fullUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        [fullUserInfo setObject:values forKey:APIObjectKey];
        NSValueTransformer *transformer = [[self class] transformerWithPropertyDescriptor:propertyDescriptor userInfo:fullUserInfo];
        if([value isKindOfClass:propertyDescriptor.typeClass] && !transformer) {
            [self setValue:value forKey:propertyName];
            continue;
        }
        if(transformer && !isCollection) {
            if([transformer isKindOfClass:FJModelValueTransformer.class]) {
                FJModelValueTransformer *modelTransformer = (FJModelValueTransformer *)transformer;
                modelTransformer.userInfo = userInfo;
                if(propertyDescriptor.typeClass) {
                    modelTransformer.modelClass = propertyDescriptor.typeClass;
                }
                modelTransformer.context = context;
            }
            value = [transformer transformedValue:value];
        } else {
            NSDictionary *subitemUserInfo = fullUserInfo;
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
        if(value && !propertyDescriptor.isReadOnly) {
            [self setValue:value forKey:propertyName];
        }
    }
}

#pragma mark - Export

- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError **)error {
    if([self isKindOfClass:[NSString class]] || [self isKindOfClass:[NSNumber class]]) {
        return self;
    }
    NSArray *valuesToExport = nil;
    BOOL isCollection = [self conformsToProtocol:@protocol(NSFastEnumeration)];
    if(isCollection) {
        valuesToExport = (NSArray *)self;
    } else {
        valuesToExport = @[self];
    }
    
    NSDictionary *keys = nil;
    if([[self class] respondsToSelector:@selector(keysForKeyPaths:)]) {
        Class modelClass = nil;
        if([valuesToExport isKindOfClass:[NSSet class]]) {
            modelClass = [[[(NSSet *)valuesToExport allObjects] firstObject] class];
        } else {
            modelClass = [[valuesToExport firstObject] class];
        }
        keys = [modelClass keysForKeyPaths:userInfo];
    }
    
    NSMutableArray *jsonValues = [NSMutableArray array];
    
    for(id valueToExport in valuesToExport) {
        Class exportClass = [valueToExport class];
        NSDictionary *json = [exportClass transformExportValues:valueToExport exportClass:exportClass userInfo:userInfo error:error];
        if(!*error && json) {
            [jsonValues addObject:json];
        }
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
    return jsonValues;
}

+ (nullable id)exportValue:(nullable id)value userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error {
    return [self transformExportValues:value exportClass:self userInfo:userInfo error:error];
}

+ (NSMutableDictionary *)modelTransformers {
    return [NSMutableDictionary dictionary];
}

+ (nonnull NSDictionary *)modelTransformersWithUserInfo:(NSDictionary *)userInfo {
    return [self modelTransformers];
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
            value = [newValues copy];
        }
    } else {
        value = [[property.typeClass alloc] initWithArray:subitems];
    }
    return value;
}

+ (NSDictionary *)transformExportValues:(id)valueToExport exportClass:(Class)exportClass userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    NSSet *properties = [exportClass properties];
    NSDictionary *keys = nil;
    NSMutableDictionary *fullUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    fullUserInfo[APIObjectKey] = valueToExport;
    if([[self class] respondsToSelector:@selector(keysForKeyPaths:)]) {
        keys = [exportClass keysForKeyPaths:userInfo];
    }
    if(!keys) {
        keys = [exportClass keysWithProperties:properties];
    }
    NSArray *allKeys = [keys allKeys];
    
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        NSString *propertyName = propertyDescriptor.name;
        if(![allKeys containsObject:propertyName]) {
            continue;
        }
        id value = [valueToExport valueForKey:propertyName];
        
        if(!value || ([[FluentJConfiguration sharedInstance] excludeExportNullValues] && [value isKindOfClass:[NSNull class]])) {
            continue;
        }
        id keysArray = keys[propertyName];
        NSString *key = [keysArray isKindOfClass:[NSArray class]] ? [keysArray firstObject] : keysArray;
        propertyDescriptor.bindingKey = key;
        id exportedValue = nil;
        NSValueTransformer *transformer = [self transformerWithPropertyDescriptor:propertyDescriptor userInfo:fullUserInfo];
        if([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
            NSMutableArray *subitems = nil;
            if(transformer) {
                subitems = [transformer reverseTransformedValue:value];
            } else {
                subitems = [NSMutableArray array];
                for(id item in value) {
                    NSDictionary *subitemUserInfo = [fullUserInfo dictionaryWithKeyPrefix:NSStringFromClass([self class])];
                    id subItemjson = [item exportWithUserInfo:subitemUserInfo error:error];
                    [subitems addObject:subItemjson];
                }
            }
            exportedValue = subitems;
        } else {
            if(transformer) {
                exportedValue = [transformer reverseTransformedValue:value];
            } else {
                NSString *classString = NSStringFromClass(self);
                NSDictionary *subitemUserInfo = [userInfo dictionaryWithKeyPrefix:classString];
                exportedValue = [value exportWithUserInfo:subitemUserInfo error:error];
            }
        }
        
        if(exportedValue) {
            BOOL omit = [FluentJConfiguration sharedInstance].omitEmptyObjects;
            if(omit && ![exportedValue isEmpty]) {
                [json setObject:exportedValue forKey:key];
            } else {
                [json setObject:exportedValue forKey:key];
            }
        }
        propertyDescriptor.bindingKey = nil;
    }
    return json;    
}

@end
