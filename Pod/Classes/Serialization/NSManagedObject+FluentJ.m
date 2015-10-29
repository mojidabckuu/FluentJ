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

@end
