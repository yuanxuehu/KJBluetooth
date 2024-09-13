//
//  KJPeripheralManager.h
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import <Foundation/Foundation.h>

//约定好，需要用到设备的蓝牙服务
#define ServiceUUIDs @[\
    [CBUUID UUIDWithString:@"12345678-FE7D-4AE5-ABCD-9ABCD205E453"]\
]
///需要用到设备的2个特征
//写入信息特征
#define WriteUUID @"12345678-8841-43F4-A8D4-ABCD34729BB1"
//设备回调特征
#define NotificationUUID @"12345678-1E4D-ABCD-BA61-23C647249611"

typedef NS_ENUM(NSUInteger, KJPeripheralManagerState) {
    KJPeripheralManagerStateNone                        = 0,
    KJPeripheralManagerStateConnecting                  = 1,//连接中
    KJPeripheralManagerStateDiscoverServices            = 2,//搜索服务中
    KJPeripheralManagerStateDiscoverCharacteristics     = 3,//搜索特征中
    KJPeripheralManagerStateBindNotification            = 4,//绑定回调通知
    KJPeripheralManagerStateReady                       = 5,//准备完成
    KJPeripheralManagerStateConnectFail                 = 6,//连接失败
    KJPeripheralManagerStateDiscoverServicesFail        = 7,//搜索服务失败
    KJPeripheralManagerStateDiscoverCharacteristicsFail = 8,//搜索特征失败
    KJPeripheralManagerStateBindNotificationFail        = 9,//绑定回调通知失败
    KJPeripheralManagerStateDisconnect                  = 10//断开连接
};

@class KJPeripheralManager;
@class CBPeripheral;

typedef void(^KJPeripheralManagerSendDateBlock)(NSData *response);
typedef void(^KJPeripheralManagerStateBlock)(CBPeripheral *peripheral,KJPeripheralManagerState state);
typedef void(^KJPeripheralManagerSendDataCompletion)(BOOL success);

@interface KJPeripheralManager : NSObject
//外设
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, assign) KJPeripheralManagerState state;//当前手机和蓝牙设备之间的状态
@property (nonatomic, copy) KJPeripheralManagerStateBlock stateBlock;//外设状态改变回调block

@property (nonatomic, strong, readonly) NSString *deviceID;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

//连接蓝牙设备
- (void)connect;

//断开蓝牙设备
- (void)disconnect;


/**
 发送配网信息
 
 @param ssid 配置网络的WiFi名称
 @param password 配置网络的WiFi密码
 @param token 独占时的用户token
 @param completion 信息是否发送成功
 @param response 设备回复内容
 */
- (void)sendWiFiWithSSID:(NSString *)ssid
                Password:(NSString *)password
                   Token:(NSString *)token
              Completion:(KJPeripheralManagerSendDataCompletion)completion
                Response:(KJPeripheralManagerSendDateBlock)response;

/**
 发送获取周围AP信息
 
 @param completion 信息是否发送成功
 @param response 设备回复内容
 */
- (void)sendScanAPs:(KJPeripheralManagerSendDataCompletion)completion
           Response:(KJPeripheralManagerSendDateBlock)response;

@end
