//
//  NSObject+FluentJ.h
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (FluentJ)

/**
 Convert JSON -> Model
 */
+ (id)importValues:(id)values keys:(NSDictionary *)keys error:(NSError *)error;
+ (id)importValues:(id)values keys:(NSDictionary *)keys context:(id)context error:(NSError *)error;

/**
 Convert Model -> JSON
 */
- (id)exportValuesWithKeys:(NSArray *)keys;
- (id)exportValuesWithKeys:(NSArray *)keys error:(NSError **)error;

/**
 Transformers for value -> value
 */
+ (NSMutableDictionary *)modelTransformers;

@end
