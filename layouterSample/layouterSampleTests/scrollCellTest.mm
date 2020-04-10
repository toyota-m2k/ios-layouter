//
//  scrollCellTest.mm
//  layouterSampleTests
//
//  Created by @toyota-m2k on 2020/04/10.
//  Copyright (c) 2020 @toyota-m2k. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WPLCellHostingView.h"
#import "WPLContainersL.h"
#import "WPLBinder.h"
#import "MICVar.h"
#import "WPLCell.h"
#import "MICUiRectUtil.h"
#import "WPLFrameView.h"
#import "WPLScrollCell.h"

@interface ScrollCellTest : XCTestCase

@end

@implementation ScrollCellTest


- (UIView*) viewOfSize:(CGSize) size {
    return [[UIView alloc] initWithFrame:MICRect(size)];
}

- (void) testBothScroller {
    MICRect rc;
//    id<IWPLCell> cell;

    // Auto > Auto
    let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_LEFT,A_TOP).requestViewSize(VSTRC,VSTRC)];
    let container = rootView.container;
    rootView.frame = MICRect(200,300);

    let scroller = [WPLScrollCell scrollCellWithName:@"rootScroller" params:WPLScrollCellParams(WPLScrollOrientationBOTH).requestViewSize(VSTRC,VSTRC).margin(MICEdgeInsets(10,20,30,40))];
    [container addCell:scroller];
    
    [scroller addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(300,400)] name:@"0" params:WPLCellParams()]];
    
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(), 300);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);
    
    rc = scroller.view.frame;
    XCTAssertEqual(rc.left(), 10);
    XCTAssertEqual(rc.top(), 20);
    XCTAssertEqual(rc.width(), 200-10-30);
    XCTAssertEqual(rc.height(), 300-20-40);

    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.width, 300);
    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.height, 400);
}

- (void) testHorzScroller {
    MICRect rc;
//    id<IWPLCell> cell;

    // Auto > Auto
    let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_LEFT,A_TOP).requestViewSize(VSTRC,VSTRC)];
    let container = rootView.container;
    rootView.frame = MICRect(200,300);

    let scroller = [WPLScrollCell scrollCellWithName:@"rootScroller" params:WPLScrollCellParams(WPLScrollOrientationHORZ).requestViewSize(VSTRC,VSTRC).margin(MICEdgeInsets(10,20,30,40))];
    [container addCell:scroller];
    
    [scroller addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(300,400)] name:@"0" params:WPLCellParams()]];
    
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(), 300);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);
    
    rc = scroller.view.frame;
    XCTAssertEqual(rc.left(), 10);
    XCTAssertEqual(rc.top(), 20);
    XCTAssertEqual(rc.width(), 200-10-30);
    XCTAssertEqual(rc.height(), 300-20-40);

    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.width, 300);
    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.height, 300-20-40);
}

- (void) testVertScroller {
    MICRect rc;
//    id<IWPLCell> cell;

    // Auto > Auto
    let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_LEFT,A_TOP).requestViewSize(VSTRC,VSTRC)];
    let container = rootView.container;
    rootView.frame = MICRect(200,300);

    let scroller = [WPLScrollCell scrollCellWithName:@"rootScroller" params:WPLScrollCellParams(WPLScrollOrientationVERT).requestViewSize(VSTRC,VSTRC).margin(MICEdgeInsets(10,20,30,40))];
    [container addCell:scroller];
    
    [scroller addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(300,400)] name:@"0" params:WPLCellParams()]];
    
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(), 300);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);
    
    rc = scroller.view.frame;
    XCTAssertEqual(rc.left(), 10);
    XCTAssertEqual(rc.top(), 20);
    XCTAssertEqual(rc.width(), 200-10-30);
    XCTAssertEqual(rc.height(), 300-20-40);

    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.width, 200-10-30);
    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.height, 400);
}

- (void) testHorzAuto {
        MICRect rc;
    //    id<IWPLCell> cell;

        // Auto > Auto
        let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_LEFT,A_TOP).requestViewSize(VSTRC,VSTRC)];
        let container = rootView.container;
        rootView.frame = MICRect(200,300);

        let scroller = [WPLScrollCell scrollCellWithName:@"rootScroller" params:WPLScrollCellParams(WPLScrollOrientationHORZ).requestViewSize(VSTRC,VAUTO).margin(MICEdgeInsets(10,20,30,40))];
                // スクロール方向（horz）のauto は無視され、STRCとして動作する。
        [container addCell:scroller];
        
        [scroller addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(300,400)] name:@"0" params:WPLCellParams()]];
        
        [rootView render];
        
        rc = container.view.frame;
        XCTAssertEqual(rc.width(), 200);
        XCTAssertEqual(rc.height(), 300);
        XCTAssertEqual(rc.left(), 0);
        XCTAssertEqual(rc.top(), 0);
        
        rc = scroller.view.frame;
        XCTAssertEqual(rc.left(), 10);
        XCTAssertEqual(rc.top(), 20);
        XCTAssertEqual(rc.width(), 200-10-30);
        XCTAssertEqual(rc.height(), 400);   // auto

        XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.width, 300);
        XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.height, 400);
}

- (void) testVertAuto {
        MICRect rc;
    //    id<IWPLCell> cell;

        // Auto > Auto
        let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_LEFT,A_TOP).requestViewSize(VSTRC,VSTRC)];
        let container = rootView.container;
        rootView.frame = MICRect(200,300);

        let scroller = [WPLScrollCell scrollCellWithName:@"rootScroller" params:WPLScrollCellParams(WPLScrollOrientationVERT).requestViewSize(VAUTO,VSTRC).margin(MICEdgeInsets(10,20,30,40))];
                // スクロール方向（horz）のauto は無視され、STRCとして動作する。
        [container addCell:scroller];
        
        [scroller addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(300,400)] name:@"0" params:WPLCellParams()]];
        
        [rootView render];
        
        rc = container.view.frame;
        XCTAssertEqual(rc.width(), 200);
        XCTAssertEqual(rc.height(), 300);
        XCTAssertEqual(rc.left(), 0);
        XCTAssertEqual(rc.top(), 0);
        
        rc = scroller.view.frame;
        XCTAssertEqual(rc.left(), 10);
        XCTAssertEqual(rc.top(), 20);
        XCTAssertEqual(rc.width(), 300);    // auto
        XCTAssertEqual(rc.height(), 300-20-40);   // strc

        XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.width, 300);
        XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.height, 400);
}

- (void) testStretchAndMax {
        MICRect rc;
    //    id<IWPLCell> cell;

        let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_LEFT,A_TOP).requestViewSize(VSTRC,VSTRC)];
        let container = rootView.container;
        rootView.frame = MICRect(200,300);

    let scroller = [WPLScrollCell scrollCellWithName:@"rootScroller" params:WPLScrollCellParams(WPLScrollOrientationBOTH).requestViewSize(VSTRC,VSTRC).maxWidth(100).maxHeight(200)];
                // スクロール方向（horz）のauto は無視され、STRCとして動作する。
        [container addCell:scroller];
        
        [scroller addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(300,400)] name:@"0" params:WPLCellParams()]];
        
        [rootView render];
        
        rc = container.view.frame;
        XCTAssertEqual(rc.width(), 200);
        XCTAssertEqual(rc.height(), 300);
        XCTAssertEqual(rc.left(), 0);
        XCTAssertEqual(rc.top(), 0);
        
        rc = scroller.view.frame;
        XCTAssertEqual(rc.left(), 0);
        XCTAssertEqual(rc.top(), 0);
        XCTAssertEqual(rc.width(), 100);
        XCTAssertEqual(rc.height(), 200);

        XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.width, 300);
        XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.height, 400);
}

- (void) testAutoAndMax {
    MICRect rc;
    id<IWPLCell> cell;

    let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_LEFT,A_TOP).requestViewSize(VSTRC,VSTRC)];
    let container = rootView.container;
    rootView.frame = MICRect(200,300);

    let scroller = [WPLScrollCell scrollCellWithName:@"rootScroller" params:WPLScrollCellParams(WPLScrollOrientationBOTH).requestViewSize(VAUTO,VAUTO).maxWidth(100).maxHeight(200).align(A_CENTER)];
            // スクロール方向（horz）のauto は無視され、STRCとして動作する。
    [container addCell:scroller];
    
    // min/max内に収まるサイズ --> スクロール不要
    [scroller addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(50,100)] name:@"0" params:WPLCellParams()]];
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(), 300);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);
    
    rc = scroller.view.frame;
    XCTAssertEqual(rc.left(), (200-50)/2);
    XCTAssertEqual(rc.top(), (300-100)/2);
    XCTAssertEqual(rc.width(), 50);
    XCTAssertEqual(rc.height(), 100);

    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.width, 50);
    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.height, 100);

    cell = [scroller findByName:@"0"];
    cell.requestViewSize = MICSize(200,100);    // widthがscrollerのmaxWidthを超える
    [rootView render];

    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(), 300);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);
    
    rc = scroller.view.frame;
    XCTAssertEqual(rc.left(), (200-100)/2);
    XCTAssertEqual(rc.top(), (300-100)/2);
    XCTAssertEqual(rc.width(), 100);    // max
    XCTAssertEqual(rc.height(), 100);

    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.width, 200);
    XCTAssertEqual(((UIScrollView*)scroller.view).contentSize.height, 100);

}


@end
