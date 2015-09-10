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

#pragma mark -

+ (id)importValue:(id)value userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSAssert(false, @"Use +importValue:context:userInfo:error: instead");
    return nil;
}

+ (id)importValues:(id)values userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSAssert(false, @"Use +importValues:context:userInfo:error: instead");
    return nil;
}

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
    NSDictionary *keys = [[self class] keysForKeyPaths:userInfo];
    NSArray *allKeys = [keys allKeys];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
    NSDictionary *relationships = [entityDescription relationshipsByName];
    id item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    for(FJPropertyDescriptor *propertyDescriptor in [[self class] properties]) {
        if(![allKeys containsObject:propertyDescriptor.name]) {
            continue;
        }
        [item willImport];
        NSRelationshipDescription *relationshipDescription = relationships[propertyDescriptor.name];
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
                
                for(id subitem in subitems) {
                    NSString *addRelationMessageFormat = @"set%@:";
                    id relationshipSource = item;
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
            [item setValue:value forKey:propertyDescriptor.name];
        }
    }
    [item didImport];
    return item;
}
@end
