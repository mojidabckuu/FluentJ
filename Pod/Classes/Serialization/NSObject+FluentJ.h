//
//  NSObject+FluentJ.h
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import <Foundation/Foundation.h>

#import "JSONSerializationProtocol.h"
#import "JSONSerializationLifecycleProtocol.h"

extern NSString *const APIObjectKey;

@interface NSObject (FluentJ) <JSONSerializationProtocol, JSONSerializationLifecycleProtocol>

@end
