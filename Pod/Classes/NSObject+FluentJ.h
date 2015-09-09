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
+ (id)importValue:(id)value userInfo:(NSDictionary *)userInfo error:(NSError *)error;
+ (id)importValues:(id)values userInfo:(NSDictionary *)userInfo error:(NSError *)error;

+ (id)importValues:(id)values context:(id)context error:(NSError *)error;

/**
 Convert Model -> JSON
 */
- (id)exportValuesWithKeys:(NSArray *)keys;
- (id)exportValuesWithKeys:(NSArray *)keys error:(NSError **)error;

/**
 Transformers for value -> value
 Should return a dictionary with format @{"PROPERTY NAME" : TRANSFORMER}
 */
+ (NSMutableDictionary *)modelTransformers;
+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo;

/**
 Utils
 */
- (void)willImport;
- (void)didImport;

@end
