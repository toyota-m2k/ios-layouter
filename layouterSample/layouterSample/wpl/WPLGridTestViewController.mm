//
//  WPLGridSampleViewController.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/05.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLGridTestViewController.h"
#import "WPLContainersL.h"
#import "WPLGrid.h"
#import "WPLStackPanel.h"
#import "WPLBinder.h"
#import "MICVar.h"
#import "WPLSwitchCell.h"
#import "MICUiRectUtil.h"
#import "WPLHostViewController.h"
#import "WPLCellHostingView.h"
#import "MICAutoLayoutBuilder.h"


@interface WPLGridTestViewController ()

@end

@implementation WPLGridTestViewController {
    WPLBinder* _binder;
    WPLCellHostingView* _hostingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    MICRect rc(self.view.bounds);
    MICEdgeInsets sa(self.additionalSafeAreaInsets);
    rc -= sa;
    _hostingView = [WPLCellHostingView new];
//    _hostingView.translatesAutoresizingMaskIntoConstraints = false;
//    _hostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    _hostingView.frame = rc;
    _hostingView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:_hostingView];

    MICAutoLayoutBuilder(self.view)
    .fitToSafeArea(_hostingView)
    .activate();

    
    let rootContainer = [WPLGrid gridWithName:@"root"
                                       params:WPLGridParams()
                                                .colDefs(@[STRC])
                                                .rowDefs(@[AUTO,STRC])
                                                .requestViewSize(-1,-1)];
    _hostingView.containerCell = rootContainer;
    
    let buttonPanel = [WPLGrid gridWithName:@"buttonPanel"
                                              params:WPLGridParams()
                                                .requestViewSize(-1, 0)
                                                .colDefs(@[AUTO,AUTO,AUTO,AUTO,AUTO,STRC])
                                                .rowDefs(@[AUTO])];
    
    let btn1 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn1 setTitle:@"Test-1" forState:(UIControlStateNormal)];
    [btn1 sizeToFit];
    [btn1 addTarget:self action:@selector(execTest1:) forControlEvents:(UIControlEventTouchUpInside)];
    [buttonPanel addCell:[WPLCell newCellWithView:btn1 name:@"test1-btn" params:WPLCellParams().margin(MICEdgeInsets(10))] row:0 column:0];
     
    let btn2 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn2 setTitle:@"Test-2" forState:(UIControlStateNormal)];
    [btn2 sizeToFit];
    [btn2 addTarget:self action:@selector(execTest2:) forControlEvents:(UIControlEventTouchUpInside)];
    [buttonPanel addCell:[WPLCell newCellWithView:btn2 name:@"test2-btn" params:WPLCellParams().margin(MICEdgeInsets(10))] row:0 column:1];
    
    let btn3 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn3 setTitle:@"Test-3" forState:(UIControlStateNormal)];
    [btn3 sizeToFit];
    [btn3 addTarget:self action:@selector(execTest3:) forControlEvents:(UIControlEventTouchUpInside)];
    [buttonPanel addCell:[WPLCell newCellWithView:btn3 name:@"test3-btn" params:WPLCellParams().margin(MICEdgeInsets(10))] row:0 column:2];

    let btn4 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn4 setTitle:@"Test-4" forState:(UIControlStateNormal)];
    [btn4 sizeToFit];
    [btn4 addTarget:self action:@selector(execTest4:) forControlEvents:(UIControlEventTouchUpInside)];
    [buttonPanel addCell:[WPLCell newCellWithView:btn4 name:@"test4-btn" params:WPLCellParams().margin(MICEdgeInsets(10))] row:0 column:3];

    let btn5 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn5 setTitle:@"Test-5" forState:(UIControlStateNormal)];
    [btn5 sizeToFit];
    [btn5 addTarget:self action:@selector(execTest5:) forControlEvents:(UIControlEventTouchUpInside)];
    [buttonPanel addCell:[WPLCell newCellWithView:btn5 name:@"test5-btn" params:WPLCellParams().margin(MICEdgeInsets(10))] row:0 column:4];

    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back setTitle:@"Back" forState:(UIControlStateNormal)];
    [back sizeToFit];
    [back addTarget:self action:@selector(backToMain:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPanel addCell:[WPLCell newCellWithView:back name:@"back" params:WPLCellParams().horzAlign(WPLCellAlignmentEND).margin(MICEdgeInsets(10))] row:0 column:5];
    
    [rootContainer addCell:buttonPanel row:0 column:0];
}

- (void)viewWillLayoutSubviews {
//    MICRect rc(self.view.bounds);
//    MICEdgeInsets sa(self.view.safeAreaInsets);
//    rc -= sa;
//    _hostingView.frame = rc;
}

//- (void)onChildCellModified:(id<IWPLCell>)cell {
//    if(cell==_buttonPanel) {
//        MICSize size = [_buttonPanel layout];
//        MICEdgeInsets sa(self.view.safeAreaInsets);
//        MICRect rc(MICRect(self.view.bounds) - sa);
//        rc.setHeight(size.height);
//        cell.view.frame = rc;
//    } else {
//        MICSize size = [_rootGrid layout];
//        MICRect rc(MICPoint(), size);
//        rc.moveCenter(MICRect(self.view.frame).center());
//        cell.view.frame = rc;
//    }
//}

- (void) cleanup {
    if(_binder!=nil) {
        [_binder dispose];
        _binder = nil;
    }
    let cell = [_hostingView.containerCell findByName:@"testContainer"];
    [_hostingView.containerCell removeCell:cell];
}

/**
 * １x１のグリッドに、１つのビューをSTRETCH で、ぴったり配置する。
 */
- (void) execTest1:(id)_ {
    [self cleanup];
    _binder = [WPLBinder new];
    let rootGrid = [WPLGrid gridWithName:@"testContainer"
                                  params:WPLGridParams()
                                            .requestViewSize(MICSize(200,300))
                                            .align(WPLAlignment(WPLCellAlignmentCENTER))];
    rootGrid.view.backgroundColor = UIColor.greenColor;
    
    let v1 = [UIView new];
    v1.backgroundColor = UIColor.orangeColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"v1" params:WPLCellParams().requestViewSize(-1,-1)];
    [rootGrid addCell:vc1];

    [(WPLGrid*) _hostingView.containerCell addCell:rootGrid row:1 column:0];
}

/**
 * １つのグリッドセルに２つのViewを配置して、それぞれ排他的に表示・非表示を切り替えて再配置するテスト
 */
- (void) execTest2:(id)_ {
    [self cleanup];
    _binder = [WPLBinder new];
    let rootGrid = [WPLGrid gridWithName:@"testContainer"
                                  params:WPLGridParams()
                                            .rowDefs(@[AUTO,STRC])
                                            .align(WPLAlignment(WPLCellAlignmentCENTER))];
    rootGrid.view.backgroundColor = UIColor.yellowColor;
    
    let sw1 = [[UISwitch alloc] init];
    [sw1 sizeToFit];
    sw1.on = true;
    let swcell1 = [WPLSwitchCell newCellWithView:sw1 name:@"no1-switch" params:WPLCellParams().vertAlign(WPLCellAlignmentCENTER).margin(MICEdgeInsets(0,0,0,20))];
    [rootGrid addCell:swcell1 row:0 column:0];
    
    let subGrid1 = [WPLGrid gridWithName:@"subGrid1"
                                  params:WPLGridParams().requestViewSize(MICSize(100,200))
                               superview:nil containerDelegate:nil];

    [rootGrid addCell:subGrid1 row:1 column:0];
    
    let v1 = [UIView new];
    v1.backgroundColor = UIColor.greenColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"v1" params:WPLCellParams().requestViewSize(-1,-1)];
    [subGrid1 addCell:vc1];
    
    let subGrid2 = [WPLGrid gridWithName:@"subGrid2" params:WPLGridParams().requestViewSize(200,100)];
    [rootGrid addCell:subGrid2 row:1 column:0];
    
    let v2 = [UIView new];
    v2.backgroundColor = UIColor.cyanColor;
    let vc2 = [WPLCell newCellWithView:v2 name:@"v1" params:WPLCellParams().requestViewSize(-1,-1)];
    [subGrid2 addCell:vc2];
    
    [_binder createPropertyWithValue:@false withKey:@"check-selected"];
    [_binder bindProperty:@"check-selected" withValueOfCell:swcell1 bindingMode:(WPLBindingModeVIEW_TO_SOURCE) customActin:nil];
    [_binder bindProperty:@"check-selected" withBoolStateOfCell:subGrid1 actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:false customActin:nil];
    [_binder bindProperty:@"check-selected" withBoolStateOfCell:subGrid2 actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:true customActin:nil];
    
    [(WPLGrid*) _hostingView.containerCell addCell:rootGrid row:1 column:0];
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
                        .requestViewSize(300, 400)
                        .align(WPLAlignment(WPLCellAlignmentCENTER));
    let rootGrid = [WPLGrid gridWithName:@"testContainer"
                                  params:gridParams];
    rootGrid.view.backgroundColor = UIColor.yellowColor;

    for(NSInteger r=0 ; r<rootGrid.rows; r++) {
        for(NSInteger c=0 ; c<rootGrid.columns ; c++) {
            let v = [[UIView alloc] initWithFrame:MICRect(0,0,30,30)];
            v.backgroundColor = UIColor.blueColor;
            [rootGrid addCell:[WPLCell newCellWithView:v
                                                   name:[NSString stringWithFormat:@"c%ld-r%ld", (long)c, (long)r]
                                                 params:WPLCellParams()
                                                           .requestViewSize((gridParams._dimension.colDefs[c].intValue==0)?0:-1, (gridParams._dimension.rowDefs[r].intValue==0)?0:-1)
                                                           .align(WPLAlignment(WPLCellAlignmentCENTER))
                                                           .margin(MICEdgeInsets(5,5,5,5))
                                                    ] row:r column:c];
        }
    }
    
    [(WPLGrid*) _hostingView.containerCell addCell:rootGrid row:1 column:0];
}

/**
 * セルのSTRETCHでの、比率配分レイアウトのテスト
 */
- (void) execTest4:(id)_ {
    [self cleanup];
    _binder = [WPLBinder new];
    var gridParams = WPLGridParams(WPLGridDefinition(),MICSize(1,1))
    .colDefs(@[AUTO,STRC,STRC,STRCx(2),AUTO])
    .rowDefs(@[AUTO,STRC,STRCx(2),STRCx(3),AUTO])
    .cellSpacing(MICSize(5,10))
    .requestViewSize(MICSize(300, 400))
    .align(WPLAlignment(WPLCellAlignmentCENTER));
    let rootGrid = [WPLGrid gridWithName:@"testContainer"
                                  params:gridParams];
    rootGrid.view.backgroundColor = UIColor.yellowColor;
    
    for(NSInteger r=0 ; r<rootGrid.rows; r++) {
        for(NSInteger c=0 ; c<rootGrid.columns ; c++) {
            let v = [[UIView alloc] initWithFrame:MICRect(0,0,30,30)];
            v.backgroundColor = UIColor.cyanColor;
            [rootGrid addCell:[WPLCell newCellWithView:v
                                                   name:[NSString stringWithFormat:@"c%ld-r%ld", (long)c, (long)r]
                                                 params:WPLCellParams()
                                                           .requestViewSize((gridParams._dimension.colDefs[c].intValue==0)?0:-1,
                                                                            ((gridParams._dimension.rowDefs[r].intValue==0)?0:-1))
                                                           .align(WPLAlignment(WPLCellAlignmentCENTER))
                                ] row:r column:c];
        }
    }
    [(WPLGrid*) _hostingView.containerCell addCell:rootGrid row:1 column:0];
    [_hostingView render];
}

- (void) execTest5:(id)_ {
    let vc = [[WPLHostViewController alloc] init];
    [self presentViewController:vc animated:true completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_binder dispose];
    [super viewWillDisappear:animated];
}

- (void) backToMain:(id) _ {
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
