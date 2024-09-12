//
//  IOKitManager.m
//  IOKitDemo
//
//  Created by yl.han on 2024/9/12.
//

#import "IOKitManager.h"
#import "IOKitDefine.h"
#import <mach/mach_time.h>

#define kIOKitNFDefine(kIOKitNotification) NSString * kIOKitNotification = @#kIOKitNotification;

kIOKitNFDefine(kIOKitVendorDefinedNotification)//厂商定义
kIOKitNFDefine(kIOKitKeyboardNewNotification)
kIOKitNFDefine(kIOKitKeyboardRingerNotification)
kIOKitNFDefine(kIOKitKeyboardFeatureNotification)
kIOKitNFDefine(kIOKitKeyboardLockNotification)
kIOKitNFDefine(kIOKitKeyboardForcedShutdownNotification)
kIOKitNFDefine(kIOKitKeyboardTouchIdNotification)
kIOKitNFDefine(kIOKitKeyboardVolumeIncreaseNotification)
kIOKitNFDefine(kIOKitKeyboardVolumeDecreaseNotification)
kIOKitNFDefine(kIOKitKeyboardHeadsetChangeNotification)
kIOKitNFDefine(kIOKitTemperatureNotification)//温度传感器
kIOKitNFDefine(kIOKitProximityNotification)//距离传感器
kIOKitNFDefine(kIOKitBiometricNotification)//生物识别
kIOKitNFDefine(kIOKitForceNotification)
kIOKitNFDefine(kIOKitUnknowNotification)


void handle_event(void* target, void* refcon, IOHIDEventQueueRef queue, IOHIDEventRef event);
static void SendHIDEvent(IOHIDEventRef event);

@implementation IOKitManager

+ (instancetype)manager{
    static IOKitManager * __manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[IOKitManager alloc] init];
    });
    
    return __manager;
}

- (void)registerServer{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *ioHIDEventSystem = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
        IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystem, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystem, handle_event, NULL, NULL);
    });
}
//测试无效
- (void)test{
#define kIOHIDEventFieldBuiltIn 4
#define kIOHIDEventFieldDigitizerDisplayIntegrated 720921
    IOHIDEventRef up1 = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 0xe9, YES, 0);
        //IOHIDEventSetIntegerValueWithOptions(event, kIOHIDEventFieldDigitizerDisplayIntegrated, 1, -268435456); //-268435456
        //IOHIDEventSetIntegerValueWithOptions(event, kIOHIDEventFieldBuiltIn, 1, -268435456); //-268435456
    IOHIDEventSetIntegerValue(up1,kIOHIDEventFieldBuiltIn, 1);
    SendHIDEvent(up1);

    sleep(1);
    IOHIDEventRef up2 = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 0xe9, NO, 0);
    IOHIDEventSetIntegerValue(up2,kIOHIDEventFieldBuiltIn, 1);
    SendHIDEvent(up2);

    sleep(1);
    IOHIDEventRef down1 = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 0xea, YES, 0);
    IOHIDEventSetIntegerValue(down1,kIOHIDEventFieldBuiltIn, 1);
    SendHIDEvent(down1);

    sleep(1);
    IOHIDEventRef down2 = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 0xea, NO, 0);
    IOHIDEventSetIntegerValue(down2,kIOHIDEventFieldBuiltIn, 1);
    SendHIDEvent(down2);

    sleep(1);
    IOHIDEventRef lock1 = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 0xe9, YES, 0);
    IOHIDEventSetIntegerValue(lock1,kIOHIDEventFieldBuiltIn, 1);
    SendHIDEvent(lock1);

    sleep(1);
    IOHIDEventRef lock2 = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 0xe9, NO, 0);
    IOHIDEventSetIntegerValue(lock2,kIOHIDEventFieldBuiltIn, 1);
    SendHIDEvent(lock2);
}
@end

static void handle_vendor_defined_event(IOHIDEventRef event){
//    uint32_t length = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldVendorDefinedDataLength);
//    IOHIDVendorDefinedEventData * data = IOHIDEventGetDataValue(event, kIOHIDEventFieldVendorDefinedData);
//    NSLog(@"%@",event);
    [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitVendorDefinedNotification object:nil];
//    NSMutableString * string = [NSMutableString string];
//    for (int i = 0; i<length; i++) {
//        uint8_t b = ((uint8_t*)data)[i];
//        if (b>=0x20 && b<0x7f) {
//            [string appendFormat:@"%c",b];
//        }
//        else{
//            [string appendFormat:@"."];
//        }
//    }
//    NSLog(@"vendor:%@",string);
}
//键盘输入 包括静音键 音量建 锁屏键
static void handle_keyboard_event(IOHIDEventRef event){
    uint32_t usage     = (uint32_t)IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage);
    uint32_t usagePage = (uint32_t)IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsagePage);
    uint32_t keyDown   = (uint32_t)IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown);
    uint32_t flags     = (uint32_t)IOHIDEventGetEventFlags(event);
    
    if (usage == 0x30 && usagePage == 12) {
        NSLog(@"电源键%@",keyDown?@"按下":@"抬起");
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardLockNotification object:nil userInfo:@{@"keyDown":@(keyDown)}];
    }
    else if (usage == 0xe9 && usagePage == 12) {
        NSLog(@"音量上键%@",keyDown?@"按下":@"抬起");
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardVolumeIncreaseNotification object:nil userInfo:@{@"keyDown":@(keyDown)}];
    }
    else if (usage == 0xea && usagePage == 12) {
        NSLog(@"音量下键%@",keyDown?@"按下":@"抬起");
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardVolumeDecreaseNotification object:nil userInfo:@{@"keyDown":@(keyDown)}];
    }
    else if (usage == 0x2e && usagePage == 11) {
        NSLog(@"铃声按钮%@",keyDown?@"打开":@"关闭");
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardRingerNotification object:nil userInfo:@{@"keyDown":@(keyDown)}];
    }
    else if (usage == 0x2d && usagePage == 11) {
        NSLog(@"多功能按钮%@",keyDown?@"按下":@"抬起");
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardFeatureNotification object:nil userInfo:@{@"keyDown":@(keyDown)}];
    }
    else if (usage == 1 && usagePage == 0xff07) {
        NSLog(@"耳机%@",keyDown?@"打开":@"关闭");
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardHeadsetChangeNotification object:nil userInfo:@{@"keyDown":@(keyDown)}];
    }
    else if (usage == 64 && usagePage == 0xff01) {
        NSLog(@"强制关机%@",keyDown?@"打开":@"关闭");
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardForcedShutdownNotification object:nil userInfo:@{@"keyDown":@(keyDown)}];
    }
    else if (usage == 64 && usagePage == 12) {
        NSLog(@"touch id %@",keyDown?@"打开":@"关闭");
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardTouchIdNotification object:nil userInfo:@{@"keyDown":@(keyDown)}];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitKeyboardNewNotification object:nil userInfo:@{@"usagePage":@(usagePage),@"usage":@(usage),@"keyDown":@(keyDown),@"flags":@(flags)}];
    }
    NSLog(@"usagePage:%d usage:0x%x keyDown:%d flags:%d",usagePage, usage, keyDown, flags);
}
//温度
static void handle_temperature_event(IOHIDEventRef event){
    float level = (float)IOHIDEventGetFloatValue(event, kIOHIDEventFieldTemperatureLevel);
    [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitTemperatureNotification object:nil userInfo:@{@"level":@(level)}];
}
//前摄像头位置距离传感器 远近会有不同
static void handle_proximity_event(IOHIDEventRef event){
    uint16_t mask = (uint16_t)IOHIDEventGetIntegerValue(event, kIOHIDEventFieldProximityDetectionMask);
    uint16_t level = (uint16_t)IOHIDEventGetIntegerValue(event, kIOHIDProximityProximityTypeLevel);
    uint16_t type = (uint16_t)IOHIDEventGetIntegerValue(event, kIOHIDProximityProximityLevel);
    NSLog(@"proximity -> type:%d level:%d mask:0x%x", type, level, mask);
    [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitProximityNotification object:nil userInfo:@{@"mask":@(mask),@"level":@(level),@"type":@(type)}];
}

static void handle_biometric_event(IOHIDEventRef event){
    uint16_t type = (uint16_t)IOHIDEventGetIntegerValue(event, kIOHIDEventFieldBiometricEventType);
    uint16_t level = (uint16_t)IOHIDEventGetIntegerValue(event, kIOHIDEventFieldBiometricLevel);
    NSLog(@"biometric -> type:%d level:%d ", type, level);
    [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitBiometricNotification object:nil userInfo:@{@"level":@(level),@"type":@(type)}];
}
static void handle_force_event(IOHIDEventRef event){
    uint32_t behavior = (uint32_t)IOHIDEventGetIntegerValue(event, kIOHIDEventFieldForceBehavior);
    float progress = (uint32_t)IOHIDEventGetFloatValue(event, kIOHIDEventFieldForceProgress);
    uint32_t stage = (uint32_t)IOHIDEventGetIntegerValue(event, kIOHIDEventFieldForceStage);
    float stageProgress = (uint32_t)IOHIDEventGetFloatValue(event, kIOHIDEventFieldForceStagePressure);
    NSLog(@"force -> ehavior:%d progress:%f stage:%d stageProgress:%f", behavior, progress, stage, stageProgress);
    [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitForceNotification
                                                        object:nil
                                                      userInfo:@{@"behavior":@(behavior),@"progress":@(progress),@"stage":@(stage),@"stageProgress":@(stageProgress)}];
}
//https://theapplewiki.com/wiki/Dev:IOHIDFamily
void handle_event(void* target, void* refcon, IOHIDEventQueueRef queue, IOHIDEventRef event){
    IOHIDEventType etype = IOHIDEventGetType(event);
    switch (etype) {
        case kIOHIDEventTypeVendorDefined:
            handle_vendor_defined_event(event);
            break;
        case kIOHIDEventTypeKeyboard:
            handle_keyboard_event(event);
            break;
        case kIOHIDEventTypeTemperature:
            handle_temperature_event(event);
            break;
        case kIOHIDEventTypeProximity:
            handle_proximity_event(event);
            break;
        case kIOHIDEventTypeBiometric:
            handle_biometric_event(event);
            break;;
        case kIOHIDEventTypeForce:
            handle_force_event(event);
            break;;
        default:
            [[NSNotificationCenter defaultCenter] postNotificationName:kIOKitUnknowNotification object:nil userInfo:@{@"type":@(etype)}];
            break;
    }
}

//发送没反应
extern void IOHIDEventSetSenderID(IOHIDEventRef, uint64_t);
extern void IOHIDEventSystemClientDispatchEvent(IOHIDEventSystemClientRef, IOHIDEventRef);
static void SendHIDEvent(IOHIDEventRef event) {
    static IOHIDEventSystemClientRef client_ = NULL;
    if (client_ == NULL)
        client_ = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    
    IOHIDEventSetSenderID(event, 0xDEFACEDBEEFFECE5);
    IOHIDEventSystemClientDispatchEvent(client_, event);
    CFRelease(event);
    NSLog(@"send");
}
