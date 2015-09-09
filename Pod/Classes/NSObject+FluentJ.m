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

@implementation NSObject (FluentJ)

+ (id)importValues:(id)values userInfo:(NSDictionary *)userInfo error:(NSError *)error {
    NSMutableArray *items = [NSMutableArray array];
    for(id value in values) {
        id item = [self importValue:value userInfo:userInfo error:error];
        [items addObject:item];
    }
    return items;
}

+ (id)importValue:(id)values userInfo:(NSDictionary *)userInfo error:(NSError *)error {
    NSDictionary *modelTransformers = [self modelTransformers];
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
        NSValueTransformer *transformer = modelTransformers[propertyDescriptor.name];
        if(!transformer) {
            transformer = [self transformerWithPropertyDescriptor:propertyDescriptor];
        }
        if(transformer && !isCollection) {
            value = [transformer transformedValue:value];
        } else {
            NSMutableDictionary *subitemUserInfo = [NSMutableDictionary dictionary];
            for(id userInfoKey in userInfo.allKeys) {
                if([userInfoKey isKindOfClass:NSString.class]) {
                    NSString *key = [NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), userInfoKey];
                    [subitemUserInfo setObject:userInfo[userInfoKey] forKey:key];
                }
            }
            if(isCollection) {
                NSString *description = [NSString stringWithFormat:@"You should provide transformer for property: %@", propertyDescriptor.name];
                NSAssert(transformer, description);
                if([transformer isKindOfClass:FJModelValueTransformer.class]) {
                    FJModelValueTransformer *modelTransformer = (FJModelValueTransformer *)transformer;
                    modelTransformer.userInfo = subitemUserInfo;
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

+ (id)importValues:(id)values context:(id)context error:(NSError *)error {
    // TODO: add realisation for CoreData models.
    return nil;
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

#pragma mark - Utils

+ (NSValueTransformer *)transformerWithPropertyDescriptor:(FJPropertyDescriptor *)propertyDescriptor {
    NSDictionary *transformers = [self modelTransformers];
    NSValueTransformer *transformer = transformers[propertyDescriptor.name];
    if(!transformer) {
        if(propertyDescriptor.typeClass != nil) {
            if(propertyDescriptor.typeClass == NSNumber.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJNumberValueTransformer];
            } else if(propertyDescriptor.typeClass == NSURL.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJURLValueTransformer];
            } else if(propertyDescriptor.typeClass == NSString.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJEmptyValueTransformer];
            }
        } else if(propertyDescriptor.type != NULL) {
            if(strcmp(propertyDescriptor.type, @encode(BOOL)) == 0) {
                transformer = [NSValueTransformer valueTransformerForName:FJBoolValueTransformer];
            }
        }
    }
    return transformer;
}

#pragma mark - Notifications

- (void)willImport {
}

- (void)didImport {
}

@end
