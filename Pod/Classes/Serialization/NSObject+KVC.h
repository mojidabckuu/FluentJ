//
//  NSObject+KVC.h
//  Pods
//
//  Created by vlad gorbenko on 9/14/15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (KVC)

- (nullable id)valueForVariableKey:(nonnull id)key;

@end
