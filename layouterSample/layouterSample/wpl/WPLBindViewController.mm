//
//  WPLBindViewController.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/07/29.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLBindViewController.h"
#import "WPLSampleView.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"

@interface WPLBindViewController ()
@end

@implementation WPLBindViewController {
}

- (void) backToPrev:(id)_ {
    [self dismissViewControllerAnimated:false completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    let view = [[WPLSampleView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    
    MICAutoLayoutBuilder(self.view)
    .fitToSafeArea(view)
    .activate();
}


@end
