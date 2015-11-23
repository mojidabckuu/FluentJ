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
    return [self keysWithProperties:properties sneak:NO];
}

+ (NSDictionary *)keysWithProperties:(NSSet *)properties sneak:(BOOL)sneak {
    NSMutableDictionary *keys = [NSMutableDictionary dictionary];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])" options:NSRegularExpressionCaseInsensitive error:&error];
    for(FJPropertyDescriptor *propertyDescriptor in properties) {
        NSString *value = propertyDescriptor.name;
        if(sneak) {
            NSRange range = NSMakeRange(0, [propertyDescriptor.name length]);
            value = [[regex stringByReplacingMatchesInString:propertyDescriptor.name options:0 range:range withTemplate:@"$1_$2"] lowercaseString];
        }
        [keys setValue:value forKey:propertyDescriptor.name];
    }
    return keys;
}

@end
