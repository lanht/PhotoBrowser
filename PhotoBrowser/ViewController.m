//
//  ViewController.m
//  PhotoBrowser
//
//  Created by Lanht on 2019/6/16.
//  Copyright © 2019 lanht. All rights reserved.
//

#import "ViewController.h"
#import "ALPhotoBrowerViewController.h"
#import "PHPhotoBrowserViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)before:(id)sender {
    [self.navigationController pushViewController:[ALPhotoBrowerViewController new] animated:YES];

}

- (IBAction)after:(id)sender {
    [self.navigationController pushViewController:[PHPhotoBrowserViewController new] animated:YES];
}

@end
