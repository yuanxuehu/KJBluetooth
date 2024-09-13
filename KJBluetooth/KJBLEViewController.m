//
//  KJBLEViewController.m
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import "KJBLEViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "KJBLEConfigManager.h"
#import "KJPeripheralManager.h"

@interface KJAddDeviceWiFiItem : NSObject
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, assign) NSInteger rssi;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) BOOL selectStatus;

+ (instancetype)itemWithSSID:(NSString *)ssid RSSI:(NSInteger)rssi;
@end

@implementation KJAddDeviceWiFiItem

+ (instancetype)itemWithSSID:(NSString *)ssid RSSI:(NSInteger)rssi
{
    KJAddDeviceWiFiItem *item = [[KJAddDeviceWiFiItem alloc]init];
    item.ssid = ssid;
    item.rssi = rssi;
    item.password = @"";
    return item;
}

@end


@interface KJBLEViewController ()

@property (nonatomic, strong) KJPeripheralManager *selectedPeripheral;
@property (nonatomic, assign) BOOL isConnecting; //正在连接中不让点击设备id再去连接

@property (nonatomic, strong) NSMutableArray *wifiArr;



@end

@implementation KJBLEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"蓝牙扫描";
    self.view.backgroundColor = UIColor.whiteColor;
    self.isConnecting = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bleConfigManagerNotice:) name:kKJBLEConfigManagerStateChangedNotification object:nil];
    
    __weak typeof(self)ws = self;
    //发现外设
    [KJBLEConfigManager manager].discoverPeripheralBlock = ^(CBPeripheral *peripheral, NSDictionary<NSString *,id> *advertisement, NSNumber *RSSI) {
        
        NSLog(@"[BLE]peripheral.name=%@",peripheral.name);
        
        //去重
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.selectedPeripheral) {
        [self.selectedPeripheral disconnect];
    }
    
    //蓝牙第一步
    //初始化CBCentralManager,建立中心角色，遵循其Delegate
    [[KJBLEConfigManager manager] setupBlueTool];
}

- (void)_bleConfigManagerNotice:(NSNotification *)sender
{
    CBCentralManager *centralManager = sender.object;
    if (centralManager.state == CBManagerStatePoweredOn) {//只处理活跃状态下的蓝牙设备
        //1、开始搜索蓝牙设备
        [[KJBLEConfigManager manager].centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cid = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cid];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cid];
        cell.imageView.image = [UIImage imageNamed:@"icon_bluetooth"];
    }
    CBPeripheral *per = [self.dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text = per.name;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isConnecting) { //正在连接
        return;
    }
    
    //[MBProgressHUD showForController:self];
    
    //选中其中一个外设进行连接
    self.selectedPeripheral = [[KJPeripheralManager alloc] initWithPeripheral:[self.dataArr objectAtIndex:indexPath.row]];
    
    __weak typeof(self)ws = self;
    self.selectedPeripheral.stateBlock = ^(CBPeripheral *peripheral, KJPeripheralManagerState state) {
        //3、发现设备服务
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[BLE]连接蓝牙状态--%lu",(unsigned long)state);
            if (state == KJPeripheralManagerStateReady) {//准备完成
                ws.isConnecting = NO;
                //[MBProgressHUD dismissForController:ws];
                [ws getWifiListFromBluetoothDevive];
            } else if (state == KJPeripheralManagerStateConnecting ||
                     state == KJPeripheralManagerStateDiscoverServices ||
                     state == KJPeripheralManagerStateDiscoverCharacteristics ||
                     state == KJPeripheralManagerStateBindNotification) {
                //[MBProgressHUD showInfoWithStatus:@"设备连接中..." forController:ws];
            } else if (state == KJPeripheralManagerStateDisconnect) {
                //[MBProgressHUD showInfoWithStatus:@"设备断开连接" forController:ws];
                ws.isConnecting = NO;
            } else {
                //[MBProgressHUD showInfoWithStatus:@"设备连接失败" forController:ws];
                ws.isConnecting = NO;
            }
        });
    };
    //2、连接蓝牙设备
    [self.selectedPeripheral connect];
    self.isConnecting = YES;
}

- (void)getWifiListFromBluetoothDevive {
    //4、从蓝牙设备获取wifi列表，需给蓝牙设备配网，指定某个WiFi
    __weak typeof(self)ws = self;
    
    [self.selectedPeripheral sendScanAPs:^(BOOL success) {
        
    } Response:^(NSData *response) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        if (json) {
            [ws p_setupData:json];
        }
    }];
}

- (void)p_setupData:(NSDictionary *)json
{
    [self.wifiArr removeAllObjects];
    NSArray *wifis = json[@"params"];
    for (NSDictionary *item in wifis) {
        //base64解码
        NSString *ssidStr = [item objectForKey:@"ssid"];
        NSData *data = [[NSData alloc]initWithBase64EncodedString:ssidStr options:0];
        NSString *ssidString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *ssid = ssidString;
        NSInteger rssi = [[item objectForKey:@"rssi"] integerValue];
        //过滤特定前缀蓝牙名
        if ([ssid hasPrefix:@"XXX"]) {
            continue;
        }
        [self.wifiArr addObject:[KJAddDeviceWiFiItem itemWithSSID:ssid RSSI:rssi]];
    }
}


- (void)p_sendWiFi {
    //5、从wifiArr数组选中其中一个WiFi，向蓝牙设备发起配网请求
    
    __weak typeof(self)ws = self;
    //NSLog(@"[BLE]发送SSID:%@, Password:%@",self.WiFiSSID,self.WiFiPassword);
    [self.selectedPeripheral sendWiFiWithSSID:@"WiFiSSID" Password:@"WiFiPassword" Token:@"" Completion:^(BOOL success) {
        NSLog(@"[BLE]SSID发送成功");
    } Response:^(NSData *response) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"[BLE]设备回复->%@",json);
        //使用完，断开蓝牙设备连接
        ws.selectedPeripheral.stateBlock = nil;
        [ws.selectedPeripheral disconnect];
        
        [ws p_waitCheckNetworkDismiss];
    }];
}

- (void)p_waitCheckNetworkDismiss {
    
    //6、检测当前手机连接的网络,跟选中的wifi一致则为局域网，否则为广域网
    
    //7、连接设备验证设备联网结果
    
    //补充：如果蓝牙设备配网成功，一般手机会自动连接到选中的wifi
    
}


- (NSMutableArray *)wifiArr
{
    if (!_wifiArr) {
        _wifiArr = [NSMutableArray array];
    }
    return _wifiArr;
}

@end
