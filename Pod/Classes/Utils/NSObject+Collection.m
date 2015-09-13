//
//  NSObject+Collection.m
//  Pods
//
//  Created by vlad gorbenko on 9/13/15.
//
//

#import "NSObject+Collection.h"

@implementation NSObject (Collection)

- (BOOL)isCollection {
    return [self conformsToProtocol:@protocol(NSFastEnumeration)];
}

@end
