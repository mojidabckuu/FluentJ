//
//  FluentJConfiguration.m
//  Pods
//
//  Created by vlad gorbenko on 11/26/15.
//
//

#import "FluentJConfiguration.h"

@implementation FluentJConfiguration

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if(self) {
        self.identifierKeyPathName = @"id";
        self.simpleClasses = [NSMutableArray array];
    }
    return self;
}

@end
