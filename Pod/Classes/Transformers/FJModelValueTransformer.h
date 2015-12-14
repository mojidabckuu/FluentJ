//
//  FJModelValueTransformer.h
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import <Foundation/Foundation.h>

@interface FJModelValueTransformer : NSValueTransformer

@property (nonatomic, assign) Class modelClass;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) id context;

+ (instancetype)transformerWithModelClass:(Class)modelClass;
+ (instancetype)transformerWithModelClass:(Class)modelClass userInfo:(NSDictionary *)userInfo;
+ (instancetype)transformerWithModelClass:(Class)modelClass userInfo:(NSDictionary *)userInfo context:(id)context;

@end
