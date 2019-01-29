//
//  SecondViewController.m
//  test
//
//  Created by apple on 17/8/19.
//  Copyright © 2017年 slq. All rights reserved.
//

#import "SecondViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SecondViewController ()<CBPeripheralManagerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *imgUp;
@property (nonatomic, strong) UIImageView *imgDown;
@property (nonatomic, strong) UILabel *showLab;
@property (nonatomic, strong) UIButton *timeBtn;
//@property (nonatomic, strong) UIButton *contentBtn;
@property (nonatomic, strong) UITextField *timeTF;
@property (nonatomic, strong) UITextField *contentTF;

@property (nonatomic, strong) CBPeripheralManager *manager;

@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic, strong) NSString *contentStr;

@end

@implementation SecondViewController

static int blueToolState = 0;
static int count = -1;
static int timeNum = 1;

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _imgUp = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH - 120)/2,180, 120,66)];
    _imgUp.image = [UIImage imageNamed:@"shake_logo_up副本"];
    [self.view addSubview:_imgUp];
    
    _timeTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, 220, 40)];
    _timeTF.placeholder = @"输入广播时间（默认1秒）";
    _timeTF.textColor = [UIColor blackColor];
    _timeTF.delegate = self;
    _timeTF.layer.borderWidth = 1.0;
    [self.view addSubview:_timeTF];
    
    _timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _timeBtn.frame = CGRectMake(20, CGRectGetMaxY(_timeTF.frame) + 10, 80, 40);
    [_timeBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_timeBtn addTarget:self action:@selector(queueClick) forControlEvents:UIControlEventTouchUpInside];
    _timeBtn.backgroundColor = [UIColor blueColor];
    [_timeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_timeBtn];
    
    _contentTF = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_timeBtn.frame) + 10, 220, 40)];
    _contentTF.placeholder = @"输入广播内容";
    _contentTF.textColor = [UIColor blackColor];
    _contentTF.delegate = self;
    _contentTF.layer.borderWidth = 1.0;
    [self.view addSubview:_contentTF];
    
    _imgDown = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH - 120)/2, CGRectGetMaxY(_imgUp.frame), 120, 66)];
    _imgDown.image = [UIImage imageNamed:@"shake_logo_down副本"];
    [self.view addSubview:_imgDown];
    
    _showLab = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH - 300)/2, CGRectGetMaxY(_imgDown.frame) + 20, 300, 120)];
    _showLab.numberOfLines = 0;
    _showLab.textColor = [UIColor redColor];
    _showLab.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_showLab];
    
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
//    _dataArr = @[@"ioajsdfiweoinfoisadlfalsdfeiouwfinlksdfewionfinalskdfjklsd", @"sdfsasdf", @"2342134sdfasdfasdsdf"];
    _dic = @{CBAdvertisementDataLocalNameKey : @"GD"};
}

//-(void)addUUIDClick:(UIButton *)btn
//{
//    if(_manager.isAdvertising)
//    {
//        [_manager stopAdvertising];
//    }
//    if(btn.selected == NO)
//    {
//        _dic = @{CBAdvertisementDataServiceUUIDsKey:@"F9F7", CBAdvertisementDataLocalNameKey : [NSString stringWithFormat:@"SGD-%@", _dataArr[count%3]]};
//        btn.selected = YES;
//        [btn setTitle:@"去除UUID" forState:UIControlStateNormal];
//        _UUIDStr = @"已添加UUID：F9F7";
//    }
//    else
//    {
//        _dic = @{CBAdvertisementDataLocalNameKey : [NSString stringWithFormat:@"SGD-%@", _dataArr[count%3]]};
//        btn.selected = NO;
//        [btn setTitle:@"添加UUID" forState:UIControlStateNormal];
//        _UUIDStr = @"已去除UUID：F9F7";
//    }
//}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_contentTF resignFirstResponder];
    [_timeTF resignFirstResponder];
}

-(void)queueClick
{
    if(_timeTF.text.length != 0)
    {
        timeNum = [_timeTF.text intValue];
        _timeTF.text = nil;
        _timeTF.placeholder = [NSString stringWithFormat:@"时间已设置为%d秒", timeNum];
    }
}

-(void)ContentQueueClick
{
    _contentStr = _contentTF.text;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == _timeTF)
        textField.keyboardType = UIKeyboardTypeNumberPad;

    return YES;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if(peripheral.state == CBManagerStatePoweredOn)
    {
        NSLog(@"蓝牙已打开");
        blueToolState = 1;
    }
    if(peripheral.state == CBManagerStatePoweredOff)
    {
        NSLog(@"蓝牙未打开");
        blueToolState = 0;
    }
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"开始摇动");
    count ++;
    
    _dic = @{CBAdvertisementDataLocalNameKey : [NSString stringWithFormat:@"GD-%@", _contentTF.text]};
    if(blueToolState)
    {
        [self addAnimations];
        //startAdvertising这个方法只允许设置CBAdvertisementDataLocalNameKey（本地名称）、CBAdvertisementDataServiceUUIDsKey（UUID）两个参数，其他键值key可在“中心模式”下的设备中使用。 CBAdvertisementDataIsConnectable（外设的可连接数）这个参数是广播包自带的默认参数（1->可连接 0->不可连接）
        [_manager startAdvertising:_dic];
        [_manager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"显示的蓝牙名称", CBAdvertisementDataServiceUUIDsKey:@"EEFF"}];
    }
    else
    {
        _showLab.text = @"未打开蓝牙";
    }
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"结束摇动");
}

-(void)cancelPeripheral
{
    [_manager stopAdvertising];
    _showLab.text = @"蓝牙广播已关闭";
}

//添加动画
#pragma mark - 摇一摇动画效果
- (void)addAnimations
{
    //让img上下移动
    CABasicAnimation *translationUp
    = [CABasicAnimation animationWithKeyPath:@"position"];
    translationUp.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translationUp.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(_imgDown.frame),  CGRectGetMidY(_imgDown.frame))];
    translationUp.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(_imgDown.frame),  CGRectGetMidY(_imgDown.frame)+50)];
    translationUp.duration = 0.8;
    translationUp.repeatCount = 1;
    translationUp.autoreverses = YES;
    
    //让imagdown上下移动
    CABasicAnimation *translationDown = [CABasicAnimation animationWithKeyPath:@"position"];
    translationDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translationDown.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(_imgUp.frame),  CGRectGetMidY(_imgUp.frame))];
    translationDown.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(_imgUp.frame),  CGRectGetMidY(_imgUp.frame)-50)];
    translationDown.duration = 0.8;
    translationDown.repeatCount = 1;
    translationDown.autoreverses = YES;
    
    [_imgDown.layer addAnimation:translationUp forKey:@"translationUp"];
    [_imgUp.layer addAnimation:translationDown forKey:@"translationDown"];
    
}

//perihpheral添加了service
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error == nil) {
        NSLog(@"外设成功创建并开始广播数据");
        
       
    }
    else
        NSLog(@"蓝牙设备添加服务失败，%@", error);
}

//手机已经开始广播广播
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    NSLog(@"已经开始广播");
    _showLab.text = [NSString stringWithFormat:@"已经成功广播蓝牙名称：GD-%@，并在%d秒后关闭广播", _contentTF.text, timeNum];
    [self performSelector:@selector(cancelPeripheral) withObject:nil afterDelay:timeNum];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
