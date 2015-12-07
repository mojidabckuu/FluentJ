//
//  NSObject+ClassIdentifier.m
//  Pods
//
//  Created by vlad gorbenko on 12/7/15.
//
//

#import "NSObject+ClassIdentifier.h"

@implementation NSObject (ClassIdentifier)

- (NSString *)classIdentifier {
    NSString *className = NSStringFromClass([self class]);
    return [[className componentsSeparatedByString:@"."] lastObject];
}

@end
