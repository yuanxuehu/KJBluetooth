//
//  KJBLEProtocol.h
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import <Foundation/Foundation.h>

@interface KJBLEProtocol : NSObject

+ (NSString *)protocolWithConfigDeviceWiFi:(NSString *)ssid password:(NSString *)password token:(NSString *)token requestID:(NSInteger)requestID;
+ (NSString *)protocolWithScanNearAPsWithRequestID:(NSInteger)requestID;

@end
