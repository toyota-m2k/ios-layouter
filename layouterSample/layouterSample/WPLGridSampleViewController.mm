//
//  WPLGridSampleViewController.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/05.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLGridSampleViewController.h"
#import "WPLGridL.h"
#import "WPLStackPanel.h"
#import "WPLBinder.h"
#import "MICVar.h"
#import "WPLSwitchCell.h"
#import "MICUiRectUtil.h"


@interface WPLGridSampleViewController ()

@end

@implementation WPLGridSampleViewController {
    UIViewController* _mainVC;
    WPLBinder* _binder;
    WPLGrid* _buttonPanel;
    WPLGrid* _rootGrid;
}

- (instancetype) initWithMain:(UIViewController*)main {
    self = [super init];
    if(nil!=self) {
        _mainVC = main;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    _buttonPanel = [WPLGrid gridWithName:@"buttonPanel"
                                              params:WPLGridParams()
                                                .requestViewSize(self.view.frame.size.width, 0)
                                                .colDefs(@[AUTO,AUTO,AUTO,STRC])
                                                .rowDefs(@[AUTO])
                                           superview:self.view containerDelegate:self];
    
    let btn1 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn1 setTitle:@"Test-1" forState:(UIControlStateNormal)];
    [btn1 sizeToFit];
    [btn1 addTarget:self action:@selector(execTest1:) forControlEvents:(UIControlEventTouchUpInside)];
    [_buttonPanel addCell:[WPLCell newCellWithView:btn1 name:@"test1-btn" params:WPLCellParams().margin(MICEdgeInsets(10))] row:0 column:0];
     
    let btn2 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn2 setTitle:@"Test-2" forState:(UIControlStateNormal)];
    [btn2 sizeToFit];
    [btn2 addTarget:self action:@selector(execTest2:) forControlEvents:(UIControlEventTouchUpInside)];
    [_buttonPanel addCell:[WPLCell newCellWithView:btn2 name:@"test2-btn" params:WPLCellParams().margin(MICEdgeInsets(10))] row:0 column:1];
    
    let btn3 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn3 setTitle:@"Test-3" forState:(UIControlStateNormal)];
    [btn3 sizeToFit];
    [btn3 addTarget:self action:@selector(execTest3:) forControlEvents:(UIControlEventTouchUpInside)];
    [_buttonPanel addCell:[WPLCell newCellWithView:btn3 name:@"test3-btn" params:WPLCellParams().margin(MICEdgeInsets(10))] row:0 column:2];
    
    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back setTitle:@"Back" forState:(UIControlStateNormal)];
    [back sizeToFit];
    [back addTarget:self action:@selector(backToMain:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonPanel addCell:[WPLCell newCellWithView:back name:@"back" params:WPLCellParams().horzAlign(WPLCellAlignmentEND).margin(MICEdgeInsets(10))] row:0 column:3];
     
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

/**
 * １x１のグリッドに、１つのビューをSTRETCH で、ぴったり配置する。
 */
- (void) execTest1:(id)_ {
    [self cleanup];
    _binder = [WPLBinder new];
    _rootGrid = [WPLGrid gridWithName:@"rootGrid" params:WPLGridParams().requestViewSize(MICSize(200,300)) superview:self.view containerDelegate:self];
    _rootGrid.view.backgroundColor = UIColor.greenColor;
    
    let v1 = [UIView new];
    v1.backgroundColor = UIColor.orangeColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"v1" params:WPLCellParams().align(WPLAlignment(WPLCellAlignmentSTRETCH))];
    [_rootGrid addCell:vc1];
    
    [self.view addSubview:_rootGrid.view];
    [self onChildCellModified:_rootGrid];

}

/**
 * １つのグリッドセルに２つのViewを配置して、それぞれ排他的に表示・非表示を切り替えて再配置するテスト
 */
- (void) execTest2:(id)_ {
    [self cleanup];
    _binder = [WPLBinder new];
    _rootGrid = [WPLGrid gridWithName:@"rootGrid" params:WPLGridParams().rowDefs(@[AUTO,STRC]) superview:self.view containerDelegate:self];
    _rootGrid.view.backgroundColor = UIColor.yellowColor;
    
    let sw1 = [[UISwitch alloc] init];
    [sw1 sizeToFit];
    sw1.on = true;
    let swcell1 = [WPLSwitchCell newCellWithView:sw1 name:@"no1-switch" params:WPLCellParams().vertAlign(WPLCellAlignmentCENTER).margin(MICEdgeInsets(0,0,0,20))];
    [_rootGrid addCell:swcell1 row:0 column:0];
    
    let subGrid1 = [WPLGrid gridWithName:@"subGrid1"
                                  params:WPLGridParams().requestViewSize(MICSize(100,200))
                               superview:nil containerDelegate:nil];

    [_rootGrid addCell:subGrid1 row:1 column:0];
    
    let v1 = [UIView new];
    v1.backgroundColor = UIColor.greenColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"v1" params:WPLCellParams().align(WPLAlignment(WPLCellAlignmentSTRETCH))];
    [subGrid1 addCell:vc1];
    
    let subGrid2 = [WPLGrid gridWithName:@"subGrid2" params:WPLGridParams().requestViewSize(200,100)];
    [_rootGrid addCell:subGrid2 row:1 column:0];
    
    let v2 = [UIView new];
    v2.backgroundColor = UIColor.cyanColor;
    let vc2 = [WPLCell newCellWithView:v2 name:@"v1" params:WPLCellParams().align(WPLAlignment(WPLCellAlignmentSTRETCH))];
    [subGrid2 addCell:vc2];
    
    [_binder createPropertyWithValue:@false withKey:@"check-selected"];
    [_binder bindProperty:@"check-selected" withValueOfCell:swcell1 bindingMode:(WPLBindingModeVIEW_TO_SOURCE) customActin:nil];
    [_binder bindProperty:@"check-selected" withBoolStateOfCell:subGrid1 actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:false customActin:nil];
    [_binder bindProperty:@"check-selected" withBoolStateOfCell:subGrid2 actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:true customActin:nil];
    [self onChildCellModified:_rootGrid];
}

/**
 * セルのSTRETCHでの、比率配分レイアウトのテスト
 */
- (void) execTest3:(id)_ {
    [self cleanup];
    _binder = [WPLBinder new];
    let gridParams = WPLGridParams()
                        .colDefs(@[AUTO,STRC,STRC,STRCx(2),AUTO])
                        .rowDefs(@[AUTO,STRC,STRCx(2),STRCx(3),AUTO])
                        .requestViewSize(300, 400);
    _rootGrid = [WPLGrid gridWithName:@"rootGrid"
                               params:gridParams
                            superview:self.view containerDelegate:self];
    _rootGrid.view.backgroundColor = UIColor.yellowColor;

    for(NSInteger r=0 ; r<_rootGrid.rows; r++) {
        for(NSInteger c=0 ; c<_rootGrid.columns ; c++) {
            let v = [[UIView alloc] initWithFrame:MICRect(0,0,30,30)];
            v.backgroundColor = UIColor.blueColor;
            [_rootGrid addCell:[WPLCell newCellWithView:v
                                                   name:[NSString stringWithFormat:@"c%ld-r%ld", (long)c, (long)r]
                                                 params:WPLCellParams()
                                                        .horzAlign((gridParams._dimension.colDefs[c].intValue==0)?WPLCellAlignmentCENTER :WPLCellAlignmentSTRETCH)
                                                        .vertAlign((gridParams._dimension.rowDefs[r].intValue==0)?WPLCellAlignmentCENTER :WPLCellAlignmentSTRETCH)
                                                        .margin(MICEdgeInsets(5,5,5,5))
                                                    ] row:r column:c];
        }
    }
    [self onChildCellModified:_rootGrid];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_binder dispose];
    [_rootGrid dispose];
    [_buttonPanel dispose];
}

- (void) backToMain:(id) _ {
    [_mainVC dismissViewControllerAnimated:true completion:nil];
    
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
