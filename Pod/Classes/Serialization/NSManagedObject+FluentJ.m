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

#import "NSObject+ClassIdentifier.h"

#import "FluentJConfiguration.h"

NSString *const FJImportRelationshipKey = @"relatedByAttribute";

NSString *const FJDirectMappingKey = @"directMapping";

Class FJClassFromString(NSString *className) {
    Class cls = NSClassFromString(className);
    if (cls == nil) {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
        className = [NSString stringWithFormat:@"%@.%@", appName, className];
        cls = NSClassFromString(className);
    }
    return cls;
}

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

+ (nullable instancetype)managedObjectFromModel:(nonnull id)model context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error {
    return [self managedObjectFromModel:model context:context userInfo:userInfo error:error persist:NO];
}

+ (nullable instancetype)managedObjectFromModel:(nonnull id)model context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error persist:(BOOL)persist {
    NSMutableDictionary *fullUserInfo = [NSMutableDictionary dictionary];
    [fullUserInfo addEntriesFromDictionary:userInfo];
    fullUserInfo[APIObjectKey] = model;
    fullUserInfo[FJDirectMappingKey] = @YES;
    __block NSManagedObject *item = nil;
    //    __block id resultValue = nil;
    [context performBlockAndWait:^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[model classIdentifier] inManagedObjectContext:context];
        id relatedBy = [entityDescription.userInfo valueForKey:FJImportRelationshipKey];
        NSAttributeDescription *primaryAttribute = [entityDescription attributesByName][relatedBy];
        
        id relatedByValue = [model valueForVariableKey:relatedBy];
        
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
    //    NSManagedObject *object = [[self class] findObjectInContext:context userInfo:fullUserInfo value:model];
    if(item.isInserted) {
        [item updateWithModel:model context:context userInfo:fullUserInfo error:error];
    }
    if((item.isUpdated || item.isInserted) && persist) {
        [item.managedObjectContext save:error];
    }
    return item;
}

+ (nullable id)modelFromManagedObject:(nonnull NSManagedObject *)object context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error {
    NSMutableDictionary *fullUserInfo = [NSMutableDictionary dictionary];
    [fullUserInfo addEntriesFromDictionary:userInfo];
    fullUserInfo[APIObjectKey] = object;
    fullUserInfo[FJDirectMappingKey] = @YES;
    
    NSEntityDescription *entity = object.entity;
    NSString *className = [[FluentJConfiguration sharedInstance] managedBndings][entity.name];
    id model = [[FJClassFromString(className ?: entity.name) alloc] init];
    
    NSDictionary *managedObjectProperties = entity.propertiesByName;
    NSSet *properties = [[model class] properties];
    [model willImportWithUserInfo:fullUserInfo];
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        NSString *propertyName = propertyDescriptor.name;
        if(!managedObjectProperties[propertyName]) {
            continue;
        }
        id value = [object valueForVariableKey:propertyName];
        if(!value || [value isKindOfClass:[NSNull class]]) {
            continue;
        }
        id attributeDescriptor = managedObjectProperties[propertyName];
        BOOL isCollection = [propertyDescriptor.typeClass conformsToProtocol:@protocol(NSFastEnumeration)];
        NSValueTransformer *transformer = [[model class] transformerWithPropertyDescriptor:propertyDescriptor userInfo:fullUserInfo];
        NSDictionary *bindings = @{@(NSInteger16AttributeType) : NSNumber.class,
                                   @(NSInteger32AttributeType) : NSNumber.class,
                                   @(NSInteger64AttributeType) : NSNumber.class,
                                   @(NSDecimalAttributeType) : NSNumber.class,
                                   @(NSDoubleAttributeType) : NSNumber.class,
                                   @(NSFloatAttributeType) : NSNumber.class,
                                   @(NSStringAttributeType) : NSString.class,
                                   @(NSBooleanAttributeType) : NSNumber.class,
                                   @(NSDateAttributeType) : NSDate.class,
                                   @(NSTransformableAttributeType) : [value class]};
        if([attributeDescriptor isKindOfClass:[NSAttributeDescription class]]) {
            if([value isKindOfClass:bindings[@([attributeDescriptor attributeType])]] && !transformer) {
                [self setValue:value forKey:propertyName];
                continue;
            }
            if(transformer) {
                value = [transformer transformedValue:value];
            }
        } else if([attributeDescriptor isKindOfClass:[NSRelationshipDescription class]]) {
            NSDictionary *subitemUserInfo = [fullUserInfo dictionaryWithKeyPrefix:NSStringFromClass([model class])];
            if(isCollection) {
                NSMutableArray *subitems = [NSMutableArray array];
                for(id subvalue in value) {
                    id subitem = [[self class] modelFromManagedObject:subvalue context:context userInfo:subitemUserInfo error:error];
                    [subitems addObject:subitem];
                }
                value = subitems;
            } else {
                //TODO: Remove this lifehack
                NSRelationshipDescription *relationshipDescriptor = (NSRelationshipDescription *)attributeDescriptor;
                if(![relationshipDescriptor.userInfo[@"forceParse"] boolValue] && relationshipDescriptor == relationshipDescriptor.inverseRelationship.inverseRelationship) {
                    value = nil;
                } else {
                    value = [[self class] modelFromManagedObject:value context:context userInfo:subitemUserInfo error:error];
                }
            }
        }
        if(value) {
            [model setValue:value forKey:propertyName];
        }
    }
    [model didImportWithUserInfo:fullUserInfo];
    return model;
}

+ (nullable NSArray *)modelsFromManagedObjects:(nonnull NSArray *)objects context:(nonnull id)context userInfo:(nullable NSDictionary *)userInfo error:(NSError *__nullable __autoreleasing *__nullable)error {
    NSMutableArray *models = [NSMutableArray array];
    for(NSManagedObject *object in objects) {
        id model = [self modelFromManagedObject:object context:context userInfo:userInfo error:error];
        if(!*error && model) {
            [models addObject:model];
        }
    }
    return models;
}

- (void)updateWithModel:(nonnull id)model context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing  _Nullable *)error {
    NSEntityDescription *entity = self.entity;
    NSDictionary *managedObjectProperties = entity.propertiesByName;
    NSSet *properties = [[model class] properties];
    [self willImportWithUserInfo:userInfo];
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        NSString *propertyName = propertyDescriptor.name;
        if(!managedObjectProperties[propertyName]) {
            continue;
        }
        id value = [model valueForVariableKey:propertyName];
        if(!value || [value isKindOfClass:[NSNull class]]) {
            [self setValue:nil forKey:propertyName];
            continue;
        }
        id attributeDescriptor = managedObjectProperties[propertyName];
        BOOL isCollection = [propertyDescriptor.typeClass conformsToProtocol:@protocol(NSFastEnumeration)];
        NSValueTransformer *transformer = [[model class] transformerWithPropertyDescriptor:propertyDescriptor userInfo:userInfo];
        NSDictionary *bindings = @{@(NSInteger16AttributeType) : NSNumber.class,
                                   @(NSInteger32AttributeType) : NSNumber.class,
                                   @(NSInteger64AttributeType) : NSNumber.class,
                                   @(NSDecimalAttributeType) : NSNumber.class,
                                   @(NSDoubleAttributeType) : NSNumber.class,
                                   @(NSFloatAttributeType) : NSNumber.class,
                                   @(NSStringAttributeType) : NSString.class,
                                   @(NSBooleanAttributeType) : NSNumber.class,
                                   @(NSDateAttributeType) : NSDate.class,
                                   @(NSTransformableAttributeType) : [value class]};
        if([attributeDescriptor isKindOfClass:[NSAttributeDescription class]]) {
            if([value isKindOfClass:bindings[@([attributeDescriptor attributeType])]] && !transformer) {
                [self setValue:value forKey:propertyName];
                continue;
            }
            if(transformer) {
                value = [transformer reverseTransformedValue:value];
            }
        } else if([attributeDescriptor isKindOfClass:[NSRelationshipDescription class]]) {
            NSDictionary *subitemUserInfo = [userInfo dictionaryWithKeyPrefix:NSStringFromClass([model class])];
            if(isCollection) {
                //                NSAssert(transformer, ([NSString stringWithFormat:@"You should provide transformer for property: %@", propertyDescriptor.name]));
                //                if([transformer isKindOfClass:FJModelValueTransformer.class]) {
                //                    FJModelValueTransformer *modelTransformer = (FJModelValueTransformer *)transformer;
                //                    modelTransformer.userInfo = subitemUserInfo;
                //                    modelTransformer.context = context;
                //                }
                for(id subvalue in value) {
                    id subitem = [[self class] managedObjectFromModel:subvalue context:context userInfo:subitemUserInfo error:error];
                    [self importModelsWithValue:value property:propertyDescriptor subitems:@[subitem] context:context userInfo:subitemUserInfo error:error];
                }
                value = nil;
                
            } else {
                id subvalue = [self valueForKey:propertyName];
                if(subvalue) {
                    [self setValue:nil forKey:propertyName];
                }
                value = [[self class] managedObjectFromModel:value context:context userInfo:subitemUserInfo error:error];
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

- (id)importModelsWithValue:(id)value property:(FJPropertyDescriptor *)property subitems:(NSArray *)subitems context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    NSDictionary *relationships = [self.entity relationshipsByName];
    NSRelationshipDescription *relationshipDescription = relationships[property.name];
    
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

#pragma mark - Finders

+ (nullable NSManagedObject *)findBy:(nonnull NSString *)by model:(nonnull id)model context:(nonnull NSManagedObjectContext *)context userInfo:(nonnull NSDictionary *)userInfo {
    return [self findBy:by model:model context:context userInfo:userInfo shouldCreate:NO];
}

+ (nonnull NSManagedObject *)findOrCreateBy:(nonnull NSString *)by model:(nonnull id)model context:(nonnull NSManagedObjectContext *)context userInfo:(nonnull NSDictionary *)userInfo {
    return [self findBy:by model:model context:context userInfo:userInfo shouldCreate:YES];
}

+ (nullable id)findBy:(nonnull NSString *)by model:(nonnull id)model context:(nonnull NSManagedObjectContext *)context userInfo:(nonnull NSDictionary *)userInfo shouldCreate:(BOOL)shouldCreate {
    __block id item = nil;
    [context performBlockAndWait:^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[model classIdentifier] inManagedObjectContext:context];
        id relatedBy = [entityDescription.userInfo valueForKey:FJImportRelationshipKey] ?: by;
        NSAttributeDescription *primaryAttribute = [entityDescription attributesByName][relatedBy];
        
        NSDictionary *keys = [[self class] keysForKeyPaths:userInfo] ?: [[self class] keysWithProperties:[[model class] properties]];
        
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
        if (!item && shouldCreate) {
            item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        }
    }];
    return item;
}

#pragma mark - Finders

+ (nullable NSManagedObject *)findEntity:(nonnull NSString *)entity context:(nonnull NSManagedObjectContext *)context error:(NSError *__autoreleasing  _Nullable * )error {
    NSFetchRequest *request = [self createFetchRequestInContext:context entityName:entity];
    return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (nullable NSManagedObject *)findBy:(nonnull NSString *)by value:(id)value entity:(NSString *)entity context:(nonnull NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestFirstByAttribute:by withValue:value inContext:context entityName:entity];
    return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (NSArray *)findAllBy:(nonnull NSString *)by value:(id)value entity:(NSString *)entity context:(nonnull NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestAllWhere:by isEqualTo:value inContext:context entityName:entity];
    return [self executeFetchRequest:request inContext:context];
}

#pragma mark - Delete

+ (BOOL)deleteBy:(nonnull NSString *)by value:(id)value entity:(NSString *)entity context:(nonnull NSManagedObjectContext *)context error:(NSError *__autoreleasing  _Nullable * )error persisted:(BOOL)persisted {
    NSManagedObject *object = [self findBy:by value:value entity:entity context:context];
    if(object) {
        [context deleteObject:object];
        if(persisted && [context hasChanges]) {
            BOOL result = [context save:error];
            return result;
        }
        return TRUE;
    }
    return FALSE;
}

+ (BOOL)deleteAllBy:(nonnull NSString *)by value:(id)value entity:(NSString *)entity context:(nonnull NSManagedObjectContext *)context error:(NSError *__autoreleasing  _Nullable * )error persisted:(BOOL)persisted {
    NSArray *objects = [self findAllBy:by value:value entity:entity context:context];
    for(NSManagedObject *object in objects) {
        [object.managedObjectContext deleteObject:object];
    }
    if(persisted) {
        return [context save:error];
    }
    return TRUE;
}


#pragma mark - Utils

+ (NSFetchRequest *)requestFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context entityName:(NSString *)entityName {
    NSFetchRequest *request = [self requestAllWhere:attribute isEqualTo:searchValue inContext:context entityName:entityName];
    [request setFetchLimit:1];
    return request;
}

+ (NSFetchRequest *)requestAllWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)context entityName:(NSString *)entityName {
    NSFetchRequest *request = [self createFetchRequestInContext:context entityName:entityName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", property, value]];
    return request;
}


+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context entityName:(NSString *)entityName {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    return request;
}

+ (id)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context {
    [request setFetchLimit:1];
    NSArray *results = [self executeFetchRequest:request inContext:context];
    if ([results count] == 0) {
        return nil;
    }
    return [results firstObject];
}

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context {
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        results = [context executeFetchRequest:request error:&error];
        if (results == nil) {
            NSLog(@"%@", error);
        }
    }];
    return results;
}

@end
