//
//  NSManagedObject+FluentJ.m
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import "NSManagedObject+FluentJ.h"

#import "FJPropertyDescriptor.h"

#import "NSObject+Properties.h"
#import "NSObject+PredefinedTransformers.h"

#import "FJModelValueTransformer.h"

#import "NSDictionary+Init.h"

#import <CoreData/CoreData.h>

@implementation NSManagedObject (FluentJ)

#pragma mark - Import

+ (id)importValues:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSMutableArray *items = [NSMutableArray array];
    for(id value in values) {
        id item = [self importValue:value context:context userInfo:userInfo error:error];
        [items addObject:item];
    }
    return items;
}

+ (id)importValue:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    if(!values) {
        return nil;
    }
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
    id item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    [item updateWithValue:values context:context userInfo:userInfo error:error];
    return item;
}

#pragma mark - Update

- (void)updateWithValue:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error {
    NSDictionary *keys = [[self class] keysForKeyPaths:userInfo];
    NSArray *allKeys = [keys allKeys];
    NSEntityDescription *entityDescription = self.entity;
    NSDictionary *relationships = [entityDescription relationshipsByName];
    [self willImportWithUserInfo:userInfo];
    for(FJPropertyDescriptor *propertyDescriptor in [[self class] properties]) {
        if(![allKeys containsObject:propertyDescriptor.name]) {
            continue;
        }
        NSRelationshipDescription *relationshipDescription = relationships[propertyDescriptor.name];
        id value = values[keys[propertyDescriptor.name]];
        if([value isKindOfClass:[NSNull class]]) {
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
                
                id subitems = [transformer transformedValue:value];
                
                for(id subitem in subitems) {
                    NSString *addRelationMessageFormat = @"set%@:";
                    id relationshipSource = self;
                    if ([relationshipDescription isToMany]) {
                        addRelationMessageFormat = @"add%@Object:";
                        if ([relationshipDescription respondsToSelector:@selector(isOrdered)] && [relationshipDescription isOrdered]) {
                            NSString *selectorName = [relationshipDescription name];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            relationshipSource = [self performSelector:NSSelectorFromString(selectorName)];
#pragma clang diagnostic pop
                            addRelationMessageFormat = @"addObject:";
                        }
                    }
                    
                    NSString *addRelatedObjectToSetMessage = [NSString stringWithFormat:addRelationMessageFormat, [[relationshipDescription name] capitalizedString]];
                    SEL selector = NSSelectorFromString(addRelatedObjectToSetMessage);
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [relationshipSource performSelector:selector withObject:subitem];
#pragma clang diagnostic pop
                }
                value = nil;
            } else {
                value = [propertyDescriptor.typeClass importValue:value context:context userInfo:subitemUserInfo error:error];
            }
        }
        if(value) {
            [self setValue:value forKey:propertyDescriptor.name];
        }
    }
    [self didImportWithUserInfo:userInfo];
}

#pragma mark - Export

- (id)exportValuesWithKeys:(NSArray *)keys {
    return nil;
}

- (id)exportValuesWithKeys:(NSArray *)keys error:(NSError *__autoreleasing *)error {
    return nil;
}

@end
