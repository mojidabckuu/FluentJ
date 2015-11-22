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

/**
 Returns a dictionary of properies [NAME : NAME]
 */
+ (NSDictionary *)keysWithProperties:(NSSet *)properties;

/**
 Returns a dictionary of properies [fileName : file_name]
 */
+ (NSDictionary *)keysWithProperties:(NSSet *)properties sneak:(BOOL)sneak;

@end
