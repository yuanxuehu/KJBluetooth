//
//  KJBLEProtocol.m
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import "KJBLEProtocol.h"

@implementation KJBLEProtocol

+ (NSString *)protocolWithConfigDeviceWiFi:(NSString *)ssid password:(NSString *)password token:(NSString *)token requestID:(NSInteger)requestID
{
    NSString *baseSSID = [[ssid dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    NSString *basePasswprd = [[password dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];;
    NSDictionary *dict = @{
                           @"ver":@1,
                           @"id":@(requestID),
                           @"method":@"putInfo",
                           @"params":@{
                                   @"mode":@"WEP",
                                   @"token":token ?: @"",
                                   @"ssid":baseSSID,
                                   @"pass":basePasswprd
                                   }
                           };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)protocolWithScanNearAPsWithRequestID:(NSInteger)requestID
{
    NSDictionary *dict = @{
                           @"ver":@1,
                           @"id":@(requestID),
                           @"method":@"getNearAp"
                           };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}


@end
