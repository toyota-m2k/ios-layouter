//
//  WPLSampleView.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/03.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLSampleView.h"
#import "MICUiRectUtil.h"
#import "WPLTextCell.h"
#import "WPLSwitchCell.h"
#import "WPLStackPanel.h"
#import "WPLGrid.h"
#import "WPLFrame.h"
#import "WPLObservableMutableData.h"
#import "MICVar.h"
#import "WPLBinder.h"
#import "WPLGridTestViewController.h"
#import "WPLStackPanelView.h"
#import "MICAutoLayoutBuilder.h"
#import "WPLBindViewController.h"
#import "WPLContainersL.h"

@implementation WPLSampleView {
//    WPLStackPanel* _stackPanel;
    WPLStackPanelView* _stackView;
    WPLBinder* _binder;
    
}
#define NPSw1 @"Sw1"
#define NPSw2 @"Sw2"

#define DPStackVisibility @"StackVisibility"
#define DPGridVisibility @"GridVisibility"
#define DPFrameVisibility @"FrameVisibility"


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self!=nil) {
        _binder = [WPLBinder new];

        _stackView = [WPLStackPanelView stackPanelViewWithName:@"rootPanel"
                                                           params:WPLStackPanelParams()
                                                                    .align(WPLAlignment(WPLCellAlignmentCENTER))
                                                                    .cellSpacing(20)];
//        _stackPanel = [WPLStackPanel stackPanelWithName:@"rootStackPanel"
//                                                 params:WPLStackPanelParams().align(WPLAlignment(WPLCellAlignmentCENTER)).cellSpacing(20)
//                                              superview:self
//                                      containerDelegate:self];
        [self addSubview:_stackView];
        MICAutoLayoutBuilder(self)
        .fitToSafeArea(_stackView)
        .activate();

        let selectionPanel = [WPLStackPanel stackPanelWithName:@"selectionPanel" params:WPLStackPanelParams().cellSpacing(10).orientation(WPLOrientationHORIZONTAL).margin(0,0,0,20)];
        [_stackView.container addCell:selectionPanel];
        
        
        let btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn1 setTitle:@"Next Test" forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(changeTestMode:) forControlEvents:(UIControlEventTouchUpInside)];
        [btn1 sizeToFit];
        let btncell1 = [WPLCell newCellWithView:btn1 name:@"modeButton" params:WPLCellParams()];
        [selectionPanel addCell:btncell1];

        let btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn2 setTitle:@"Back" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(backToPrev:) forControlEvents:(UIControlEventTouchUpInside)];
        [btn2 sizeToFit];
        let btncell2 = [WPLCell newCellWithView:btn2 name:@"backButton" params:WPLCellParams()];
        [selectionPanel addCell:btncell2];

        let btnStack = [WPLStackPanel stackPanelWithName:@"switchPanel" params:WPLStackPanelParams().cellSpacing(10).orientation(WPLOrientationHORIZONTAL)];
        [_stackView.container addCell:btnStack];
        
        
        let sw1 = [[UISwitch alloc] init];
        [sw1 sizeToFit];
        sw1.on = true;
        let swcell1 = [WPLSwitchCell newCellWithView:sw1 name:@"no1-switch" params:WPLCellParams()];
        [btnStack addCell:swcell1];

        let sw2 = [[UISwitch alloc] init];
        [sw2 sizeToFit];
        sw2.on = true;
        let swcell2 = [WPLSwitchCell newCellWithView:sw2 name:@"no2-switch" params:WPLCellParams()];
        [btnStack addCell:swcell2];

        WPLBinderBuilder bb(_binder);
        bb
        .property(NPSw1, false)
        .property(NPSw2, false)
        .dependentProperty(DPGridVisibility, ^id(id<IWPLDelegatedDataSource>) {
            return [self->_binder propertyForKey:NPSw1].value;
        }, NPSw1, nil)
        .dependentProperty(DPStackVisibility, ^id(id<IWPLDelegatedDataSource>) {
            return [self->_binder propertyForKey:NPSw2].value;
        }, NPSw2, nil)
        .dependentProperty(DPFrameVisibility, ^id(id<IWPLDelegatedDataSource>) {
            if(![self->_binder propertyForKey:NPSw1].boolValue && ![self->_binder propertyForKey:NPSw2].boolValue) {
                return @true;
            } else {
                return @false;
            }
        }, NPSw1, NPSw2, nil)
        .bind(NPSw1, swcell1, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT)
        .bind(NPSw2, swcell2, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT);
        
//        [_binder createPropertyWithValue:@true withKey:@"StackVisibility"];
//        [_binder bindProperty:@"StackVisibility" withValueOfCell:swcell1 bindingMode:(WPLBindingModeVIEW_TO_SOURCE_WITH_INIT) customActin:nil];

        [self createStackPanelContents];
        [self createGridContents];
        [self createFrameContents];
    }
    return self;
}

- (UIViewController*) presentViewController {
    UIResponder* responder = self;
    while ((responder = responder.nextResponder)!=nil) {
        if([responder isKindOfClass:UIViewController.class]) {
            return (UIViewController*)responder;
        }
    }
    return nil;
}

- (void) backToPrev:(id) _ {
    let vc = self.presentViewController;
    if([vc isKindOfClass:WPLBindViewController.class]) {
        [(WPLBindViewController*)vc backToPrev:nil];
    }
}

- (void) changeTestMode:(id)_ {
    let viewController = self.presentViewController;
    if(nil!=viewController) {
//        [viewController presentationController]
        let vc = [[WPLGridTestViewController alloc] init];
        // [vc present]
        
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [viewController presentViewController:vc animated:true completion:nil];
    }
    
}

- (void) createFrameContents {
    let subFrame = [WPLFrame frameWithName:@"subFrame" params:WPLCellParams().requestViewSize(0,0)];
    [_stackView.container addCell:subFrame];
    WPLBinderBuilder bb(_binder);
    bb.bind(DPFrameVisibility, subFrame, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false);
    
    let v1 = [UIView new];
    v1.backgroundColor=UIColor.greenColor;
    let c1 = [WPLCell newCellWithView:v1 name:@"fv1" params:WPLCellParams().requestViewSize(100,100)];
    [subFrame addCell:c1];

    let v2 = [UIView new];
    v2.backgroundColor=UIColor.orangeColor;
    let c2 =[WPLCell newCellWithView:v2 name:@"fv2" params:WPLCellParams().requestViewSize(100,100).margin(50,50,0,0)];
    [subFrame addCell:c2];
}

- (void) createGridContents {
    let subGrid = [WPLGrid gridWithName:@"subGrid"
                                 params:WPLGridParams()
                                        .requestViewSize(MICSize(300,0))
                                        .colDefs(@[AUTO,AUTO,STRC,AUTO])
                                        .rowDefs(@[AUTO,AUTO,AUTO])];
    subGrid.view.backgroundColor = UIColor.yellowColor;
    [_stackView.container addCell:subGrid];
//    [_binder bindProperty:@"StackVisibility" withBoolStateOfCell:subGrid actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:true customActin:nil];
    WPLBinderBuilder bb(_binder);
    bb.bind(DPGridVisibility, subGrid, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false);

    let v1 = [[UIView alloc] init];
    v1.backgroundColor = UIColor.greenColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"gv1" params:WPLCellParams().margin(0,0,5,0).requestViewSize(20,20).align(A_CENTER, A_CENTER)];
    [subGrid addCell:vc1];

    let v2 = [[UIView alloc] init];
    v2.backgroundColor = UIColor.cyanColor;
    let vc2 = [WPLCell newCellWithView:v2 name:@"gv2" params:WPLCellParams().margin(0,0,5,0).requestViewSize(20,40).align(A_CENTER,A_CENTER)];
    [subGrid addCell:vc2 row:0 column:1];
    
    let v3 = [[UIView alloc] init];
    v3.backgroundColor = UIColor.greenColor;
    let vc3 = [WPLCell newCellWithView:v3 name:@"gv3" params:WPLCellParams().requestViewSize(-1,20).vertAlign(WPLCellAlignmentCENTER)];
    [subGrid addCell:vc3 row:0 column:2];

    let v11 = [[UIView alloc] init];
    v11.backgroundColor = UIColor.greenColor;
    let vc11 = [WPLCell newCellWithView:v11 name:@"gv11" params:WPLCellParams().margin(0,10,5,0).requestViewSize(20,-1).horzAlign(WPLCellAlignmentCENTER)];
    [subGrid addCell:vc11 row:1 column:0 rowSpan:2 colSpan:1];
    
    let v12 = [[UIView alloc] init];
    v12.backgroundColor = UIColor.blueColor;
    let vc12 = [WPLCell newCellWithView:v12 name:@"gv12" params:WPLCellParams().margin(0,10,5,0).requestViewSize(20,20).align(A_CENTER,A_CENTER)];
    [subGrid addCell:vc12 row:1 column:1];
    
    let v13 = [[UIView alloc] init];
    v13.backgroundColor = UIColor.redColor;
    let vc13 = [WPLCell newCellWithView:v13 name:@"gv13" params:WPLCellParams().margin(0,10,0,0).requestViewSize(-1,20).vertAlign(WPLCellAlignmentCENTER)];
    [subGrid addCell:vc13 row:1 column:2];

    
    let v24 = [[UIView alloc] init];
    v24.backgroundColor = UIColor.blueColor;
    let vc24 = [WPLCell newCellWithView:v24 name:@"gv24" params:WPLCellParams().margin(5,10,0,0).requestViewSize(20,20).align(A_CENTER,A_CENTER)];
    [subGrid addCell:vc24 row:2 column:3];

    let v22 = [[UIView alloc] init];
    v22.backgroundColor = UIColor.orangeColor;
    let vc22 = [WPLCell newCellWithView:v22 name:@"gv22" params:WPLCellParams().margin(0,10,0,0).requestViewSize(-1,20).vertAlign(WPLCellAlignmentCENTER)];
    [subGrid addCell:vc22 row:2 column:1 rowSpan:1 colSpan:2];

}

- (void) createStackPanelContents {
    let subStackPanel = [WPLStackPanel stackPanelWithName:@"subStackPanel"
                                                   params:WPLStackPanelParams()
                                                            .align(WPLAlignment(WPLCellAlignmentCENTER))
                                                            .cellSpacing(10)];
    subStackPanel.view.backgroundColor = UIColor.yellowColor;
    [_stackView.container addCell:subStackPanel];
    
    WPLBinderBuilder bb(_binder);
    bb.bind(DPStackVisibility, subStackPanel, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false);
//
//    [_binder bindProperty:@"StackVisibility" withBoolStateOfCell:subStackPanel actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:false customActin:nil];
    
    let tv1 = [[UITextView alloc] init];
    tv1.text = @"Wg";
    [tv1 sizeToFit];
    tv1.text = @"";
    tv1.backgroundColor = UIColor.cyanColor;
    
    let tcell1 = [WPLTextCell newCellWithView:tv1 name:@"no1-text" params:WPLCellParams().requestViewSize(200,0).align(A_RIGHT, A_START)];
    
    let tv2 = [[UITextView alloc] initWithFrame:MICRect(0,0, 300, tv1.frame.size.height)];
    tv2.backgroundColor = UIColor.blueColor;
    
    let tcell2 = [WPLTextCell newCellWithView:tv2 name:@"no2-text" params:WPLCellParams().align(A_START, A_START)];
    
    let tv3 = [[UITextView alloc] initWithFrame:MICRect(0,0, 150, tv1.frame.size.height)];
    tv3.backgroundColor = UIColor.redColor;
    let tcell3 = [WPLTextCell newCellWithView:tv3 name:@"no3-text"
                                       params:WPLCellParams().requestViewSize(-1,-1)];
    [_binder createPropertyWithValue:@"initial value" withKey:@"text1"];
    [_binder bindProperty:@"text1" withValueOfCell:tcell1 bindingMode:(WPLBindingModeTWO_WAY) customActin:nil];
    [_binder bindProperty:@"text1" withValueOfCell:tcell2 bindingMode:(WPLBindingModeSOURCE_TO_VIEW) customActin:nil];
    
    
    [subStackPanel addCell:tcell1];
    [subStackPanel addCell:tcell2];
    [subStackPanel addCell:tcell3];

    let innerPanel = [WPLStackPanel stackPanelWithName:@"innerStackPanel"
                                                params:WPLStackPanelParams()
                                                        .margin(MICEdgeInsets(0,0,0,0))
                                                        .orientation(WPLOrientationHORIZONTAL)];
    
//    let innerPanel = [WPLStackPanel stackPanelViewWithName:@"innerStackPanel"∫
//                                                    margin:MICEdgeInsets(0,20,0,0)
//                                           requestViewSize:MICSize()
//                                                hAlignment:WPLCellAlignmentCENTER
//                                                vAlignment:WPLCellAlignmentCENTER
//                                                visibility:WPLVisibilityVISIBLE
//                                         containerDelegate:self
//                                               orientation:WPLOrientationHORIZONTAL];
    [subStackPanel addCell:innerPanel];
    
    let v1 = [[UIView alloc] init];
    v1.backgroundColor = UIColor.purpleColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"v1" params:WPLCellParams().margin(0,0,5,0).requestViewSize(20,20).align(A_CENTER,A_CENTER)];
    [innerPanel addCell:vc1];
    let v2 = [[UIView alloc] init];
    v2.backgroundColor = UIColor.purpleColor;
    let vc2 = [WPLCell newCellWithView:v2 name:@"v2" params:WPLCellParams().margin(0,0,5,0).requestViewSize(20,20).align(A_CENTER, A_CENTER)];
    [innerPanel addCell:vc2];
    let v3 = [[UIView alloc] init];
    v3.backgroundColor = UIColor.purpleColor;
    let vc3 = [WPLCell newCellWithView:v3 name:@"v3" params:WPLCellParams().requestViewSize(20,20).align(A_CENTER,A_CENTER)];
    [innerPanel addCell:vc3];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)didMoveToSuperview {
    if(self.superview==nil) {
        [_binder dispose];
//        [_stackView.container dispose];
    }
}

@end
