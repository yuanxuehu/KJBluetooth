//
//  ViewController.m
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import "ViewController.h"
#import "KJBLEViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *clickButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.clickButton];
    self.clickButton.frame = CGRectMake(20, self.view.frame.size.height/2, self.view.frame.size.width-40, 40);
  
}

- (void)click {
    KJBLEViewController *vc = [[KJBLEViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

- (UIButton *)clickButton {
    if (!_clickButton) {
        _clickButton = [[UIButton alloc] init];
        [_clickButton setTitle:@"点击跳转蓝牙页面" forState:UIControlStateNormal];
        [_clickButton setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
        [_clickButton addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _clickButton;
}


@end
