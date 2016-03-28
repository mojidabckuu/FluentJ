//
//  FJPropertyDescriptor.m
//  Pods
//
//  Created by vlad gorbenko on 9/6/15.
//
//

#import "FJPropertyDescriptor.h"

@implementation FJPropertyDescriptor

#pragma mark - Object lifecycle

+ (instancetype)propertyDescriptorWithObjcProperty:(objc_property_t)property {
    return [[[self class] alloc] initWithObjcProperty:property];
}

- (instancetype)initWithObjcProperty:(objc_property_t)property {
    self = [super init];
    if(self) {
        self.ivar = NULL;
        self.type = NULL;
        [self setupWithProperty:property];
    }
    return self;
}

- (void)dealloc {
    if(self.ivar != NULL) {
        free(self.ivar);
    }
    if(self.type != NULL) {
        free(self.type);
    }
}

#pragma mark - Setup

- (BOOL)setupWithProperty:(objc_property_t)property {
    self.name = @(property_getName(property));
    
        const char * const attrString = property_getAttributes(property);
        if (!attrString) {
            fprintf(stderr, "ERROR: Could not get attribute string from property %s\n", property_getName(property));
            return NO;
        }
        
        if (attrString[0] != 'T') {
            fprintf(stderr, "ERROR: Expected attribute string \"%s\" for property %s to start with 'T'\n", attrString, property_getName(property));
            return NO;
        }
        
        const char *typeString = attrString + 1;
        const char *next = NSGetSizeAndAlignment(typeString, NULL, NULL);
        if (!next) {
            fprintf(stderr, "ERROR: Could not read past type in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
            return NO;
        }
        
        size_t typeLength = next - typeString;
        if (!typeLength) {
            fprintf(stderr, "ERROR: Invalid type in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
            return NO;
        }
        
        // allocate enough space for the structure and the type string (plus a NUL)
    
//        if (!attributes) {
//            fprintf(stderr, "ERROR: Could not allocate mtl_propertyAttributes structure for attribute string \"%s\" for property %s\n", attrString, property_getName(property));
//            return NULL;
//        }
    
        // copy the type string
        self.type = calloc(sizeof(char), typeLength);
        strncpy(self.type, typeString, typeLength);
        self.type[typeLength - 1] = '\0';
    
        
        // if this is an object type, and immediately followed by a quoted string...
        if (typeString[0] == *(@encode(id)) && typeString[1] == '"') {
            // we should be able to extract a class name
            const char *className = typeString + 2;
            next = strchr(className, '"');
            
            if (!next) {
                fprintf(stderr, "ERROR: Could not read class name in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
                return NO;
            }
            
            if (className != next) {
                size_t classNameLength = next - className;
                char trimmedName[classNameLength + 1];
                
                strncpy(trimmedName, className, classNameLength);
                trimmedName[classNameLength] = '\0';
                
                // attempt to look up the class in the runtime
                self.typeClass = objc_getClass(trimmedName);
            }
        }
        
        if (*next != '\0') {
            // skip past any junk before the first flag
            next = strchr(next, ',');
        }
        
        while (next && *next == ',') {
            char flag = next[1];
            next += 2;
            
            switch (flag) {
                case '\0':
                    break;
                    
                case 'R':
                    self.readonly = YES;
                    break;
                    
                case 'C':
                    self.ARCPolicy = FJARCPolicyCopy;
                    break;
                    
                case '&':
                    self.ARCPolicy = FJARCPolicyRetain;
                    break;
                    
                case 'N':
                    self.nonatomic = YES;
                    break;
                    
                case 'G':
                case 'S':
                {
                    const char *nextFlag = strchr(next, ',');
                    SEL name = NULL;
                    
                    if (!nextFlag) {
                        // assume that the rest of the string is the selector
                        const char *selectorString = next;
                        next = "";
                        
                        name = sel_registerName(selectorString);
                    } else {
                        size_t selectorLength = nextFlag - next;
                        if (!selectorLength) {
                            fprintf(stderr, "ERROR: Found zero length selector name in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
                            return NO;
                        }
                        
                        char selectorString[selectorLength + 1];
                        
                        strncpy(selectorString, next, selectorLength);
                        selectorString[selectorLength] = '\0';
                        
                        name = sel_registerName(selectorString);
                        next = nextFlag;
                    }
                    
                    if (flag == 'G')
                        self.getter = name;
                    else
                        self.setter = name;
                }
                    
                    break;
                    
                case 'D':
                    self.dynamic = YES;
                    self.ivar = NULL;
                    break;
                    
                case 'V':
                    // assume that the rest of the string (if present) is the ivar name
                    if (*next == '\0') {
                        // if there's nothing there, let's assume this is dynamic
                        self.ivar = NULL;
                    } else {
                        size_t count = sizeof(next[0]) * sizeof(next);
                        self.ivar = malloc(count);
                        memcpy(self.ivar, next, count);
                        next = "";
                    }
                    
                    break;
                    
                case 'W':
                    self.weak = YES;
                    break;
                    
                case 'P':
                    self.canBeCollected = YES;
                    break;
                    
                case 't':
                    fprintf(stderr, "ERROR: Old-style type encoding is unsupported in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
                    
                    // skip over this type encoding
                    while (*next != ',' && *next != '\0')
                        ++next;
                    
                    break;
                    
                default:
                    fprintf(stderr, "ERROR: Unrecognized attribute string flag '%c' in attribute string \"%s\" for property %s\n", flag, attrString, property_getName(property));
            }
        }
        
        if (next && *next != '\0') {
            fprintf(stderr, "Warning: Unparsed data \"%s\" in attribute string \"%s\" for property %s\n", next, attrString, property_getName(property));
        }
        
        if (!self.getter) {
            // use the property name as the getter by default
            self.getter = sel_registerName(property_getName(property));
        }
        
        if (!self.setter) {
            const char *propertyName = property_getName(property);
            size_t propertyNameLength = strlen(propertyName);
            
            // we want to transform the name to setProperty: style
            size_t setterLength = propertyNameLength + 4;
            
            char setterName[setterLength + 1];
            strncpy(setterName, "set", 3);
            strncpy(setterName + 3, propertyName, propertyNameLength);
            
            // capitalize property name for the setter
            setterName[3] = (char)toupper(setterName[3]);
            
            setterName[setterLength - 1] = ':';
            setterName[setterLength] = '\0';
            
            self.setter = sel_registerName(setterName);
        }
    return YES;
}

@end
