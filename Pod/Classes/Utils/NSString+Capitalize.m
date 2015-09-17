//
//  NSString+Capitalize.m
//  Pods
//
//  Created by vlad gorbenko on 9/17/15.
//
//

#import "NSString+Capitalize.h"

@implementation NSString (Capitalize)

- (NSString *)capitalizedStringWithIndex:(NSInteger)index {
    NSRange range = NSMakeRange(index, 1);
    NSString *letter = [self substringWithRange:range];
    return [self stringByReplacingCharactersInRange:range withString:[letter capitalizedString]];
}

@end
