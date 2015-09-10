//
//  NSObject+Properties.h
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Properties)

/**
 Returns array of FJPropertyDescription.
 */
+ (NSSet *)properties;

@end
