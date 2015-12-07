//
//  NSObject+Class.h
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

BOOL FJSimpleClass(Class class);

@interface NSObject (Class)

+ (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block;

@end
