//
//  NSObject+Mutable.m
//  Pods
//
//  Created by vlad gorbenko on 9/13/15.
//
//

#import "NSObject+Mutable.h"

@implementation NSObject (Mutable)

+ (BOOL)isMutable {
    NSString *classString = NSStringFromClass(self);
    return [classString containsString:@"Mutable"];
}

@end
