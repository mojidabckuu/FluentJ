//
//  NSObject+KVC.m
//  Pods
//
//  Created by vlad gorbenko on 9/14/15.
//
//

#import "NSObject+KVC.h"

#import "NSObject+Collection.h"

@implementation NSObject (KVC)

- (id)valueForVariableKey:(id)key {
    id value = nil;
    NSArray *simpleClasses = @[[NSString class], [NSNumber class], [NSData class]];
    BOOL simple = false;
    for(Class simpleClass in simpleClasses) {
        simple = [self isKindOfClass:simpleClass];
        if(simple) {
            break;
        }
    }
    @try {
        value = [self valueForKey:key];
    }
    @catch (NSException *exception) {
//        NSLog(@"Something went wrong: %@", exception);
        if([self respondsToSelector:@selector(key)]) {
            value = [self valueForKey:key];
        } else if([key isCollection] && !simple) {
            for(id subkey in key) {
                SEL selector = NSSelectorFromString(subkey);
                //            if([self respondsToSelector:NSSelectorFromString(subkey)]) {
                value = [self valueForKey:subkey];
                if(value) {
                    break;
                }
                //            }
            }
        } else if([self isKindOfClass:[NSDictionary class]]) {
            value = [self valueForKey:key];
        } else {
            value = self;
        }
        
    }
    return value;
}

@end
