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

#import "NSObject+Update.h"

#import "NSObject+KVC.h"

#import "NSString+Capitalize.h"

#import "NSobject+ClassIdentifier.h"

NSString *const FJImportRelationshipKey = @"relatedByAttribute";

@implementation NSManagedObject (FluentJ)

#pragma mark - Import Private

+ (id)_importValue:(id)value context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    if(!value) {
        return nil;
    }
    __block id item = nil;
    __block id resultValue = nil;
    [context performBlockAndWait:^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
        id relatedBy = [entityDescription.userInfo valueForKey:FJImportRelationshipKey];
        NSAttributeDescription *primaryAttribute = [entityDescription attributesByName][relatedBy];
        
        NSDictionary *keys = [[self class] keysForKeyPaths:userInfo] ?: [[self class] keysWithProperties:[self properties]];
        
        id relatedByValue = [value valueForVariableKey:keys[relatedBy]];
        
        if (primaryAttribute) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", relatedBy, relatedByValue]];
            [request setFetchLimit:1];
            __block NSArray *results = nil;
            [context performBlockAndWait:^{
                NSError *error = nil;
                results = [context executeFetchRequest:request error:&error];
                if(error) {
                    NSLog(@"ERROR: %@", error);
                }
            }];
            item = results.count ? [results firstObject] : nil;
        }
        if (!item) {
            item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        }
        resultValue = value;
        if(![value isKindOfClass:[NSDictionary class]]) {
            resultValue = @{relatedBy : value};
        }
    }];
    [item updateWithValue:resultValue context:context userInfo:userInfo error:error];
    
    return item;
}

#pragma mark - Update

- (void)updateWithValue:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error {
    [super updateWithValue:values context:context userInfo:userInfo error:error];
}

#pragma mark - ManagedObject transform

+ (nullable id)managedObjectFromModel:(nonnull id)model context:(id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error {
    NSMutableDictionary *fullUserInfo = [NSMutableDictionary dictionary];
    [fullUserInfo addEntriesFromDictionary:userInfo];
    fullUserInfo[@"managedMapping"] = @YES;
    __block id item = nil;
//    __block id resultValue = nil;
    [context performBlockAndWait:^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[model classIdentifier] inManagedObjectContext:context];
        id relatedBy = [entityDescription.userInfo valueForKey:FJImportRelationshipKey];
        NSAttributeDescription *primaryAttribute = [entityDescription attributesByName][relatedBy];
        
        NSDictionary *keys = [[model class] keysForKeyPaths:userInfo] ?: [[model class] keysWithProperties:[[model class] properties]];
        
        id relatedByValue = [model valueForVariableKey:keys[relatedBy]];
        
        if (primaryAttribute) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", relatedBy, relatedByValue]];
            [request setFetchLimit:1];
            __block NSArray *results = nil;
            [context performBlockAndWait:^{
                NSError *error = nil;
                results = [context executeFetchRequest:request error:&error];
                if(error) {
                    NSLog(@"ERROR: %@", error);
                }
            }];
            item = results.count ? [results firstObject] : nil;
        }
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:entityDescription.name inManagedObjectContext:context];
//            item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        }
//        resultValue = value;
//        if(![value isKindOfClass:[NSDictionary class]]) {
//            resultValue = @{relatedBy : value};
//        }
    }];
    NSManagedObject *object = [[self class] findObjectInContext:context userInfo:fullUserInfo value:model];
    [object updateWithModel:model context:context userInfo:userInfo error:error];
    return object;
}

- (void)updateWithModel:(nonnull id)model context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing  _Nullable *)error {
    NSEntityDescription *entity = self.entity;
    NSDictionary *managedObjectProperties = entity.propertiesByName;
    
    NSSet *properties = [[model class] properties];
    NSDictionary *keys = nil;
    if([[model class] respondsToSelector:@selector(keysForKeyPaths:)]) {
        keys = [[model class] keysForKeyPaths:userInfo];
    }
    if(!keys) {
        keys = [[model class] keysWithProperties:properties];
    }
    NSArray *allKeys = [keys allKeys];
    [self willImportWithUserInfo:userInfo];
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        NSString *propertyName = propertyDescriptor.name;
        if(![allKeys containsObject:propertyName]) {
            continue;
        }
        id value = [model valueForVariableKey:keys[propertyName]];
        if(!value || [value isKindOfClass:[NSNull class]]) {
            continue;
        }
        BOOL isCollection = [propertyDescriptor.typeClass conformsToProtocol:@protocol(NSFastEnumeration)];
        NSValueTransformer *transformer = [[model class] transformerWithPropertyDescriptor:propertyDescriptor userInfo:userInfo];
        if([value isKindOfClass:propertyDescriptor.typeClass] && !transformer) {
            [self setValue:value forKey:propertyName];
            continue;
        }
        if(transformer && !isCollection) {
            value = [transformer transformedValue:value];
        } else {
            NSDictionary *subitemUserInfo = [userInfo dictionaryWithKeyPrefix:NSStringFromClass([model class])];
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

#pragma mark - Utils

- (id)importModelsWithValue:(id)value property:(FJPropertyDescriptor *)property transformer:(NSValueTransformer *)transformer context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSDictionary *relationships = [self.entity relationshipsByName];
    NSRelationshipDescription *relationshipDescription = relationships[property.name];
    
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
        
        NSString *addRelatedObjectToSetMessage = [NSString stringWithFormat:addRelationMessageFormat, [[relationshipDescription name] capitalizedStringWithIndex:0]];
        SEL selector = NSSelectorFromString(addRelatedObjectToSetMessage);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [relationshipSource performSelector:selector withObject:subitem];
#pragma clang diagnostic pop
    }
    return nil;
}

+ (NSManagedObject *)findObjectInContext:(NSManagedObjectContext *)context userInfo:(NSDictionary *)userInfo value:(id)value {
    __block id item = nil;
    __block id resultValue = nil;
    [context performBlockAndWait:^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
        id relatedBy = [entityDescription.userInfo valueForKey:FJImportRelationshipKey];
        NSAttributeDescription *primaryAttribute = [entityDescription attributesByName][relatedBy];
        
        NSDictionary *keys = [[self class] keysForKeyPaths:userInfo] ?: [[self class] keysWithProperties:[self properties]];
        
        id relatedByValue = [value valueForVariableKey:keys[relatedBy]];
        
        if (primaryAttribute) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", relatedBy, relatedByValue]];
            [request setFetchLimit:1];
            __block NSArray *results = nil;
            [context performBlockAndWait:^{
                NSError *error = nil;
                results = [context executeFetchRequest:request error:&error];
                if(error) {
                    NSLog(@"ERROR: %@", error);
                }
            }];
            item = results.count ? [results firstObject] : nil;
        }
        if (!item) {
            item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        }
        resultValue = value;
        if(![value isKindOfClass:[NSDictionary class]]) {
            resultValue = @{relatedBy : value};
        }
    }];
    return item;
}

@end
