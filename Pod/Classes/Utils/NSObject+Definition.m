//
//  NSObject+Definition.m
//  Pods
//
//  Created by vlad gorbenko on 11/26/15.
//
//

#import "NSObject+Definition.h"

#import "FJSimpleClassCache.h"

BOOL FJSimpleClass(Class class) {
    BOOL simple = [class customClass];
    if(!simple) {
        NSString *classString = NSStringFromClass(class);
        if([classString hasPrefix:@"NS"] || [classString hasPrefix:@"UI"]) {
            return TRUE;
        }
        if([[FJSimpleClassCache simpleModels] containsObject:class]) {
            return TRUE;
        }
    }
    return simple;
}

@implementation NSObject (Definition)

+ (BOOL)customClass {
    return YES;
}

@end
