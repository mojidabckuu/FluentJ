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

#import "NSValueTransformer+PredefinedTransformers.h"

@implementation NSObject (FluentJ)

+ (id)importValues:(id)values keys:(NSDictionary *)keys error:(NSError *)error {
    NSDictionary *transformers = [self modelTransformers];
    NSMutableArray *items = [NSMutableArray array];
    
    NSArray *allKeys = [keys allKeys];
    for(FJPropertyDescriptor *propertyDescriptor in [[self class] properties]) {
        if(![allKeys containsObject:propertyDescriptor.name]) {
            continue;
        }
        
        id item = [[[self class] alloc] init];
        id value = values[keys[propertyDescriptor.name]];
        NSValueTransformer *transformer = transformers[propertyDescriptor.name];
        if(!transformer) {
            if(*propertyDescriptor.type == *(@encode(id))) {
                transformer = [NSValueTransformer valueTransformerForName:FJBoolValueTransformer];
            } else if(strcmp(propertyDescriptor.type, @encode(BOOL)) == 0) {
                transformer = [NSValueTransformer valueTransformerForName:FJNumberValueTransformer];
            } else if([propertyDescriptor.typeClass conformsToProtocol:@protocol(NSFastEnumeration)]) {
                
            }
        }
        if(transformer) {
            value = [transformer transformedValue:value];
        }
        if([propertyDescriptor.typeClass conformsToProtocol:@protocol(NSFastEnumeration)]) {
            [propertyDescriptor.typeClass]
            
            value = [[propertyDescriptor.typeClass alloc] init];
            
        }
        [item setValue:value forKey:propertyDescriptor.name];
        [items addObject:item];
    }
}

+ (id)importValues:(id)values keys:(NSDictionary *)keys context:(id)context error:(NSError *)error {
    // TODO: add realisation for CoreData models.
}

- (id)exportValuesWithKeys:(NSArray *)keys {
    
}

- (id)exportValuesWithKeys:(NSArray *)keys error:(NSError **)error {
    
}

- (NSMutableDictionary *)modelTransformers {
    
}

@end
