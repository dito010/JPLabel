//
//  JPWebViewController.m
//  JPLabel
//
//  Created by lava on 16/9/3.
//  Copyright © 2016年 lavaMusic. All rights reserved.
//

#import "JPWebViewController.h"

@interface JPWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation JPWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:_URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end
