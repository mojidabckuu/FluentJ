//
//  FJSimpleClassCache.m
//  Pods
//
//  Created by vlad gorbenko on 11/26/15.
//
//

#import "FJSimpleClassCache.h"

@implementation FJSimpleClassCache

#pragma mark - Utils

+ (NSMutableArray *)simpleModels {
    static dispatch_once_t onceToken;
    static NSMutableArray *items = nil;
    dispatch_once(&onceToken, ^{
        items = [NSMutableArray array];
    });
    return items;
}

@end
