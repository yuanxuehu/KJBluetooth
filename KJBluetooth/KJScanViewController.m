//
//  KJScanViewController.m
//  KJBluetooth
//
//  Created by TigerHu on 2024/9/13.
//

#import "KJScanViewController.h"

@interface KJScanViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;

@end

@implementation KJScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 50)];
    _headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_headerView];
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"选择蓝牙外设";
    textLabel.font = [UIFont systemFontOfSize:16];
    textLabel.textColor = [UIColor grayColor];
    [_headerView addSubview:textLabel];
    textLabel.frame = CGRectMake(10, 70, self.view.bounds.size.width-20, 50);
    
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    [_headerView addSubview:loadingView];
    loadingView.frame = CGRectMake(160, 75, 40, 40);
    [loadingView startAnimating];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:line];
    line.frame = CGRectMake(0, 119.5, self.view.bounds.size.width, 0.5);
    
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, self.view.bounds.size.height-200) style:UITableViewStyleGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.backgroundColor = [UIColor clearColor];
    self.table.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    [self.view addSubview:self.table];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cid = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cid];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
