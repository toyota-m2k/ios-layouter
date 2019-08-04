//
//  WPLSampleView.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLSampleView.h"
#import "MICUiRectUtil.h"
#import "WPLTextCell.h"
#import "WPLSwitchCell.h"
#import "WPLStackPanel.h"
#import "WPLGrid.h"
#import "WPLObservableMutableData.h"
#import "MICVar.h"
#import "WPLBinder.h"

@implementation WPLSampleView {
    WPLStackPanel* _stackPanel;
    WPLBinder* _binder;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self!=nil) {
        _binder = [WPLBinder new];
        
        //self.backgroundColor = UIColor.greenColor;
        _stackPanel = [WPLStackPanel stackPanelViewWithName:@"rootStackPanel"
                                                     margin:MICEdgeInsets()
                                            requestViewSize:MICSize()
                                                 hAlignment:WPLCellAlignmentCENTER
                                                 vAlignment:WPLCellAlignmentCENTER
                                                 visibility:WPLVisibilityVISIBLE
                                          containerDelegate:self
                                                orientation:WPLOrientationVERTICAL];
        [self addSubview:_stackPanel.view];

        let sw1 = [[UISwitch alloc] init];
        [sw1 sizeToFit];
        sw1.on = true;
        let swcell1 = [WPLSwitchCell newCellWithSwitchView:sw1 name:@"no1-switch" margin:MICEdgeInsets(0,0,0,20) requestViewSize:MICSize() hAlignment:(WPLCellAlignmentSTART) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE)];
        [_stackPanel addCell:swcell1];

        [_binder createPropertyWithValue:@true withKey:@"StackVisibility"];
        [_binder bindProperty:@"StackVisibility" withValueOfCell:swcell1 bindingMode:(WPLBindingModeVIEW_TO_SOURCE) customActin:nil];

        [self createStackPanelContents];
        [self createGridContents];
        
        [self addSubview:_stackPanel.view];
        
        [self onChildCellModified:_stackPanel];
    }
    return self;
}

- (void) createGridContents {
    let subGrid = [WPLGrid newGridOfRows:@[@(WPL_GRID_SIZING_AUTO),@(WPL_GRID_SIZING_AUTO)] andColumns:@[@(WPL_GRID_SIZING_AUTO),@(WPL_GRID_SIZING_AUTO),@(WPL_GRID_SIZING_STRETCH)]];
    subGrid.requestViewSize = MICSize(300,0);
    [_stackPanel addCell:subGrid];
    [_binder bindProperty:@"StackVisibility" withBoolStateOfCell:subGrid actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:true bindingMode:(WPLBindingModeSOURCE_TO_VIEW) customActin:nil];
    
    let v1 = [[UIView alloc] init];
    v1.backgroundColor = UIColor.greenColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"gv1" margin:MICEdgeInsets(0,0,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [subGrid addCell:vc1];

    let v2 = [[UIView alloc] init];
    v2.backgroundColor = UIColor.blueColor;
    let vc2 = [WPLCell newCellWithView:v2 name:@"gv2" margin:MICEdgeInsets(0,0,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [subGrid addCell:vc2 row:0 column:1];
    
    let v3 = [[UIView alloc] init];
    v3.backgroundColor = UIColor.greenColor;
    let vc3 = [WPLCell newCellWithView:v3 name:@"gv3" margin:MICEdgeInsets(0,0,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentSTRETCH) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [subGrid addCell:vc3 row:0 column:2];

    let v11 = [[UIView alloc] init];
    v11.backgroundColor = UIColor.greenColor;
    let vc11 = [WPLCell newCellWithView:v11 name:@"gv11" margin:MICEdgeInsets(0,10,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [subGrid addCell:vc11 row:1 column:0];
    
    let v12 = [[UIView alloc] init];
    v12.backgroundColor = UIColor.blueColor;
    let vc12 = [WPLCell newCellWithView:v12 name:@"gv12" margin:MICEdgeInsets(0,10,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [subGrid addCell:vc12 row:1 column:1];
    
    let v13 = [[UIView alloc] init];
    v3.backgroundColor = UIColor.redColor;
    let vc13 = [WPLCell newCellWithView:v13 name:@"gv13" margin:MICEdgeInsets(0,10,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentSTRETCH) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [subGrid addCell:vc13 row:1 column:2];


}

- (void) createStackPanelContents {
    let subStackPanel = [WPLStackPanel stackPanelViewWithName:@"subStackPanel"
                                                       margin:MICEdgeInsets()
                                              requestViewSize:MICSize()
                                                   hAlignment:WPLCellAlignmentCENTER
                                                   vAlignment:WPLCellAlignmentCENTER
                                                   visibility:WPLVisibilityVISIBLE
                                            containerDelegate:self
                                                  orientation:WPLOrientationVERTICAL];
    
    [_stackPanel addCell:subStackPanel];
    [_binder bindProperty:@"StackVisibility" withBoolStateOfCell:subStackPanel actionType:(WPLBoolStateActionTypeVISIBLE_COLLAPSED) negation:false bindingMode:(WPLBindingModeSOURCE_TO_VIEW) customActin:nil];
    
    let tv1 = [[UITextView alloc] init];
    tv1.text = @"Wg";
    [tv1 sizeToFit];
    tv1.text = @"";
    tv1.backgroundColor = UIColor.cyanColor;
    
    let tcell1 = [WPLTextCell newCellWithTextView:tv1 name:@"no1-text" margin:UIEdgeInsets() requestViewSize:MICSize(200,0) hAlignment:WPLCellAlignmentEND vAlignment:WPLCellAlignmentSTART visibility:WPLVisibilityVISIBLE];
    
    let tv2 = [[UITextView alloc] initWithFrame:MICRect(0,0, 300, tv1.frame.size.height)];
    tv2.backgroundColor = UIColor.blueColor;
    
    let tcell2 = [WPLTextCell newCellWithTextView:tv2 name:@"no2-text" margin:MICEdgeInsets(0,20,0,0) requestViewSize:MICSize(0,0) hAlignment:WPLCellAlignmentSTART vAlignment:WPLCellAlignmentSTART visibility:WPLVisibilityVISIBLE];
    
    let tv3 = [[UITextView alloc] initWithFrame:MICRect(0,0, 150, tv1.frame.size.height)];
    tv3.backgroundColor = UIColor.redColor;
    let tcell3 = [WPLTextCell newCellWithTextView:tv3 name:@"no3-text" margin:MICEdgeInsets(0,20,0,0) requestViewSize:MICSize(0,0) hAlignment:WPLCellAlignmentSTRETCH vAlignment:WPLCellAlignmentSTART visibility:WPLVisibilityVISIBLE];
    
    [_binder createPropertyWithValue:@"initial value" withKey:@"text1"];
    [_binder bindProperty:@"text1" withValueOfCell:tcell1 bindingMode:(WPLBindingModeTWO_WAY) customActin:nil];
    [_binder bindProperty:@"text1" withValueOfCell:tcell2 bindingMode:(WPLBindingModeSOURCE_TO_VIEW) customActin:nil];
    
    
    [subStackPanel addCell:tcell1];
    [subStackPanel addCell:tcell2];
    [subStackPanel addCell:tcell3];
    
    let innerPanel = [WPLStackPanel stackPanelViewWithName:@"innerStackPanel"
                                                    margin:MICEdgeInsets(0,20,0,0)
                                           requestViewSize:MICSize()
                                                hAlignment:WPLCellAlignmentCENTER
                                                vAlignment:WPLCellAlignmentCENTER
                                                visibility:WPLVisibilityVISIBLE
                                         containerDelegate:self
                                               orientation:WPLOrientationHORIZONTAL];
    [subStackPanel addCell:innerPanel];
    
    let v1 = [[UIView alloc] init];
    v1.backgroundColor = UIColor.purpleColor;
    let vc1 = [WPLCell newCellWithView:v1 name:@"v1" margin:MICEdgeInsets(0,0,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [innerPanel addCell:vc1];
    let v2 = [[UIView alloc] init];
    v2.backgroundColor = UIColor.purpleColor;
    let vc2 = [WPLCell newCellWithView:v2 name:@"v2" margin:MICEdgeInsets(0,0,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [innerPanel addCell:vc2];
    let v3 = [[UIView alloc] init];
    v3.backgroundColor = UIColor.purpleColor;
    let vc3 = [WPLCell newCellWithView:v3 name:@"v3" margin:MICEdgeInsets() requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
    [innerPanel addCell:vc3];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) onChildCellModified:(id<IWPLCell>) cell {
    MICSize size = [_stackPanel layout];
    MICRect rc(MICPoint(), size);
    rc.moveCenter(MICRect(self.frame).center());
    cell.view.frame = rc;
}

@end
