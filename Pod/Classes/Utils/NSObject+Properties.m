//
//  NSObject+Properties.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "NSObject+Properties.h"

#import "NSObject+Class.h"

#import "FJPropertyDescriptor.h"

static void *FJCachedPropertyKeysKey = &FJCachedPropertyKeysKey;

@implementation NSObject (Properties)

+ (NSSet *)properties {
    NSSet *cachedKeys = objc_getAssociatedObject(self, FJCachedPropertyKeysKey);
    if (cachedKeys != nil) return cachedKeys;
    
    NSMutableSet *keys = [NSMutableSet set];
    
    [self enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        FJPropertyDescriptor *propertyDescription = [FJPropertyDescriptor propertyDescriptorWithObjcProperty:property];
        [keys addObject:propertyDescription];
    }];
    
    objc_setAssociatedObject(self, FJCachedPropertyKeysKey, keys, OBJC_ASSOCIATION_COPY);
    return keys;
}

#pragma mark - Utils

+ (NSDictionary *)keysWithProperties:(NSSet *)properties {
    NSMutableDictionary *keys = [NSMutableDictionary dictionary];
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        [keys setValue:propertyDescriptor.name forKey:propertyDescriptor.name];
    }
    return keys;
}

@end
