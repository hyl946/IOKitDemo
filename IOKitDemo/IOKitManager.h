//
//  IOKitManager.h
//  IOKitDemo
//
//  Created by yl.han on 2024/9/12.
//

#import <Foundation/Foundation.h>

#define IOKitExternDefine(kIOKitNotification) extern NSString * _Nonnull kIOKitNotification;
IOKitExternDefine(kIOKitVendorDefinedNotification)//厂商定义
IOKitExternDefine(kIOKitKeyboardNewNotification)
IOKitExternDefine(kIOKitKeyboardRingerNotification)
IOKitExternDefine(kIOKitKeyboardFeatureNotification)
IOKitExternDefine(kIOKitKeyboardLockNotification)
IOKitExternDefine(kIOKitKeyboardForcedShutdownNotification)
IOKitExternDefine(kIOKitKeyboardTouchIdNotification)
IOKitExternDefine(kIOKitKeyboardVolumeIncreaseNotification)
IOKitExternDefine(kIOKitKeyboardVolumeDecreaseNotification)
IOKitExternDefine(kIOKitKeyboardHeadsetChangeNotification)
IOKitExternDefine(kIOKitTemperatureNotification)//温度传感器
IOKitExternDefine(kIOKitProximityNotification)//距离传感器
IOKitExternDefine(kIOKitBiometricNotification)
IOKitExternDefine(kIOKitForceNotification)
IOKitExternDefine(kIOKitUnknowNotification)


NS_ASSUME_NONNULL_BEGIN

@interface IOKitManager : NSObject

+ (instancetype)manager;
- (void)registerServer;

- (void)test;

@end

NS_ASSUME_NONNULL_END
