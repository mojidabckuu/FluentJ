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

// if related object is {} or [] then it will not be treated
// Default is YES
@property (nonatomic, assign) BOOL omitEmptyObjects;


// Swift supports nested classes. Their names are encoded.
// When FluentJ transforms object -> model or model -> object it will try to lookup
// for name from managedBindings.
// Format: [entity.name : className]

@property (nonatomic, strong) NSMutableDictionary *managedBndings;

+ (instancetype)sharedInstance;

@end
