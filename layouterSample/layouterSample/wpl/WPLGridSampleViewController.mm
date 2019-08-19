//
//  WPLGridSampleViewController.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/19.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLGridSampleViewController.h"
#import "WPLGridScrollView.h"
#import "MICAutoLayoutBuilder.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "WPLSwitchCell.h"
#import "WPLBinder.h"
#import "WPLContainersL.h"

@interface WPLGridSampleViewController ()

@end

@implementation WPLGridSampleViewController

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

#define PROP_GRID_A_VISIBLE @"GridA"
#define PROP_GRID_B_VISIBLE @"GridB"
#define PROP_GRID_C_VISIBLE @"GridC"


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    
    let gs = [WPLGridScrollView gridViewWithName:@"rootScroller"
                                          params:WPLGridParams()
                                              .requestViewSize(0,0)
                                              // 0: auto
                                              // -1:stretch にすると、ビューのサイズに合わせてコンテントが伸縮してしまうので、スクロールしなくなるので注意）
                                              .align(WPLCellAlignmentCENTER)
                                              .cellSpacing(10,10)
                                              .colDefs(@[AUTO,STRC,AUTO])
                                              .rowDefs(@[AUTO,AUTO,AUTO, AUTO,AUTO,AUTO, AUTO,AUTO])];

    [self.view addSubview:gs];
    
    MICAutoLayoutBuilder(self.view)
    .fitToSafeArea(gs, MICUiPosExALL)
    .activate();
    
    WPLBinderBuilder bb(gs.binder);
    bb.property(PROP_GRID_A_VISIBLE, true);
    bb.property(PROP_GRID_B_VISIBLE, true);
    bb.property(PROP_GRID_C_VISIBLE, true);

    WPLCell* cell;
    UILabel* label;
//    UIView* view;
    
    // Row-0
    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [back sizeToFit];
    cell = [WPLCell newCellWithView:back name:@"BackButton" params:WPLCellParams().margin(MICEdgeInsets(0,0,0,0)).horzAlign(WPLCellAlignmentEND)];
    [gs.container addCell:cell row:0 column:2];
    
    // Row-1
    label = [UILabel new];
    label.text = @"Grid-A";
    [label sizeToFit];
    [gs.container addCell:[WPLCell newCellWithView:label name:@"Grid-A title" params:WPLCellParams()] row:1 column:0];

    let sw1 = [UISwitch new];
    [sw1 sizeToFit];
    cell = [WPLSwitchCell newCellWithView:sw1 name:@"A-switch" params:WPLCellParams().horzAlign(WPLCellAlignmentSTART)];
    bb.bindValue(PROP_GRID_A_VISIBLE, cell, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT);
    [gs.container addCell:cell row:1 column:1];

#if true
    let g1 = [WPLGrid gridWithName:@"g1" params:WPLGridParams()
              .requestViewSize(VSTRC,VAUTO)
              .rowDefs(@[AUTO])
              .colDefs(@[STRC])];
    [gs.container addCell:g1 row:0 column:0];
    label = [UILabel new];
    label.backgroundColor = UIColor.orangeColor;
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"WWWWW WWWWW WWWWW WWWWW WWWWW WWWWW WWWWW";
    [label sizeToFit];
    label.frame = MICRect(label.frame).inflate(0,0,0,30);
    [gs.container addCell:[WPLCell newCellWithView:label name:@"" params:WPLCellParams().requestViewSize(VSTRC,VAUTO)] row:2 column:0 rowSpan:1 colSpan:3];
#else
    // Row-2
    // Inner Grid-1
    let g1 = [WPLGrid gridWithName:@"g1" params:WPLGridParams()
              .requestViewSize(VSTRC,VAUTO)
              .rowDefs(@[AUTO,AUTO,AUTO])
              .colDefs(@[STRC,STRC,STRC,STRC])
              ];
    
    for(NSInteger i=0;i<3;i++) {
        for(NSInteger j=0;j<4;j++) {
            label = [UILabel new];
            label.backgroundColor = colors[(i*3+j)%colorCount];
            label.textColor = UIColor.whiteColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [NSString stringWithFormat:@"R%ld-C%ld", (long)i+1, (long)j+1];
            [label sizeToFit];
            label.frame = MICRect(label.frame).inflate(0,0,30,30);
            [g1 addCell:[WPLCell newCellWithView:label name:@"" params:WPLCellParams().requestViewSize(VSTRC,VAUTO)] row:i column:j];
        }
    }
    [gs.container addCell:g1 row:2 column:0 rowSpan:1 colSpan:3];
    bb.bindState(PROP_GRID_A_VISIBLE, g1, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false);

    // Row-3
    label = [UILabel new];
    label.text = @"Grid-B (stretch 1:2:3)";
    [label sizeToFit];
    [gs.container addCell:[WPLCell newCellWithView:label name:@"Grid-C title" params:WPLCellParams()] row:3 column:0];
    
    let sw2 = [UISwitch new];
    [sw2 sizeToFit];
    cell = [WPLSwitchCell newCellWithView:sw2 name:@"B-switch" params:WPLCellParams().horzAlign(WPLCellAlignmentSTART)];
    bb.bindValue(PROP_GRID_B_VISIBLE, cell, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT);
    [gs.container addCell:cell row:3 column:1];


    // Row-4
    // Inner Grid-2
    let g2 = [WPLGrid gridWithName:@"g2" params:WPLGridParams()
              .requestViewSize(VAUTO,VAUTO)
              .rowDefs(@[AUTO,AUTO,AUTO])
              .colDefs(@[STRC,STRCx(2),STRCx(3)])
              ];
    for(NSInteger i=0;i<3;i++) {
        for(NSInteger j=0;j<3;j++) {
            label = [UILabel new];
            label.backgroundColor = colors[(i*3+j)%colorCount];
            label.textColor = UIColor.whiteColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [NSString stringWithFormat:@"R%ld-C%ld", (long)i+1, (long)j+1];
            [label sizeToFit];
            label.frame = MICRect(label.frame).inflate(0,0,30,30);
            [g2 addCell:[WPLCell newCellWithView:label name:@"" params:WPLCellParams().requestViewSize(VSTRC,VAUTO)] row:i column:j];
        }
    }
    
    
    [gs.container addCell:g2 row:4 column:0 rowSpan:1 colSpan:3];
    bb.bindState(PROP_GRID_B_VISIBLE, g2, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false);



    // Row-5
    label = [UILabel new];
    label.text = @"Grid-C (auto)";
    [label sizeToFit];
    [gs.container addCell:[WPLCell newCellWithView:label name:@"Grid-C title" params:WPLCellParams()] row:5 column:0];
    
    let sw3 = [UISwitch new];
    [sw3 sizeToFit];
    cell = [WPLSwitchCell newCellWithView:sw3 name:@"C-switch" params:WPLCellParams()];
    bb.bindValue(PROP_GRID_C_VISIBLE, cell, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT);
    [gs.container addCell:cell row:5 column:1];
    
    // Row-6
    // Inner Grid-3
    let g3 = [WPLGrid gridWithName:@"g2" params:WPLGridParams()
              .requestViewSize(VAUTO,VAUTO)
              .rowDefs(@[AUTO,AUTO,AUTO])
              .colDefs(@[AUTO,AUTO,AUTO])
              ];
    for(NSInteger i=0;i<3;i++) {
        for(NSInteger j=0;j<3;j++) {
            label = [UILabel new];
            label.backgroundColor = colors[(i*3+j)%colorCount];
            label.textColor = UIColor.whiteColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [NSString stringWithFormat:@"R%ld-C%ld", (long)i+1, (long)j+1];
            [label sizeToFit];
            label.frame = MICRect(label.frame).inflate(0,0,30,30);
            [g3 addCell:[WPLCell newCellWithView:label name:@"" params:WPLCellParams().requestViewSize(VSTRC,VAUTO)] row:i column:j];
        }
    }
    [gs.container addCell:g3 row:6 column:0 rowSpan:1 colSpan:3];
    bb.bindState(PROP_GRID_C_VISIBLE, g3, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false);
#endif
    
    // Cell Marker
    for(NSInteger i=0 ; i<gs.container.columns ; i++) {
        label = [UILabel new];
        label.backgroundColor = colors[i%colorCount];
        label.textColor = UIColor.whiteColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"C%ld", (long)i+1];
        [label sizeToFit];
        label.frame = MICRect(label.frame).inflate(0,0,30,30);
        [gs.container addCell:[WPLCell newCellWithView:label name:@""
                                                params:WPLCellParams().requestViewSize(VSTRC,VAUTO)] row:7 column:i];

    }

}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
