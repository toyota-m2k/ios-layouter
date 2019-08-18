//
//  WPLBindViewController.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/07/29.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
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
