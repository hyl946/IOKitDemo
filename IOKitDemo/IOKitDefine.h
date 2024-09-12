//
//  IOKitDefine.h
//  MTPotal
//
//  Created by yl.han on 2024/9/12.
//

#ifndef IOKitDefine_h
#define IOKitDefine_h

#define MIXBOX_ENABLE_FRAMEWORK_IO_KIT 1

//theos的iokit头文件不全
//#import <IOKit/hid/IOHIDEventSystemClient.h>
//#import <IOKit/hid/IOHIDEvent.h>
//#import <IOKit/hid/IOHIDEventField.h>
//#import <IOKit/hid/IOHIDEventTypes.h>

//https://github.com/avito-tech/Mixbox/tree/0843871d6681f8708f09138c1484017387430f45/Frameworks/IoKit
//该git库头文件比较全
#import <IOKit/hid/IOHIDEventSystemClient.h>
#import <IOKit/hid/IOHIDEvent.h>
#import <IOKit/hid/IOHIDEventField.h>
#import <IOKit/hid/IOHIDEventTypes.h>

#endif /* IOKitDefine_h */
