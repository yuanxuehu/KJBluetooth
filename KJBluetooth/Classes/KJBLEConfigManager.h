//
//  KJBLEConfigManager.h
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import <Foundation/Foundation.h>

extern NSString *const kKJBLEConfigManagerStateChangedNotification;

@class CBPeripheral;
@class CBCentralManager;

typedef void(^KJBLEConfigManagerDiscoverPeripheralBlock)(CBPeripheral *peripheral,NSDictionary<NSString *, id> *advertisement, NSNumber *RSSI);
typedef void(^KJBLEConfigManagerPeripheralStateChangedBlock)(CBPeripheral *peripheral, NSError *error);

@interface KJBLEConfigManager : NSObject
//中心管理者
@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) KJBLEConfigManagerDiscoverPeripheralBlock discoverPeripheralBlock;
@property (nonatomic, strong) KJBLEConfigManagerPeripheralStateChangedBlock peripheralStateChangedBlock;

+ (KJBLEConfigManager *)manager;

- (void)setupBlueTool;

@end
