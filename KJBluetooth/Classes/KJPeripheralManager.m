//
//  KJPeripheralManager.m
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import "KJPeripheralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "KJBLEProtocol.h"
#import "KJBLEConfigManager.h"

#define BLE_SEND_MAX_LEN 20
//跟蓝牙设备约定好的id
#define BLE_SEND_WiFi_ID 10001 //发送蓝牙设备配网
#define BLE_SEND_APs_ID 10002 //获取周边wifi列表

@interface KJPeripheralManager () <CBPeripheralDelegate>
{
    KJPeripheralManagerSendDateBlock _sendDataBlock;
    NSMutableData *_tempData;
    KJPeripheralManagerSendDataCompletion _completionBlock;
}

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@end

@implementation KJPeripheralManager

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
{
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        [self.peripheral addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context: nil];
    }
    return self;
}

- (void)connect
{
    [[KJBLEConfigManager manager].centralManager connectPeripheral:self.peripheral options:nil];
}

- (void)disconnect
{
    [[KJBLEConfigManager manager].centralManager cancelPeripheralConnection:self.peripheral];
}

- (void)sendMsgWithSubPackage:(NSData*)msgData
{
    for (int i = 0; i < [msgData length]; i += BLE_SEND_MAX_LEN) {
        // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
        if ((i + BLE_SEND_MAX_LEN) < [msgData length]) {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, BLE_SEND_MAX_LEN];
            NSData *subData = [msgData subdataWithRange:NSRangeFromString(rangeStr)];
            //WriteWithoutResponse
            [self.peripheral writeValue:subData forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
        } else {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([msgData length] - i)];
            NSData *subData = [msgData subdataWithRange:NSRangeFromString(rangeStr)];
            //关键点：WriteWithResponse写完数据需蓝牙设备回调通知回来
            [self.peripheral writeValue:subData forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        
        //根据接收模块的处理能力做相应延时
        usleep(20 * 1000);
    }
}

/**
 给蓝牙发送信息

 @param dataString 信息内容
 @param completion 信息是否发送成功
 @param response 设备回复内容
 */
- (void)sendDataString:(NSString *)dataString Completion:(KJPeripheralManagerSendDataCompletion)completion Response:(KJPeripheralManagerSendDateBlock)response
{
    if (!self.writeCharacteristic) {
        completion(NO);
        return;
    }
    _sendDataBlock = response;
    _completionBlock = completion;
    _tempData = [NSMutableData data];
    NSString *msg =  [dataString stringByAppendingString:@"\r\n"];
    [self sendMsgWithSubPackage:[msg dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)sendWiFiWithSSID:(NSString *)ssid
                Password:(NSString *)password
                   Token:(NSString *)token
              Completion:(KJPeripheralManagerSendDataCompletion)completion
                Response:(KJPeripheralManagerSendDateBlock)response
{
    NSString *msg = [KJBLEProtocol protocolWithConfigDeviceWiFi:ssid password:password token:token requestID:BLE_SEND_WiFi_ID];
    [self sendDataString:msg Completion:completion Response:response];
}

- (void)sendScanAPs:(KJPeripheralManagerSendDataCompletion)completion
           Response:(KJPeripheralManagerSendDateBlock)response
{
    NSString *msg = [KJBLEProtocol protocolWithScanNearAPsWithRequestID:BLE_SEND_APs_ID];
    [self sendDataString:msg Completion:completion Response:response];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CBPeripheral *peripheral = object;
    
    switch (peripheral.state) {
        case CBPeripheralStateConnecting:
        {
            if (self.stateBlock) {
                self.stateBlock(self.peripheral, KJPeripheralManagerStateConnecting);
            }
        }
            break;
            
        case CBPeripheralStateConnected:
        {
            //开始搜素蓝牙服务，跟蓝牙设备约定好的服务
            [peripheral discoverServices:ServiceUUIDs];
            if (self.stateBlock) {
                self.stateBlock(self.peripheral, KJPeripheralManagerStateDiscoverServices);
            }
        }
            break;
            
        case CBPeripheralStateDisconnected:
        {
            if (self.stateBlock) {
                self.stateBlock(self.peripheral, KJPeripheralManagerStateDisconnect);
            }
        }
            break;
            
        case CBPeripheralStateDisconnecting:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - CBPeripheralDelegate
#pragma mark - didDiscoverServices 发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    //APP跟蓝牙设备约定好的两个特征
    NSArray *arr = @[
                     [CBUUID UUIDWithString:WriteUUID],
                     [CBUUID UUIDWithString:NotificationUUID],
                     ];
    //开始搜索特征
    [peripheral discoverCharacteristics:arr forService:peripheral.services.firstObject];
    if (self.stateBlock) {
        self.stateBlock(self.peripheral, KJPeripheralManagerStateDiscoverCharacteristics);
    }
}

#pragma mark - didDiscoverCharacteristics 发现特征

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    self.writeCharacteristic = nil;
    CBCharacteristic *notificationCharacteristic;
    
    //遍历服务里边的特征
    for (CBCharacteristic *chara in service.characteristics) {
        if ([chara.UUID.UUIDString isEqualToString:WriteUUID]) {
            self.writeCharacteristic = chara;
        } else if ([chara.UUID.UUIDString isEqualToString:NotificationUUID]) {
            notificationCharacteristic = chara;
        }
    }
    
    //判断writeCharacteristic和notificationCharacteristic都有值（写特征和特征回调通知）
    if (self.writeCharacteristic && notificationCharacteristic) {
        //订阅Characteristic通知
        [peripheral setNotifyValue:YES forCharacteristic:notificationCharacteristic];
        //绑定特征回调通知
        if (self.stateBlock) {
            self.stateBlock(self.peripheral, KJPeripheralManagerStateBindNotification);
        }
    } else {
        if (self.stateBlock) {
            self.stateBlock(self.peripheral, KJPeripheralManagerStateDiscoverCharacteristicsFail);
        }
    }
}

#pragma mark - didUpdateNotificationStateForCharacteristic 特征回调通知
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (characteristic.isNotifying) {
        //准备完成
        if (self.stateBlock) {
            self.stateBlock(self.peripheral, KJPeripheralManagerStateReady);
        }
    } else {
        if (self.stateBlock) {
            self.stateBlock(self.peripheral, KJPeripheralManagerStateBindNotificationFail);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (![characteristic.UUID.UUIDString isEqualToString:NotificationUUID]) {
        return;
    }
    
    if (!_tempData) { //为空，初始化
        _tempData = [NSMutableData data];
    }
    [_tempData appendData:characteristic.value];
    NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:_tempData options:0 error:nil];
    if (!json) {
        return;
    }
    
    if (_sendDataBlock) {
        _sendDataBlock(_tempData);
        _sendDataBlock = nil;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (_completionBlock) {
        if (error) {
            _completionBlock(NO);
        } else {
            _completionBlock(YES);
        }
    }
}

- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral
{
//    if (_completionBlock) {
//        _completionBlock(YES);
//    }
}



- (NSString *)deviceID
{
    //截取某位字符串作为设备id
    if ([self.peripheral.name hasPrefix:@"XXX"] && self.peripheral.name.length > 3) {
        return [self.peripheral.name substringFromIndex:3];
    }
    return nil;
}

- (void)dealloc {
    [self.peripheral removeObserver:self forKeyPath:@"state"];
    NSLog(@"%s",__func__);
}

@end
