//
//  WPLGridSampleViewController.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/05.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLGridSampleViewController.h"
#import "WPLGrid.h"
#import "WPLStackPanel.h"
#import "WPLBinder.h"
#import "MICVar.h"
#import "WPLSwitchCell.h"
#import "MICUiRectUtil.h"


@interface WPLGridSampleViewController ()

@end

@implementation WPLGridSampleViewController {
    WPLBinder* _binder;
    WPLStackPanel* _buttonPanel;
    WPLGrid* _rootGrid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    _buttonPanel = [WPLStackPanel stackPanelViewWithName:@"buttonPanel" orientation:(WPLOrientationHORIZONTAL) xalignment:(WPLCellAlignmentSTART) containerDelegate:self];
    [self.view addSubview:_buttonPanel.view];
    
    let btn1 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn1 setTitle:@"Test-①" forState:(UIControlStateNormal)];
    [btn1 sizeToFit];
    [btn1 addTarget:self action:@selector(execTest1:) forControlEvents:(UIControlEventTouchUpInside)];
    [_buttonPanel addCell:[WPLCell newCellWithView:btn1 name:@"test1-btn" margin:MICEdgeInsets(0,0,10,0) requestViewSize:MICSize() hAlignment:(WPLCellAlignmentSTART) vAlignment:(WPLCellAlignmentSTART) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil]];
    
    let btn2 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn2 setTitle:@"Test-②" forState:(UIControlStateNormal)];
    [btn2 sizeToFit];
    [btn2 addTarget:self action:@selector(execTest2:) forControlEvents:(UIControlEventTouchUpInside)];
    [_buttonPanel addCell:[WPLCell newCellWithView:btn2 name:@"test2-btn" margin:MICEdgeInsets(0,0,10,0) requestViewSize:MICSize() hAlignment:(WPLCellAlignmentSTART) vAlignment:(WPLCellAlignmentSTART) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil]];

}

- (void)viewWillLayoutSubviews {
    [self onChildCellModified:_buttonPanel];
}

- (void)onChildCellModified:(id<IWPLCell>)cell {
    if(cell==_buttonPanel) {
        MICSize size = [_buttonPanel layout];
        MICEdgeInsets sa(self.view.safeAreaInsets);
        MICRect rc(MICRect(self.view.frame) - sa);
        rc.size = size;
        cell.view.frame = rc;
    } else {
        MICSize size = [_rootGrid layout];
        MICRect rc(MICPoint(), size);
        rc.moveCenter(MICRect(self.view.frame).center());
        cell.view.frame = rc;
    }
}

- (void) cleanup {
    if(_binder!=nil) {
        [_binder dispose];
        _binder = nil;
    }
    if(_rootGrid!=nil) {
        [_rootGrid.view removeFromSuperview];
        [_rootGrid dispose];
        _rootGrid = nil;
    }
}

- (void) execTest1:(id)_ {
    [self cleanup];
    _binder = [WPLBinder new];
    _rootGrid = [WPLGrid newGridOfRows:nil andColumns:nil requestViewSize:MICSize(200,300)];
    _rootGrid.view.backgroundColor = UIColor.greenColor;
    
    let v1 = [UIView new];
    v1.backgroundColor = UIColor.orangeColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"v1" margin:MICEdgeInsets() requestViewSize:MICSize() hAlignment:(WPLCellAlignmentSTRETCH) vAlignment:(WPLCellAlignmentSTRETCH) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [_rootGrid addCell:vc1];
    
    [self.view addSubview:_rootGrid.view];
    [self onChildCellModified:_rootGrid];

}


- (void) execTest2:(id)_ {
    [self cleanup];
    _binder = [WPLBinder new];
    _rootGrid = [WPLGrid newGridOfRows:@[@0,@-1] andColumns:nil requestViewSize:MICSize()];
    _rootGrid.containerDelegate = self;
    _rootGrid.view.backgroundColor = UIColor.yellowColor;
    [self.view addSubview:_rootGrid.view];
    
    let sw1 = [[UISwitch alloc] init];
    [sw1 sizeToFit];
    sw1.on = true;
    let swcell1 = [WPLSwitchCell newCellWithSwitchView:sw1 name:@"no1-switch" margin:MICEdgeInsets(0,0,0,20) requestViewSize:MICSize() hAlignment:(WPLCellAlignmentSTART) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE)];
    [_rootGrid addCell:swcell1 row:0 column:0];
    
    let subGrid1 = [WPLGrid newGridOfRows:nil andColumns:nil requestViewSize:MICSize(100,200)];
    [_rootGrid addCell:subGrid1 row:1 column:0];
    
    let v1 = [UIView new];
    v1.backgroundColor = UIColor.greenColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"v1" margin:MICEdgeInsets() requestViewSize:MICSize() hAlignment:(WPLCellAlignmentSTRETCH) vAlignment:(WPLCellAlignmentSTRETCH) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [subGrid1 addCell:vc1];
    
    let subGrid2 = [WPLGrid newGridOfRows:nil andColumns:nil requestViewSize:MICSize(200,100)];
    [_rootGrid addCell:subGrid2 row:1 column:0];
    
    let v2 = [UIView new];
    v2.backgroundColor = UIColor.cyanColor;
    let vc2 = [WPLCell newCellWithView:v2 name:@"v1" margin:MICEdgeInsets() requestViewSize:MICSize() hAlignment:(WPLCellAlignmentSTRETCH) vAlignment:(WPLCellAlignmentSTRETCH) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [subGrid2 addCell:vc2];
    
    [_binder createPropertyWithValue:@false withKey:@"check-selected"];
    [_binder bindProperty:@"check-selected" withValueOfCell:swcell1 bindingMode:(WPLBindingModeVIEW_TO_SOURCE) customActin:nil];
    [_binder bindProperty:@"check-selected" withBoolStateOfCell:subGrid1 actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:false customActin:nil];
    [_binder bindProperty:@"check-selected" withBoolStateOfCell:subGrid2 actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:true customActin:nil];
    [self onChildCellModified:_rootGrid];
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
