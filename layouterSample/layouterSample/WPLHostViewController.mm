//
//  WPLHostViewController.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/08.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLHostViewController.h"
#import "WPLCellHostingView.h"
#import "WPLGridL.h"
#import "WPLStackPanel.h"
#import "WPLBinder.h"
#import "MICVar.h"

@interface WPLHostViewController ()

@end

@implementation WPLHostViewController {
    WPLCellHostingView* _hostView;
    UIViewController* _prev;
}

- (instancetype) initWithPrev:(UIViewController*) prev {
    self = [super init];
    if(nil!=self) {
        _prev = prev;
    }
    return self;
}

- (UIView*) viewInColor:(UIColor*)color {
    let v = [[UIView alloc] initWithFrame:MICRect(MICPoint(), MICSize(20,20))];
    v.backgroundColor = color;
    return v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    _hostView = [WPLCellHostingView new];
    MICEdgeInsets sa(30,30);
    MICRect rc(self.view.frame);
    rc.deflate(sa);

    _hostView.frame = rc;
    _hostView.translatesAutoresizingMaskIntoConstraints = false;
    _hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_hostView];
    
    let grid = [WPLGrid gridWithName:@"rootGrid"
                              params:WPLGridParams()
                                .rowDefs(@[AUTO,STRC,AUTO])
                                .colDefs(@[STRC,AUTO,AUTO])
                                .requestViewSize(-1, -1)
                                .cellSpacing(10, 10)];
    
    let c1 = [WPLCell newCellWithView:[self viewInColor:UIColor.cyanColor] name:@"v1" params:WPLCellParams().requestViewSize(-1,0)];
    [grid addCell:c1 row:0 column:0];

    let c2 = [WPLCell newCellWithView:[self viewInColor:UIColor.orangeColor] name:@"v2" params:WPLCellParams()];
    [grid addCell:c2 row:0 column:1];

    let c3 = [WPLCell newCellWithView:[self viewInColor:UIColor.yellowColor] name:@"v3" params:WPLCellParams()];
    [grid addCell:c3 row:0 column:2];

    let c4 = [WPLCell newCellWithView:[self viewInColor:UIColor.greenColor] name:@"v4" params:WPLCellParams().requestViewSize(-1,0)];
    [grid addCell:c4 row:2 column:0];

    let c5 = [WPLCell newCellWithView:[self viewInColor:UIColor.purpleColor] name:@"v5" params:WPLCellParams()];
    [grid addCell:c5 row:2 column:1];

    let c6 = [WPLCell newCellWithView:[self viewInColor:UIColor.redColor] name:@"v6" params:WPLCellParams()];
    [grid addCell:c6 row:2 column:2];
    
    let stack = [WPLStackPanel stackPanelWithName:@"stack" params:WPLStackPanelParams().requestViewSize(-1,-1).cellSpacing(10)];
    stack.view.backgroundColor = UIColor.lightGrayColor;
//    stack.visibility = WPLVisibilityCOLLAPSED;
    [grid addCell:stack row:1 column:0 rowSpan:1 colSpan:3];
    
    let s1 = [WPLCell newCellWithView:[self viewInColor:UIColor.blueColor] name:@"s1" params:WPLCellParams().requestViewSize(-1,0)];
    let s2 = [WPLCell newCellWithView:[self viewInColor:UIColor.brownColor] name:@"s2" params:WPLCellParams().requestViewSize(-1,0)];
    let s3 = [WPLCell newCellWithView:[self viewInColor:UIColor.darkGrayColor] name:@"s3" params:WPLCellParams().requestViewSize(-1,0)];
    
    let btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"Back" forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backToPrev:) forControlEvents:UIControlEventTouchUpInside];
    let bc = [WPLCell newCellWithView:btn name:@"backBtn" params:WPLCellParams().horzAlign(WPLCellAlignmentCENTER)];
    [stack addCell:s1];
    [stack addCell:s2];
    [stack addCell:s3];
    [stack addCell:bc];
    
    _hostView.containerCell = grid;
}

- (void) backToPrev:(id)_ {
    if(_prev!=nil) {
        [_prev dismissViewControllerAnimated:false completion:nil];
    }
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
