//
//  FJModelValueTransformer.h
//  Pods
//
//  Created by vlad gorbenko on 9/9/15.
//
//

#import <Foundation/Foundation.h>

@interface FJModelValueTransformer : NSValueTransformer

@property (nonatomic, assign, readonly) Class modelClass;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) id context;

+ (instancetype)transformerWithModelClass:(Class)modelClass;
- (instancetype)initWithModelClass:(Class)modelClass;

@end
