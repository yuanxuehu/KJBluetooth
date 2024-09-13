//
//  JABLEViewController.m
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import "KJBLEViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "KJBLEConfigManager.h"
#import "KJPeripheralManager.h"

@interface JABLEViewController ()

@end

@implementation JABLEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"蓝牙扫描";
    
    
    __weak typeof(self)ws = self;
    [KJBLEConfigManager manager].discoverPeripheralBlock = ^(CBPeripheral *peripheral, NSDictionary<NSString *,id> *advertisement, NSNumber *RSSI) {
        NSLog(@"[BLE]peripheral.name=%@",peripheral.name);
        BOOL isRepetition = NO;
        for (CBPeripheral *ral in ws.dataArr) {
            if ([ral.name isEqualToString:peripheral.name]) {
                isRepetition = YES;
                break;
            }
        }
        if (!isRepetition) {
            [ws.dataArr addObject:peripheral];
            [ws.table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:ws.dataArr.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
    };
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[KJBLEConfigManager manager].centralManager stopScan];
    [self.dataArr removeAllObjects];
    [self.table reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cid = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cid];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cid];
        cell.imageView.image = [UIImage imageNamed:@"icon_add_bluetooth"];
    }
    CBPeripheral *per = [self.dataArr objectAtIndex:indexPath.row];
    NSString *eseeID = [per.name substringFromIndex:per.name.length-10];
    if ([[eseeID substringToIndex:1] integerValue] == 0) {
        eseeID = [eseeID substringFromIndex:1];
    }
    cell.textLabel.text = eseeID;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    //已添加的设备
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eseeid == %@", eseeID];
//    NSArray *filteredArray = [self.deviceList filteredArrayUsingPredicate:predicate];
//    cell.textLabel.textColor = filteredArray.count>0?[UIColor grayColor]:[UIColor c3_Color];

    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *per = [self.dataArr objectAtIndex:indexPath.row];
    NSString *eseeID = [per.name substringFromIndex:per.name.length-10];
    if ([[eseeID substringToIndex:1] integerValue] == 0) {
        eseeID = [eseeID substringFromIndex:1];
    }
    
//    //已添加的设备
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eseeid == %@", eseeID];
//    NSArray *filteredArray = [self.deviceList filteredArrayUsingPredicate:predicate];
//    if(filteredArray.count>0){
//        [MBProgressHUD showInfoWithStatus:[NSString ja_existDeviceID] forController:self];
//        return;
//    }
//
//    if (self.isConnecting) { //正在连接
//        return;
//    }
//    [MBProgressHUD showForController:self];
//    self.selectedPeripheral = [[JAPeripheralManager alloc] initWithPeripheral:[self.dataArr objectAtIndex:indexPath.row]];
//    __weak typeof(self)ws = self;
//    self.selectedPeripheral.stateBlock = ^(CBPeripheral *peripheral, JAPeripheralManagerState state) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            JACLog(@"[BLE]连接蓝牙状态--%lu",(unsigned long)state);
//            if (state == JAPeripheralManagerStateReady) {
//                ws.isConnecting = NO;
//                [MBProgressHUD dismissForController:ws];
//                JAAddDeviceBLEInputWiFiViewController *vc = [[JAAddDeviceBLEInputWiFiViewController alloc] init];
//                vc.peripheralManager = ws.selectedPeripheral;
//                vc.deviceID = ws.selectedPeripheral.deviceID;
//                [ws.navigationController pushViewController:vc animated:YES];
//            }
//            else if (state == JAPeripheralManagerStateConnecting || state == JAPeripheralManagerStateDiscoverServices || state == JAPeripheralManagerStateDiscoverCharacteristics ||  state == JAPeripheralManagerStateBindNotification){
//                [MBProgressHUD showInfoWithStatus:[NSString ja_deviceConnecting] forController:ws];
//            }else if (state == JAPeripheralManagerStateDisconnect){
//                [MBProgressHUD showInfoWithStatus:[NSString ja_deviceDisconnect] forController:ws];
//                [ws popBLEConnectBreakOffAlert:[NSString ja_deviceDisconnect]];
//                ws.isConnecting = NO;
//            }else{
//                [MBProgressHUD showInfoWithStatus:[NSString ja_deviceConnectFail] forController:ws];
//                [ws popBLEConnectBreakOffAlert:[NSString ja_deviceConnectFail]];
//                ws.isConnecting = NO;
//            }
//        });
//    };
//    [self.selectedPeripheral connect];
//    self.isConnecting = YES;
}

@end
