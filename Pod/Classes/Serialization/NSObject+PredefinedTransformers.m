//
//  NSObject+PredefinedTransformers.m
//  Pods
//
//  Created by vlad gorbenko on 9/10/15.
//
//

#import "NSObject+PredefinedTransformers.h"

#import "NSObject+FluentJ.h"
#import "NSObject+Class.h"

#import "NSValueTransformer+PredefinedTransformers.h"
#import "FJModelValueTransformer.h"

#import "FJPropertyDescriptor.h"

@implementation NSObject (PredefinedTransformers)

+ (NSValueTransformer *)transformerWithPropertyDescriptor:(FJPropertyDescriptor *)propertyDescriptor userInfo:(nullable NSDictionary *)userInfo {
    NSDictionary *transformers = [self modelTransformersWithUserInfo:userInfo];
    NSValueTransformer *transformer = transformers[propertyDescriptor.name];
    if(!transformer) {
        if(propertyDescriptor.typeClass != nil) {
            if([propertyDescriptor.typeClass isKindOfClass:NSNumber.class] || propertyDescriptor.typeClass == NSNumber.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJNumberValueTransformerKey];
            } else if(propertyDescriptor.typeClass == NSURL.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJURLValueTransformerKey];
            } else if([propertyDescriptor.typeClass isKindOfClass:NSString.class] || propertyDescriptor.typeClass == NSString.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJEmptyValueTransformerKey];
            } else if(!FJSimpleClass(propertyDescriptor.typeClass)) {
                // TODO: HARD LIFEHACK FROM EXTERNAL LIB CRUDSY.
                if([[propertyDescriptor.bindingKey lowercaseString] hasSuffix:@"id"]) {
                    transformer = [NSValueTransformer valueTransformerForName:@"FJModelIdValueTransformer"];
                } else {
                    transformer = [NSValueTransformer valueTransformerForName:FJModelValueTransformerKey];
                }
            }
        } else if(propertyDescriptor.type != NULL) {
            if(strcmp(propertyDescriptor.type, @encode(BOOL)) == 0) {
                transformer = [NSValueTransformer valueTransformerForName:FJNumberValueTransformerKey];
            } else {
                transformer = [NSValueTransformer valueTransformerForName:FJEmptyValueTransformerKey];
            }
        }
    }
    return transformer;
}

@end
