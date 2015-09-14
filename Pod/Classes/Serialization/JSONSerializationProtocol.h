//
//  JSONSerializationProtocol.h
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import <Foundation/Foundation.h>

@protocol JSONSerializationProtocol <NSObject>

/**
 Convert JSON -> Model
 */
+ (id)importValue:(id)value userInfo:(NSDictionary *)userInfo error:(NSError **)error;

/**
 JSON -> Model using specified context
 */
+ (id)importValue:(id)value context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error;

/**
 Update Model using JSON
 */
- (void)updateWithValue:(id)values context:(id)context userInfo:(NSDictionary *)userInfo error:(NSError **)error;

/**
 Convert Model -> JSON
 */
- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError **)error;

@end
