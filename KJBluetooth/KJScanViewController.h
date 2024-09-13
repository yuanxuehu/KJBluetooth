//
//  KJScanViewController.h
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import <UIKit/UIKit.h>

@interface KJScanViewController : UIViewController

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

