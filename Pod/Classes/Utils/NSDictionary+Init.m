//
//  NSDictionary+Init.m
//  Pods
//
//  Created by vlad gorbenko on 9/10/15.
//
//

#import "NSDictionary+Init.h"

@implementation NSDictionary (Init)

- (instancetype)dictionaryWithKeyPrefix:(NSString *)prefix {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for(id key in self.allKeys) {
        if([key isKindOfClass:NSString.class]) {
            NSString *subkey = [NSString stringWithFormat:@"%@.%@", prefix, key];
            [dictionary setObject:self[key] forKey:subkey];
        }
    }
    return dictionary;
}

@end
