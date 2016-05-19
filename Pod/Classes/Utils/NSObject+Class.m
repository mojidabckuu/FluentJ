//
//  NSObject+Class.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "NSObject+Class.h"

#import "NSObject+Definition.h"
#import "FluentJConfiguration.h"

BOOL FJSimpleClass(Class class) {
    BOOL custom = class ? [class customClass] : YES;
    if(!custom) {
        NSString *classString = NSStringFromClass(class);
        if([classString containsString:@"NS"] || [classString containsString:@"UI"]) {
            return TRUE;
        }
        if([[[FluentJConfiguration sharedInstance] simpleClasses] containsObject:class]) {
            return TRUE;
        }
    }
    return custom;
}

@implementation NSObject (Class)

+ (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    Class cls = self;
    BOOL stop = NO;
    
    Class managedClass = NSClassFromString(@"NSManagedObject");
    while (!stop && !([cls isEqual:NSObject.class] || [cls isEqual:managedClass])) {
        unsigned count = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        
        cls = cls.superclass;
        if (properties == NULL) continue;
        
        for (unsigned i = 0; i < count; i++) {
            block(properties[i], &stop);
            if (stop) break;
        }
        
        free(properties);
    }
}

@end
