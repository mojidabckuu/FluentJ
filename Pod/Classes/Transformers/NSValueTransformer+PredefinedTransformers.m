//
//  NSValueTransformer+PredefinedTransformers.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "NSValueTransformer+PredefinedTransformers.h"

#import "FJValueTransformer.h"

#import "FJModelValueTransformer.h"

NSString *const FJBoolValueTransformerKey = @"FJBoolValueTransformer";
NSString *const FJNumberValueTransformerKey = @"FJNumberValueTransformer";
NSString *const FJURLValueTransformerKey = @"FJURLValueTransformer";
NSString *const FJEmptyValueTransformerKey = @"FJEmptyValueTransformer";
NSString *const FJModelValueTransformerKey = @"FJModelValueTransformer";

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
            if([boolTrueValues containsObject:[boolean lowercaseString]]) {
                return (NSNumber *)kCFBooleanTrue;
            } else if([boolFalseValue containsObject:boolean]) {
                return (NSNumber *)kCFBooleanFalse;
            }
        }
        return nil;
    }];
    [NSValueTransformer setValueTransformer:booleanValueTransformer forName:FJBoolValueTransformerKey];
    
    FJValueTransformer *numberValueTransformer = [FJValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if(!value) return nil;
        if([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *number = [formatter numberFromString:value];
            return number;
        } else if([value isKindOfClass:NSNumber.class]) {
            return value;
        }
        return nil;
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if([value isKindOfClass:[NSNumber class]]) {
            *success = YES;
            return value;
        }
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Value is not a number value", nil)};
        *error = [NSError errorWithDomain:@"com.FluentJ" code:0 userInfo:userInfo];
        *success = NO;
        return nil;
    }];
    [NSValueTransformer setValueTransformer:numberValueTransformer forName:FJNumberValueTransformerKey];
    
    
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
    [NSValueTransformer setValueTransformer:URLValueTransformer forName:FJURLValueTransformerKey];
    
    FJValueTransformer *emptyValueTransformer = [FJValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    }];
    [NSValueTransformer setValueTransformer:emptyValueTransformer forName:FJEmptyValueTransformerKey];
    
    FJModelValueTransformer *modelValueTranformer = [[FJModelValueTransformer alloc] init];
    [NSValueTransformer setValueTransformer:modelValueTranformer forName:FJModelValueTransformerKey];
}

@end
