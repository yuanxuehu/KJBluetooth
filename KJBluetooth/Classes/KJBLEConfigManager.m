//
//  KJBLEConfigManager.m
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import "KJBLEConfigManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString *const kKJBLEConfigManagerStateChangedNotification = @"KJBLEConfigManagerStateChangedNotification";

@interface KJBLEConfigManager ()<CBCentralManagerDelegate>
{
    
}
@end

@implementation KJBLEConfigManager

+ (KJBLEConfigManager *)manager
{
    static KJBLEConfigManager *singleInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        singleInstance = [[self alloc] init];
    });
    return singleInstance;
}

- (void)setupBlueTool
{
    //不向用户显示警告对话框
    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@NO};
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    //搜索到的蓝牙设备，通知出去
    [[NSNotificationCenter defaultCenter] postNotificationName:kKJBLEConfigManagerStateChangedNotification object:central];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (self.peripheralStateChangedBlock) {
        self.peripheralStateChangedBlock(peripheral,nil);
    }
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (self.peripheralStateChangedBlock) {
        self.peripheralStateChangedBlock(peripheral,error);
    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    if (self.peripheralStateChangedBlock) {
        self.peripheralStateChangedBlock(peripheral,error);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    //过滤掉name为空的蓝牙设备
    if (!peripheral.name || peripheral.name.length == 0) {
        return;
    }
    
    //过滤掉不是我们的蓝牙设备
//    if (![peripheral.name hasPrefix:@"XXX"]) {
//        return;
//    }
    
    if (self.discoverPeripheralBlock) {
        self.discoverPeripheralBlock(peripheral, advertisementData, RSSI);
    }
}

@end
