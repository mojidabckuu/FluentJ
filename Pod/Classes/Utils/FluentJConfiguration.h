//
//  FluentJConfiguration.h
//  Pods
//
//  Created by vlad gorbenko on 11/26/15.
//
//

#import <Foundation/Foundation.h>

// This class represents wrokarounds and configurations for FluentJ

@interface FluentJConfiguration : NSObject

@property (nonatomic, strong) NSString *identifierKeyPathName;
@property (nonatomic, strong) NSMutableArray *simpleClasses;
@property (nonatomic, assign) BOOL excludeExportNullValues;


// Swift supports nested classes. Their names are encoded.
// When FluentJ transforms object -> model or model -> object it will try to lookup
// for name from managedBindings.

@property (nonatomic, strong) NSMutableDictionary *managedBndings;

+ (instancetype)sharedInstance;

@end
