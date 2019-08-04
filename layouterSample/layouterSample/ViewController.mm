//
//  ViewController.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/07/29.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "ViewController.h"
#import "WPLSampleView.h"
#import "MICVar.h"

@interface ViewController ()
@end

@implementation ViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    let view = [[WPLSampleView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    
}


@end
