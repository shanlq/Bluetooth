//
//  ThirdViewController.m
//  test
//
//  Created by apple on 2017/10/24.
//  Copyright © 2017年 slq. All rights reserved.
//

#import "ThirdViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DES3Util.h"

@interface ThirdViewController ()<CBPeripheralManagerDelegate>

@property (nonatomic, strong) UIImageView *imgUp;
@property (nonatomic, strong) UIImageView *imgDown;
@property (nonatomic, strong) UILabel *showLab;

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic, strong) CBPeripheralManager *manager;

@end

@implementation ThirdViewController

static int blueToolState = 0;
static int count = 0;

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _dic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    _imgUp = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH - 120)/2,80, 120,66)];
    _imgUp.image = [UIImage imageNamed:@"shake_logo_up副本"];
    [self.view addSubview:_imgUp];
    
    _imgDown = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH - 120)/2, CGRectGetMaxY(_imgUp.frame), 120, 66)];
    _imgDown.image = [UIImage imageNamed:@"shake_logo_down副本"];
    [self.view addSubview:_imgDown];
    
    _showLab = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH - 300)/2, CGRectGetMaxY(_imgDown.frame) + 20, 300, 200)];
    _showLab.numberOfLines = 0;
    _showLab.textColor = [UIColor redColor];
    _showLab.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_showLab];
    
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
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
    _showLab.text = nil;
    
    NSString *seviceId = @"sldislkdjfcl";
    NSString *totalStr = [NSString stringWithFormat:@"1%@%@", [seviceId substringFromIndex:3], [self getRandomNumberStr]];
    NSString *encryStr = [DES3Util encryptUseDES:totalStr key:@"s2j0t161"];
    
    _dic = @{CBAdvertisementDataLocalNameKey : [NSString stringWithFormat:@"SGD-%@", encryStr]};
    if(blueToolState)
    {
        [self addAnimations];
        [_manager startAdvertising:_dic];
        _showLab.text = [NSString stringWithFormat:@"第一次：\n拼接：%@\n加密：%@", totalStr, encryStr];
        _showLab.hidden = YES;
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
    count++;
    if(count == 2)
    {
        [_manager stopAdvertising];
        count = 0;
    }
    else
    {
        [_manager stopAdvertising];
        NSString *seviceId = @"sldislkdjfcl";
        NSString *totalStr = [NSString stringWithFormat:@"2%@%@", [seviceId substringFromIndex:3], [self GetData]];
        NSString *encryStr = [DES3Util encryptUseDES:totalStr key:@"s2j0t161"];
        
        _dic = @{CBAdvertisementDataLocalNameKey : [NSString stringWithFormat:@"SGD-%@", encryStr]};
        [_manager startAdvertising:_dic];
        _showLab.text = [NSString stringWithFormat:@"%@\n第二次：\n拼接：%@\n加密：%@", _showLab.text, totalStr, encryStr];
        _showLab.hidden = YES;
    }
    
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

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    NSLog(@"已经开始广播");
    _showLab.hidden = NO;
    [self performSelector:@selector(cancelPeripheral) withObject:nil afterDelay:0.5];
//    _showLab.text = [NSString stringWithFormat:@"已经成功广播蓝牙名称：SGD-%@，并在%d秒后关闭广播", _contentTF.text, timeNum];
}

//随机4位数
-(NSString*)getRandomNumberStr
{
    return [NSString stringWithFormat:@"%d",(int)(1000 + (arc4random() % (9999 - 1000 + 1)))];
}
//日期（月、日）
-(NSString *)GetData
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mmdd"];
    return [formatter stringFromDate:date];
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
