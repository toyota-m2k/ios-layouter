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
    UIViewController* _prev;
}

- (void) backToPrev:(id)_ {
    if(_prev!=nil) {
        [_prev dismissViewControllerAnimated:false completion:nil];
    }
}

- (instancetype) initWithPrev:(UIViewController*) prev {
    self = [super init];
    if(nil!=self) {
        _prev = prev;
    }
    return self;
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
