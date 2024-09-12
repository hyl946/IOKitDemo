//
//  ViewController.m
//  IOKitDemo
//
//  Created by yl.han on 2024/9/12.
//

#import "ViewController.h"
#import "IOKitManager.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray <UILabel *>* labels;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[IOKitManager manager] registerServer];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 40);
    button.center = CGPointMake(self.view.center.x, 600);
    [button setTitle:@"测试" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.labels = [NSMutableArray array];
    int height = 100;
    for (int i = 0; i<15; i++,height+=40) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, height, self.view.frame.size.width-30, 30)];
        [self.view addSubview:label];
        [self.labels addObject:label];
    }
    __block int index = 0;
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitVendorDefinedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        self.labels[0].text = [NSString stringWithFormat:@"接收到VendorDefined %d",index++];
        [self.labels[0] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardNewNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[1].text = [NSString stringWithFormat:@"kb %@ %@ %@ %@",info[@"usagePage"],info[@"usage"],info[@"keyDown"],info[@"flags"]];
        [self.labels[1] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardNewNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[2].text = [NSString stringWithFormat:@"强制关机%@",[info[@"keyDown"] boolValue] ? @"打开":@"关闭"];
        [self.labels[2] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitBiometricNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[2].text = [NSString stringWithFormat:@"生物识别type:%@ level:%@",info[@"type"],info[@"level"]];
        [self.labels[2] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardRingerNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[2].text = [NSString stringWithFormat:@"铃声%@",[info[@"keyDown"] boolValue] ? @"打开":@"关闭"];
        [self.labels[2] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardFeatureNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[2].text = [NSString stringWithFormat:@"多功能按键%@",[info[@"keyDown"] boolValue] ? @"打开":@"关闭"];
        [self.labels[2] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardLockNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[3].text = [NSString stringWithFormat:@"电源键%@",[info[@"keyDown"] boolValue] ? @"按下":@"抬起"];
        [self.labels[3] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardTouchIdNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[3].text = [NSString stringWithFormat:@"touch id键%@",[info[@"keyDown"] boolValue] ? @"按下":@"抬起"];
        [self.labels[3] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardVolumeIncreaseNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[4].text = [NSString stringWithFormat:@"音量上键%@",[info[@"keyDown"] boolValue] ? @"按下":@"抬起"];
        [self.labels[4] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardVolumeDecreaseNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[5].text = [NSString stringWithFormat:@"音量下键%@",[info[@"keyDown"] boolValue] ? @"按下":@"抬起"];
        [self.labels[5] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitKeyboardHeadsetChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[6].text = [NSString stringWithFormat:@"耳机%@",[info[@"keyDown"] boolValue] ? @"按下":@"抬起"];
        [self.labels[6] layoutIfNeeded];
    }];
    
    __block double last_wd = 0;
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitTemperatureNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        double level = [info[@"level"] doubleValue];
        if (last_wd == 0) {
            last_wd = level;
        }
        if (fabs(level-last_wd) < 2) {
            last_wd = level;
        }
        
        self.labels[7].text = [NSString stringWithFormat:@"当前温度%f",last_wd];
        [self.labels[7] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitProximityNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[8].text = [NSString stringWithFormat:@"proximity type:%@ mask:%@ level:%@",info[@"type"],info[@"mask"],info[@"level"]];
        [self.labels[8] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitForceNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[9].text = [NSString stringWithFormat:@"force Behavior:%@ Progress:%@ Stage:%@ StageProgress:%@",info[@"behavior"],info[@"progress"],info[@"stage"],info[@"stageProgress"]];
        [self.labels[9] layoutIfNeeded];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kIOKitUnknowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSDictionary * info = notification.userInfo;
        self.labels[10].text = [NSString stringWithFormat:@"未知类型:%@",info[@"type"]];
        [self.labels[10] layoutIfNeeded];
    }];
}

- (void)test{
    [[IOKitManager manager] test];
}
@end
