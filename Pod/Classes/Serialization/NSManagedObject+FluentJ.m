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

@implementation NSManagedObject (FluentJ)

#pragma mark - Import Private

+ (id)_importValue:(id)value context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error {
    if(!value) {
        return nil;
    }
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
    id item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    [item updateWithValue:value context:context userInfo:userInfo error:error];
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
        
        NSString *addRelatedObjectToSetMessage = [NSString stringWithFormat:addRelationMessageFormat, [[relationshipDescription name] capitalizedString]];
        SEL selector = NSSelectorFromString(addRelatedObjectToSetMessage);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [relationshipSource performSelector:selector withObject:subitem];
#pragma clang diagnostic pop
    }
    return nil;
}

@end
