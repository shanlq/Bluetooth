//
//  ViewController.m
//  test
//
//  Created by apple on 17/8/10.
//  Copyright © 2017年 slq. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBPeripheralManagerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) CBPeripheralManager *manager;

@property (nonatomic, strong) UILabel *showLab;
@property (nonatomic, strong) UITextField *tf;
@property (nonatomic, strong) UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tf];
    [self.view addSubview:self.btn];
    [self.view addSubview:self.showLab];
    
    //外设模式
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    CBPeripheralManager *manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:nil];
    
    NSLog(@"%lu, %d", sizeof(_tf.text), (int)_tf.text.length);
}

#pragma mark CBPeripheralMangerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
        {
            NSLog(@"蓝牙已打开");
            _showLab.text = @"蓝牙已打开";
            break;
        }
        case CBManagerStatePoweredOff:
            _showLab.text = @"未打开蓝牙，生成的广播无效";
            break;
        default:
            break;
    }
}

//perihpheral添加了service
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error == nil) {
        NSLog(@"外设成功创建并开始广播数据");
        
        [_manager stopAdvertising];
        [_manager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@"F2F3"]],CBAdvertisementDataLocalNameKey : [NSString stringWithFormat:@"SGD-%@", _tf.text]}
         ];
    }
    else
        NSLog(@"蓝牙设备添加服务失败，%@", error);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"手机正在发送广播" message:[NSString stringWithFormat:@"显示名称是%@%@", @"SGD-",_tf.text] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark getter
-(UITextField *)tf
{
    if(!_tf)
    {
        _tf = [[UITextField alloc] initWithFrame:CGRectMake(50, 60, 200, 40)];
        _tf.placeholder = @"请输入要广播的名称";
        _tf.textColor = [UIColor blackColor];
        _tf.font = [UIFont systemFontOfSize:16];
        _tf.layer.borderWidth = 1.0;
        _tf.text = @"iM/uGKUkEmhgB0vy+zaNse5XL+Jc7ftDziah7OHcA/1/BSqw+GK+j1ofKHTJh3Eu";
        _tf.layer.borderColor = [[UIColor blackColor] CGColor];
        _tf.delegate = self;
    }
    return _tf;
}

-(UILabel *)showLab
{
    if(!_showLab)
    {
        _showLab = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(_btn.frame) + 40, 250, 60)];
        _showLab.textColor = [UIColor blackColor];
    }
    return _showLab;
}

-(UIButton *)btn
{
    if(!_btn)
    {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(100, CGRectGetMaxY(_tf.frame) + 20, 100, 40);
        [_btn setTitle:@"发送广播" forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn setBackgroundColor:[UIColor blueColor]];
        [_btn addTarget:self action:@selector(Click) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

#pragma mark Touch Event
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _tf.text = nil;
    return YES;
}

-(void)Click
{
        //根据特定的“特征”、“服务”创建外设对象
        CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"FFF1"] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:@"F9F7"] primary:YES];
        [service1 setCharacteristics:@[notiyCharacteristic]];
    [_manager addService:service1];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_tf resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
