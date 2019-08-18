//
//  TabViewController.m
//  LayoutDemo
//
//  Created by M.TOYOTA on 2014/12/17.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "TabViewController.h"
#import "MICUiDsTabView.h"
#import "MICUiRectUtil.h"
#import "MICUiDsDefaults.h"
#import "MICUiRelativeLayout.h"
#import "MICUiAccordionCellViewSwicherProc.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"
#import "MICKeyValueObserver.h"

#define TAB_HEIGHT 30

@implementation TabViewController {
    MICUiRelativeLayout* _mainLayouter;
    MICUiDsTabView* _topTab;
    MICUiDsTabView* _bottomTab;
    MICUiDsTabView* _leftTab;
    MICUiDsTabView* _rightTab;
    MICUiSwitchingViewMediator* _switcher;
    MICUiAccordionCellViewSwicherProc* _swicherProc;
//    bool _changing;
//    bool _reserved;
    MICKeyValueObserver* _observer;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    
    let rootView = [UIView new];
    [self.view addSubview:rootView];
    MICAutoLayoutBuilder lb(self.view);
    lb.fitToSafeArea(rootView);

//    _changing = false;
    
    _swicherProc = [[MICUiAccordionCellViewSwicherProc alloc] init];
    
    MICSize contentSize = self.view.frame.size;
//    contentSize.height -= 100;
    _mainLayouter = [[MICUiRelativeLayout alloc] init];
    _mainLayouter.overallSize = contentSize;
    _mainLayouter.parentView = rootView;
//    _mainLayouter.marginTop = 50;
//    _mainLayouter.marginBottom = 50;

    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    MICRect bkrc = MICRect(200, 50);
    back.frame = bkrc;
    back.backgroundColor = [UIColor blackColor];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [_mainLayouter addChild:back
                    andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                     left:[MICUiRelativeLayoutAttachInfo newAttachCenter]
                                                                    right:[MICUiRelativeLayoutAttachInfo newAttachCenter]
                                                                     vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                      top:[MICUiRelativeLayoutAttachInfo newAttachCenter]
                                                                   bottom:[MICUiRelativeLayoutAttachInfo newAttachCenter]]];


    
    
//    MICUiStatefulResource* colors = [[MICUiStatefulResource alloc] initWithDictionary:@{
//                                                                                        MICUiStatefulBgColorNORMAL: [UIColor darkGrayColor],
//                                                                                        MICUiStatefulBgColorSELECTED: [UIColor greenColor],
//                                                                                        MICUiStatefulBgColorACTIVATED: [UIColor yellowColor],
//                                                                                        MICUiStatefulBgColorDISABLED: [UIColor darkGrayColor],
//                                                                                        
//                                                                                        MICUiStatefulFgColorNORMAL: [UIColor whiteColor],
//                                                                                        MICUiStatefulFgColorSELECTED: [UIColor blackColor],
//                                                                                        MICUiStatefulFgColorACTIVATED: [UIColor blackColor],
//                                                                                        MICUiStatefulFgColorDISABLED: [UIColor grayColor],
//                                                                                        
//                                                                                        MICUiStatefulBorderColorNORMAL: [UIColor whiteColor],
//                                                                                        }];
    
//    MICRect rcBounds = self.view.bounds;
//    MICRect rcTab;
    int tabid = 0;
    NSString *tabname;

//    rcTab = rcBounds;
//    rcTab.deflate(TAB_HEIGHT, MIN(rcBounds.height(),rcBounds.width())*2/3, TAB_HEIGHT, 0);
    _bottomTab = [[MICUiDsTabView alloc] initWithFrame:MICRect(0,200)];
    _bottomTab.labelAlignment = MICUiAlignExFILL;
    _bottomTab.orientation = MICUiVertical;
    _bottomTab.labelPos = MICUiPosBOTTOM|MICUiPosRIGHT;
    _bottomTab.movableLabel = false;
    _bottomTab.attachBottom = true;
    _bottomTab.tabHeight = 20;
    _bottomTab.tabWidth = 0;
    _bottomTab.contentMargin = MICEdgeInsets(10,0,10,0);
    _bottomTab.backgroundColor = UIColor.purpleColor;
    _bottomTab.accordionDelegate = _swicherProc;
    

    for( int i=0 ; i<5 ; i++) {
        tabname = [NSString stringWithFormat:@"Tab-%d", ++tabid];
        [_bottomTab addTab:tabname label:tabname color:nil icon:nil updateView:false];
    }

    [_mainLayouter addChild:_bottomTab
              andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingFree]
                                                               left:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                              right:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                               vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                top:[MICUiRelativeLayoutAttachInfo newAttachFree]
                                                             bottom:[MICUiRelativeLayoutAttachInfo newAttachParent:0]]];

    
    
    
    
//    rcTab = rcBounds;
//    rcTab.deflate(TAB_HEIGHT, rcBounds.height()*2/3, TAB_HEIGHT, 0);
    _topTab = [[MICUiDsTabView alloc] initWithFrame:MICRect(0,200)];
    _topTab.labelAlignment = MICUiAlignExFILL;
    _topTab.orientation = MICUiVertical;
    _topTab.labelPos = MICUiPosTOP|MICUiPosLEFT;
    _topTab.movableLabel = false;
    _topTab.attachBottom = false;
    _topTab.tabHeight = 20;
    _topTab.tabWidth = 0;
    _topTab.contentMargin = MICEdgeInsets(10,0,10,0);
    _topTab.backgroundColor = UIColor.cyanColor;
    _topTab.accordionDelegate = _swicherProc;
    
    
    for( int i=0 ; i<5 ; i++) {
        tabname = [NSString stringWithFormat:@"Tab-%d", ++tabid];
        [_topTab addTab:tabname label:tabname color:nil icon:nil updateView:false];
    }
    
    [_mainLayouter addChild:_topTab
                    andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingFree]
                                                                     left:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                                    right:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                                     vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                      top:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                                   bottom:[MICUiRelativeLayoutAttachInfo newAttachFree]]];

    
//    rcTab = rcBounds;
//    rcTab.size.width = rcBounds.width()/3;
    _leftTab = [[MICUiDsTabView alloc] initWithFrame:MICRect(150,0)];
    _leftTab.labelAlignment = MICUiAlignExFILL;
    _leftTab.orientation = MICUiHorizontal;
    _leftTab.labelPos = MICUiPosTOP|MICUiPosLEFT;
    _leftTab.movableLabel = false;
    _leftTab.attachBottom = false;
    _leftTab.tabHeight = 20;
    _leftTab.tabWidth = 0;
    _leftTab.contentMargin = MICEdgeInsets(10,0,10,0);
    _leftTab.backgroundColor = [UIColor yellowColor]; //MICCOLOR_PANEL_FACE;
    _leftTab.labelView.backgroundColor = [UIColor greenColor];
    _leftTab.turnOver = true;
    _leftTab.accordionDelegate = _swicherProc;
    _leftTab.tabBar.name = @"left-tab-bar";
    
    
    for( int i=0 ; i<5 ; i++) {
        tabname = [NSString stringWithFormat:@"Tab-%d", ++tabid];
        [_leftTab addTab:tabname label:tabname color:nil icon:nil updateView:false];
    }
    
    [_mainLayouter addChild:_leftTab
                    andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                     left:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                                    right:[MICUiRelativeLayoutAttachInfo newAttachFree]
                                                                     vert:[MICUiRelativeLayoutScalingInfo newScalingFree]
                                                                      top:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:_topTab inDistance:10]
                                                                   bottom:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:_bottomTab inDistance:10]]];

    
    
    
    
//    rcTab = rcBounds;
//    rcTab.size.width = rcBounds.width()/3;
    _rightTab = [[MICUiDsTabView alloc] initWithFrame:MICRect(150,0)];
    _rightTab.labelAlignment = MICUiAlignExFILL;
    _rightTab.orientation = MICUiHorizontal;
    _rightTab.labelPos = MICUiPosBOTTOM|MICUiPosRIGHT;
    _rightTab.rotateRight = false;
    _rightTab.movableLabel = false;
    _rightTab.attachBottom = false;
    _rightTab.tabHeight = 20;
    _rightTab.tabWidth = 0;
    _rightTab.contentMargin = MICEdgeInsets(10,0,10,0);
    _rightTab.backgroundColor = [UIColor purpleColor]; //MICCOLOR_PANEL_FACE;
    _rightTab.labelView.backgroundColor = [UIColor orangeColor];
    _rightTab.turnOver = false;
    _rightTab.accordionDelegate = _swicherProc;
    _rightTab.tabBar.name = @"right-tab-bar";
    
    
    for( int i=0 ; i<5 ; i++) {
        tabname = [NSString stringWithFormat:@"Tab-%d", ++tabid];
        [_rightTab addTab:tabname label:tabname color:nil icon:nil updateView:false];
    }
    
    [_mainLayouter addChild:_rightTab
                    andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                     left:[MICUiRelativeLayoutAttachInfo newAttachFree]
                                                                    right:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                                     vert:[MICUiRelativeLayoutScalingInfo newScalingFree]
                                                                      top:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:_topTab inDistance:10]
                                                                   bottom:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:_bottomTab inDistance:10]]];
    
    
    _switcher = [[MICUiSwitchingViewMediator alloc] init];
    _swicherProc.switcher = _switcher;
    _swicherProc.layouter = _mainLayouter;
    
    [_switcher registerView:_topTab ofName:@"top" callback:_swicherProc];
    [_switcher registerView:_bottomTab ofName:@"bottom" callback:_swicherProc];
    [_switcher registerView:_leftTab ofName:@"left" callback:_swicherProc];
    [_switcher registerView:_rightTab ofName:@"right" callback:_swicherProc];
   
    _switcher.delegate = _swicherProc;
    [_switcher setExclusiveViewGroup:@[@"top",@"bottom"]];
    [_switcher setCompanionViewGroup:@[@"left", @"right"]];
    [_switcher setAlternativeViewGroup:@[@"top"] andAnotherGroup:@[@"left", @"right"]];

    [_mainLayouter updateLayout:false onCompleted:nil];
    [_switcher showView:@"top" updateView:true];                // _mainLayouterのupdateLayoutを一度実行してから、_switcherのshowViewを呼ぶ
    
    
    [_bottomTab.tabBar beginCustomizingWithLongPress:true endWithTap:true];
    [_topTab.tabBar beginCustomizingWithLongPress:true endWithTap:true];
    [_leftTab.tabBar beginCustomizingWithLongPress:true endWithTap:true];
    
    _observer = [[MICKeyValueObserver alloc] initWithActor:rootView];
    [_observer add:@"frame" listener:self handler:@selector(onViewSizePropertyChanged:target:)];
    [_observer add:@"bounds" listener:self handler:@selector(onViewSizePropertyChanged:target:)];
}

- (void) onViewSizePropertyChanged:(id<IMICKeyValueObserverItem>)info target:(id)target {
    _mainLayouter.overallSize = ((UIView*)target).bounds.size;
    [_mainLayouter updateLayout:true onCompleted:nil];
}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_observer dispose];
}

#if 0
- (void)setViewVisibility:(UIView *)view visible:(bool)show onCompleted:(void (^)(BOOL))onCompleted{
    if([view isKindOfClass:MICUiDsTabView.class]) {
        bool anim = !_changing;
        if(show) {
            [((MICUiDsTabView*)view) unfold:anim onCompleted:onCompleted];
        } else {
            [((MICUiDsTabView*)view) fold:anim onCompleted:onCompleted];
        }
    } else {
        if(nil!=onCompleted) {
            onCompleted(false);
        }
    }
    return;
}

- (bool)isViewVisible:(UIView *)view {
    if([view isKindOfClass:MICUiDsTabView.class]) {
        return !((MICUiDsTabView*)view).folding;
    }
    return false;
}

- (void)accordionCellFolded:(MICUiAccordionCellView *)sender fold:(BOOL)folded lastFrame:(CGRect)frame {
    if(!_changing) {
        _reserved = true;
        [_switcher setViewVisibility:[_switcher getViewName:sender] visible:!folded updateView:true];
    }
//        [_mainLayouter requestRecalcLayout];
//        [_mainLayouter updateLayout:true onCompleted:nil];

    //    [_mainLayouter cancelCellSizeReservation:sender];
//    [_mainLayouter requestRecalcLayout];
}

- (void)accordionCellFolding:(MICUiAccordionCellView *)sender fold:(BOOL)folded lastFrame:(CGRect)frame {
//    [_switcher setViewVisibility:[_switcher getViewName:sender] visible:!folded updateView:true];
    if(!_changing) {
        [_mainLayouter updateLayoutWithReservingCell:sender atLocation:frame animated:true onCompleted:nil];
    }
    
//    [_mainLayouter reserveCell:sender toLocation:frame];
//    [_mainLayouter requestRecalcLayout];
//    [_mainLayouter updateLayout:true onCompleted:^(BOOL r){
//        [_mainLayouter cancelCellLocationReservation:sender];
//    }];
}

- (void)willSwitchViewVisibility:(MICUiSwitchingViewMediator *)sender {
    _changing = true;
    
}

- (void)didSwitchViewVisibility:(MICUiSwitchingViewMediator *)sender changed:(bool)changed {
    if(changed||_reserved) {
        [_mainLayouter requestRecalcLayout];
        [_mainLayouter updateLayout:true onCompleted:nil];
        _reserved = false;
    }
    _changing = false;
}

#endif

@end
