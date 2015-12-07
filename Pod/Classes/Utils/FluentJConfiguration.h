//
//  FluentJConfiguration.h
//  Pods
//
//  Created by vlad gorbenko on 11/26/15.
//
//

#import <Foundation/Foundation.h>

@interface FluentJConfiguration : NSObject

@property (nonatomic, strong) NSString *identifierKeyPathName;
@property (nonatomic, strong) NSMutableArray *simpleClasses;

+ (instancetype)sharedInstance;

@end
