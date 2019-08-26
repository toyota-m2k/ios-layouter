//
//  WPLStackPanelSampleViewController.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/19.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLStackPanelSampleViewController.h"
#import "WPLStackPanelView.h"
#import "WPLStackPanelScrollView.h"
#import "MICAutoLayoutBuilder.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "WPLSwitchCell.h"
#import "WPLBinder.h"

@interface WPLStackPanelSampleViewController ()

@end

@implementation WPLStackPanelSampleViewController

#define PROP_HORZ_STACK_VISIBLE     @"HorzStackVisible"
#define PROP_VERT_STACK_VISIBLE     @"VertStackVisible"


static UIColor* colors[] = {
    //    [UIColor blackColor],      // 0.0 white
    [UIColor darkGrayColor],   // 0.333 white
    [UIColor lightGrayColor],  // 0.667 white
    //    [UIColor whiteColor],      // 1.0 white
    [UIColor grayColor],       // 0.5 white
    [UIColor redColor],       // 1.0, 0.0, 0.0 RGB
    [UIColor greenColor],      // 0.0, 1.0, 0.0 RGB
    [UIColor blueColor],       // 0.0, 0.0, 1.0 RGB
    [UIColor cyanColor],       // 0.0, 1.0, 1.0 RGB
    [UIColor yellowColor],     // 1.0, 1.0, 0.0 RGB
    [UIColor magentaColor],    // 1.0, 0.0, 1.0 RGB
    [UIColor orangeColor],     // 1.0, 0.5, 0.0 RGB
    [UIColor purpleColor],     // 0.5, 0.0, 0.5 RGB
    [UIColor brownColor],      // 0.6, 0.4, 0.2 RGB
    //    [UIColor clearColor],      // 0.0 white, 0.0 alpha
};
static int colorCount = sizeof(colors)/sizeof(colors[0]);

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    let ss = [WPLStackPanelScrollView stackPanelViewWithName:@"rootScroller"
                                                      params:WPLStackPanelParams()
                                                        .requestViewSize(0,0)
                                                            // 0: auto
                                                            // -1:stretch にすると、ビューのサイズに合わせてコンテントが伸縮してしまうので、スクロールしなくなるので注意）
                                                        .align(WPLCellAlignmentCENTER)
                                                        .orientation(WPLOrientationVERTICAL)];
    
    [self.view addSubview:ss];
    
    MICAutoLayoutBuilder(self.view)
    .fitToSafeArea(ss, MICUiPosExALL)
    .activate();
    
    WPLBinderBuilder bb(ss.binder);
    bb.property(PROP_HORZ_STACK_VISIBLE, true);
    bb.property(PROP_VERT_STACK_VISIBLE, true);

    WPLCell* cell;
    UILabel* label;
    UIView* view;
    
    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [back sizeToFit];
    cell = [WPLCell newCellWithView:back name:@"BackButton" params:WPLCellParams().margin(MICEdgeInsets(0,0,0,5)).horzAlign(WPLCellAlignmentEND)];
    [ss.container addCell:cell];
    
    //---- 横並びのスタックパネル ----

    // Switch + Label を配置するスタックパネル
    let ts1 = [WPLStackPanel stackPanelWithName:@"horz stack switch" params:WPLStackPanelParams().orientation(WPLOrientationHORIZONTAL).cellSpacing(30).margin(0,30,0,10).vertAlign(WPLCellAlignmentCENTER)];
    [ss.container addCell:ts1];

    let sw1 = [UISwitch new];
    [sw1 sizeToFit];
    sw1.on = true;
    cell = [WPLSwitchCell newCellWithView:sw1 name:@"no1-switch" params:WPLCellParams()];
    bb.bind(PROP_HORZ_STACK_VISIBLE, cell, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT);
    [ts1 addCell:cell];

    label = [UILabel new];
    label.text = @"Horizontal Stack Panel";
    [label sizeToFit];
    [ts1 addCell:[WPLCell newCellWithView:label name:@"horz stack title" params:WPLCellParams()]];
    
    // 横向きスタックパネル
    let s1 = [WPLStackPanel stackPanelWithName:@"horzStack"
                                        params:WPLStackPanelParams()
                                                .orientation(WPLOrientationHORIZONTAL)
                                                .cellSpacing(4)
                                                .horzAlign(WPLCellAlignmentCENTER)];
    for(NSInteger i=0; i<20; i++) {
        view = [[UIView alloc] initWithFrame:MICRect(30,30)];
        view.backgroundColor = colors[i%colorCount];
        [s1 addCell:[WPLCell newCellWithView:view name:@"" params:WPLCellParams()]];
    }
    [ss.container addCell:s1];
    // Switch on/off でこのスタックパネルの表示・非表示を切り替える
    bb.bind(PROP_HORZ_STACK_VISIBLE, s1, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false);

    //---- 縦並びのスタックパネル ----

    // Switch + Label を配置するスタックパネル
    let ts2 = [WPLStackPanel stackPanelWithName:@"vert stack switch"
                                         params:WPLStackPanelParams()
                                           .orientation(WPLOrientationHORIZONTAL)
                                           .cellSpacing(30)
                                           .margin(0,30,0,10)
                                           .vertAlign(WPLCellAlignmentCENTER)];
    [ss.container addCell:ts2];

    let sw2 = [UISwitch new];
    [sw2 sizeToFit];
    cell = [WPLSwitchCell newCellWithView:sw2 name:@"no2-switch" params:WPLCellParams()];
    bb.bind(PROP_VERT_STACK_VISIBLE, cell, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT);
    [ts2 addCell:cell];

    
    label = [UILabel new];
    label.text = @"Vertical Stack Panel";
    [label sizeToFit];
    [ts2 addCell:[WPLCell newCellWithView:label name:@"vertical stack title" params:WPLCellParams()]];

    let s2 = [WPLStackPanel stackPanelWithName:@"horzStack"
                                        params:WPLStackPanelParams()
                                          .orientation(WPLOrientationVERTICAL)
                                          .cellSpacing(4)
                                          .horzAlign(WPLCellAlignmentCENTER)];
    for(NSInteger i=0; i<20; i++) {
        label = [UILabel new];
        label.backgroundColor = colors[i%colorCount];
        label.textColor = UIColor.whiteColor;
        label.text = [NSString stringWithFormat:@"Label-%ld", (long)i+1];
        [label sizeToFit];
        label.frame = MICRect(label.frame).inflate(0,0,10,10);
        [s2 addCell:[WPLCell newCellWithView:label name:@"" params:WPLCellParams()]];
    }
    [ss.container addCell:s2];
    // Switch on/off でこのスタックパネルの表示・非表示を切り替える
    bb.bind(PROP_VERT_STACK_VISIBLE, s2, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false);
}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
