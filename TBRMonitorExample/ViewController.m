//
//  ViewController.m
//  TBRMonitorExample
//
//  Created by huanwh on 16/4/15.
//  Copyright © 2016年 Alibaba-inc Literature. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray * urlStrings = @[@"https://www.google.com",
                             @"http://www.baidu.com",
                             @"https://taobao.com",
                             @"http://www.safsaf24---23423.com"];
    
    for (NSString *  urlString in urlStrings) {
        NSURL * url = [NSURL URLWithString:urlString];
        [self startWithRequest:url];
    }
    
}

-(void)startWithRequest:(NSURL *)url {
    if (!url) {
        return;
    }
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([response isMemberOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"收到 : %ld",httpResponse.statusCode);
        }
        if (error) {
            NSLog(@"network Errpr: %@",[error localizedDescription]);
        }
    }];
    [task resume];
}

@end
