//
//  NSObject+Update.h
//  Pods
//
//  Created by vlad gorbenko on 9/13/15.
//
//

#import <Foundation/Foundation.h>

@class FJPropertyDescriptor;

@interface NSObject (Update)

- (id)importModelsWithValue:(id)value property:(FJPropertyDescriptor *)property transformer:(NSValueTransformer *)transformer context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error;
- (void)exportValuesWithProperty:(FJPropertyDescriptor *)property userInfo:(NSDictionary *)userInfo error:(NSError **)error;

@end
