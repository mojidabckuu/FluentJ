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
    if([key isCollection]) {
        for(id subkey in key) {
            value = [self valueForKey:subkey];
            if(value) {
                break;
            }
        }
    } else {
        value = [self valueForKey:key];
    }
    return value;
}

@end
