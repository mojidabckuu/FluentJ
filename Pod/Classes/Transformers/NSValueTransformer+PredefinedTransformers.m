//
//  NSValueTransformer+PredefinedTransformers.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "NSValueTransformer+PredefinedTransformers.h"

#import "FJValueTransformer.h"

NSString *const FJBoolValueTransformer = @"FJBoolValueTransformer";
NSString *const FJNumberValueTransformer = @"FJNumberValueTransformer";
NSString *const FJURLValueTransformer = @"FJURLValueTransformer";
NSString *const FJEmptyValueTransformer = @"FJEmptyValueTransformer";

@implementation NSValueTransformer (PredefinedTransformers)

+ (void)load {
    FJValueTransformer *booleanValueTransformer = [FJValueTransformer transformerUsingReversibleBlock:^ id (id boolean, BOOL *success, NSError **error) {
        if (boolean == nil) return nil;
        if ([boolean isKindOfClass:NSNumber.class]) {
            NSNumber *boolValue = boolean;
            return (NSNumber *)(boolValue.boolValue ? kCFBooleanTrue : kCFBooleanFalse);
        } else if([boolean isKindOfClass:NSString.class]) {
            NSArray *boolTrueValues = @[@"y", @"yes", @"true", @"1"];
            NSArray *boolFalseValue = @[@"n", @"no", @"false", @"0"];
            if([boolTrueValues containsObject:boolean]) {
                return (NSNumber *)kCFBooleanTrue;
            } else if([boolFalseValue containsObject:boolean]) {
                return (NSNumber *)kCFBooleanFalse;
            }
        }
        return nil;
    }];
    [NSValueTransformer setValueTransformer:booleanValueTransformer forName:FJBoolValueTransformer];
    
    FJValueTransformer *numberValueTransformer = [FJValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if(!value) return nil;
        if([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *number = [formatter numberFromString:value];
            return number;
        } else if([value isKindOfClass:NSNumber.class]) {
            return value;
        }
        return nil;
    }];
    [NSValueTransformer setValueTransformer:numberValueTransformer forName:FJNumberValueTransformer];
    
    
    FJValueTransformer *URLValueTransformer = [FJValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if(!value.length || ![value isKindOfClass:NSString.class]) {
            return nil;
        }
        NSURL *URL = [NSURL URLWithString:value];
        if(!URL) {
            if(error != NULL) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert string to URL", nil)};
                *error = [NSError errorWithDomain:@"com.FluentJ" code:0 userInfo:userInfo];
            }
            *success = NO;
            return nil;
        }
        return URL;
        
    } reverseBlock:^id(NSURL *value, BOOL *success, NSError *__autoreleasing *error) {
        if(!value || ![value isKindOfClass:NSURL.class]) {
            return nil;
        }
        return value.absoluteString;
    }];
    [NSValueTransformer setValueTransformer:URLValueTransformer forName:FJURLValueTransformer];
    
    FJValueTransformer *emptyValueTransformer = [FJValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    }];
    [NSValueTransformer setValueTransformer:emptyValueTransformer forName:FJEmptyValueTransformer];
    
}

@end
