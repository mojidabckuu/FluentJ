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
            if(propertyDescriptor.typeClass == NSNumber.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJNumberValueTransformer];
            } else if(propertyDescriptor.typeClass == NSURL.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJURLValueTransformer];
            } else if(propertyDescriptor.typeClass == NSString.class) {
                transformer = [NSValueTransformer valueTransformerForName:FJEmptyValueTransformer];
            } else if([[propertyDescriptor.name lowercaseString] hasSuffix:@"id"] && !FJSimpleClass(propertyDescriptor.typeClass)) {
                // TODO: HARD LIFEHACK FROM EXTERNAL LIB CRUDSY.
                transformer = [NSValueTransformer valueTransformerForName:@"FJModelIdValueTransformer"];
            }
        } else if(propertyDescriptor.type != NULL) {
            if(strcmp(propertyDescriptor.type, @encode(BOOL)) == 0) {
                transformer = [NSValueTransformer valueTransformerForName:FJBoolValueTransformer];
            } else {
                transformer = [NSValueTransformer valueTransformerForName:FJEmptyValueTransformer];
            }
        }
    }
    return transformer;
}

@end
