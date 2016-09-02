//
//  ViewController.m
//  JPLabel
//
//  Created by lava on 16/9/2.
//  Copyright © 2016年 lavaMusic. All rights reserved.
//

#import "ViewController.h"
#import "JPLabel.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet JPLabel *textLabel;

@end

@implementation ViewController
- (void)viewDidLoad {

    [super viewDidLoad];
   
    self.textLabel.text = @"#JPLabel# 用于匹配字符串的内容显示, 用户:@盼盼, 包括话题:#怎么追漂亮女孩?#, 链接:https://github.com/coderwhy/HYLabel, 协议:《退款政策》";
    
    // 非匹配内容文字颜色
    self.textLabel.jp_commonTextColor = [UIColor colorWithRed:112.0/255 green:93.0/255 blue:77.0/255 alpha:1];
    
    // 点选高亮文字颜色
    self.textLabel.jp_textHightLightBackgroundColor = [UIColor colorWithRed:237.0/255 green:213.0/255 blue:177.0/255 alpha:1];
    
    // 匹配文字颜色
    [self.textLabel setHightLightTextColor:[UIColor colorWithRed:132.0/255 green:77.0/255 blue:255.0/255 alpha:1] forHandleStyle:HandleStyleUser];
    [self.textLabel setHightLightTextColor:[UIColor colorWithRed:9.0/255 green:163.0/255 blue:213.0/255 alpha:1] forHandleStyle:HandleStyleLink];
    [self.textLabel setHightLightTextColor:[UIColor colorWithRed:254.0/255 green:156.0/255 blue:59.0/255 alpha:1] forHandleStyle:HandleStyleTopic];
    [self.textLabel setHightLightTextColor:[UIColor colorWithRed:255.0/255 green:69.0/255 blue:0.0/255 alpha:1] forHandleStyle:HandleStyleAgreement];
    
    // 匹配到合适内容的回调
    self.textLabel.jp_tapOperation = ^(UILabel *label, HandleStyle style, NSString *selectedString, NSRange range){
        
        NSLog(@"%@", selectedString);
    };
}

@end
