//
//  FJPropertyDescriptor.h
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

typedef enum {
    FJARCPolicyAssign = 0,
    FJARCPolicyRetain,
    FJARCPolicyCopy
} FJARCPolicy;

@interface FJPropertyDescriptor : NSObject

@property (nonatomic, assign, getter=isNonatomic) BOOL nonatomic;
@property (nonatomic, assign, getter=isReadOnly) BOOL readonly;
@property (nonatomic, assign, getter=isWeak) BOOL weak;
@property (nonatomic, assign, getter=isDynamic) BOOL dynamic;
@property (nonatomic, assign, getter=isCanBeCollected) BOOL canBeCollected;
@property (nonatomic, assign) FJARCPolicy ARCPolicy;
@property (nonatomic, assign) SEL getter;
@property (nonatomic, assign) SEL setter;
@property (nonatomic, assign) char *ivar;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) Class typeClass;
@property (nonatomic, assign) char *type;
@property (nonatomic, strong) NSString *bindingKey;

//@property (nonatomic, readonly, getter = isFromFoundation) BOOL fromFoundation;
//
//@property (nonatomic, readonly, getter = isKVCDisabled) BOOL KVCDisabled;

+ (instancetype)propertyDescriptorWithObjcProperty:(objc_property_t)property;

- (instancetype)initWithObjcProperty:(objc_property_t)property;

@end
