//
//  gridTest.m
//  layouterSampleTests
//
//  Created by @toyota-m2k on 2019/11/05.
//  Copyright (c) 2019 @toyota-m2k. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WPLCellHostingView.h"
#import "WPLContainersL.h"
#import "WPLBinder.h"
#import "MICVar.h"
#import "WPLCell.h"
#import "MICUiRectUtil.h"
#import "WPLGrid.h"



@interface gridTest : XCTestCase

@end

@implementation gridTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (UIView*) viewOfSize:(CGSize) size {
    return [[UIView alloc] initWithFrame:MICRect(size)];
}

/**
 * ルートグリッドの横幅を親View (WPLGridView)の幅にフィット(stretch)させ、
 * 0カラム目はコンテント依存の自動サイズ(auto)
 * 1カラム目に残りを割り当てる(stretch)
 */
- (void)testFitToParent {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams().dimension(WPLGridDefinition().rows(@[AUTO]).cols(@[AUTO,STRC])).requestViewSize(MICSize(S_STRC,S_AUTO))];
    rootView.containerCell = container;
    
    // cell(0,0) :size:40,20 --> AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(40,20)] name:@"0,0" params:WPLCellParams()] row:0 column:0];
    
    // cell(0,1) :size:0,0 --> Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,0)] name:@"0,1" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_STRC))] row:0 column:1];

    rootView.frame = MICRect(200,100);
    [rootView render];

    MICRect frame;
    frame = container.view.frame;
    XCTAssertEqual(frame.width(), 200);
    XCTAssertEqual(frame.height(), 20);

    
    UIView* view = [container findByName:@"0,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 0);

    
    view = [container findByName:@"0,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 200-40);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 40);
    XCTAssertEqual(frame.top(), 0);
}

/**
 * コンテントのサイズからグリッドサイズを決定する。
 * cell(0,1), cell(1,0)は、stretch指定とし、それぞれ、cell(1,0), cell(1,1) の幅に合わせて伸長する。
 */
- (void)testFitContent {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams()
    .dimension(WPLGridDefinition()
                  .rows(@[AUTO,AUTO])
                  .cols(@[AUTO,AUTO]))
    .requestViewSize(MICSize(S_AUTO,S_AUTO))];
    rootView.containerCell = container;
    
    // cell(0,0) :size:40,20 --> AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(40,20)] name:@"0,0" params:WPLCellParams()] row:0 column:0];
    
    // cell(0,1) :size:0,0 --> Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,0)] name:@"0,1" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_STRC))] row:0 column:1];
    
    // cell(1,0) : size:0,0 --> Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,0)] name:@"1,0" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_STRC))] row:1 column:0];

    // cell(0,0) :size:100,20 --> AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,30)] name:@"1,1" params:WPLCellParams()] row:1 column:1];

    rootView.frame = MICRect(200,100);
    [rootView render];

    MICRect frame;
    frame = rootView.containerCell.view.frame;
    XCTAssertEqual(frame.width(), 140);
    XCTAssertEqual(frame.height(), 50);

    
    UIView* view = [container findByName:@"0,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 0);

    
    view = [container findByName:@"0,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 100);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 40);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"1,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 30);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 20);

    view = [container findByName:@"1,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 100);
    XCTAssertEqual(frame.height(), 30);
    XCTAssertEqual(frame.left(), 40);
    XCTAssertEqual(frame.top(), 20);
}

- (void)testStretchToSpan {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams()
    .dimension(WPLGridDefinition()
                  .rows(@[AUTO,AUTO,AUTO])
                  .cols(@[AUTO,STRC,AUTO]))
    .requestViewSize(MICSize(S_AUTO,S_AUTO))];
    rootView.containerCell = container;
   
    // | 40 | S | 60 |
    // |  S |  150   |
   
    // cell(0,0) :size:40,20 --> AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(40,20)] name:@"0,0" params:WPLCellParams()] row:0 column:0];
    
    // cell(0,1) :size:0,0 --> Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,0)] name:@"0,1" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_STRC))] row:0 column:1];

    // cell(0,2) :size:60,0 --> auto, Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(60,0)] name:@"0,2" params:WPLCellParams().requestViewSize(MICSize(S_AUTO, S_STRC))] row:0 column:2];

    // cell(1,0) : size:0,30 --> Stretch, auto
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,30)] name:@"1,0" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_AUTO))] row:1 column:0];

    // cell(1,1) :size:150,0 --> Stretch, AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,0)] name:@"1,1" params:WPLCellParams().requestViewSize(MICSize(S_AUTO,S_STRC))] row:1 column:1 rowSpan:1 colSpan:2];

    rootView.frame = MICRect(200,100);
    [rootView render];

    MICRect frame;
    frame = rootView.containerCell.view.frame;
    XCTAssertEqual(frame.width(), 190);
    XCTAssertEqual(frame.height(), 50);

    
    UIView* view = [container findByName:@"0,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 0);

    
    view = [container findByName:@"0,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 90);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 40);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"0,2"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 60);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 130);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"1,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 30);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 20);

    view = [container findByName:@"1,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 150);
    XCTAssertEqual(frame.height(), 30);
    XCTAssertEqual(frame.left(), 40);
    XCTAssertEqual(frame.top(), 20);
}

- (void)testCellSpacingTest {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams()
                     .cellSpacing(10, 20)
                     .dimension(WPLGridDefinition()
                          .rows(@[AUTO,AUTO,AUTO])
                          .cols(@[AUTO,STRC,AUTO]))
                    .requestViewSize(MICSize(S_AUTO,S_AUTO))];
    rootView.containerCell = container;
    
    // cell(0,0) :size:40,20 --> AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(40,20)] name:@"0,0" params:WPLCellParams()] row:0 column:0];
    
    // cell(0,1) :size:0,0 --> Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,0)] name:@"0,1" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_STRC))] row:0 column:1];

    // cell(0,2) :size:60,0 --> auto, Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(60,0)] name:@"0,2" params:WPLCellParams().requestViewSize(MICSize(S_AUTO, S_STRC))] row:0 column:2];

    // cell(1,0) : size:0,30 --> Stretch, auto
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,30)] name:@"1,0" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_AUTO))] row:1 column:0];

    // cell(1,1) :size:0,30 --> Stretch, AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,0)] name:@"1,1" params:WPLCellParams().requestViewSize(MICSize(S_AUTO,S_STRC))] row:1 column:1 rowSpan:1 colSpan:2];

    rootView.frame = MICRect(200,100);
    [rootView render];

    MICRect frame;
    frame = rootView.containerCell.view.frame;
    XCTAssertEqual(frame.width(), 210);
    XCTAssertEqual(frame.height(), 70);

    
    UIView* view = [container findByName:@"0,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 0);

    
    view = [container findByName:@"0,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 90);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 50);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"0,2"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 60);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 150);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"1,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 30);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 40);

    view = [container findByName:@"1,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 150);
    XCTAssertEqual(frame.height(), 30);
    XCTAssertEqual(frame.left(), 50);
    XCTAssertEqual(frame.top(), 40);
}

- (void)testRootStretchTest {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams()
                     .dimension(WPLGridDefinition()
                          .rows(@[AUTO,AUTO,AUTO])
                          .cols(@[AUTO,STRC,AUTO]))
                    .requestViewSize(MICSize(S_STRC,S_AUTO))];
    rootView.containerCell = container;
    
    // cell(0,0) :size:40,20 --> AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(40,20)] name:@"0,0" params:WPLCellParams()] row:0 column:0];
    
    // cell(0,1) :size:0,0 --> Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,0)] name:@"0,1" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_STRC))] row:0 column:1];

    // cell(0,2) :size:60,0 --> auto, Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(60,0)] name:@"0,2" params:WPLCellParams().requestViewSize(MICSize(S_AUTO, S_STRC))] row:0 column:2];

    // cell(1,0) : size:0,30 --> Stretch, auto
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,30)] name:@"1,0" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_AUTO))] row:1 column:0 rowSpan:0 colSpan:3];

    rootView.frame = MICRect(200,100);
    [rootView render];

    MICRect frame;
    frame = rootView.containerCell.view.frame;
    XCTAssertEqual(frame.width(), 200);
    XCTAssertEqual(frame.height(), 50);

    
    UIView* view = [container findByName:@"0,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 0);

    
    view = [container findByName:@"0,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 100);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 40);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"0,2"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 60);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 140);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"1,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 200);
    XCTAssertEqual(frame.height(), 30);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 20);

}

- (void)testRootStretchWithCellSpacing {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams()
                     .cellSpacing(MICSize(20,10))
                     .dimension(WPLGridDefinition()
                          .rows(@[AUTO,AUTO,AUTO])
                          .cols(@[AUTO,STRC,AUTO]))
                    .requestViewSize(MICSize(S_STRC,S_AUTO))];
    rootView.containerCell = container;
    
    // cell(0,0) :size:40,20 --> AUTO (no-size)
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(40,20)] name:@"0,0" params:WPLCellParams()] row:0 column:0];
    
    // cell(0,1) :size:0,0 --> Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,0)] name:@"0,1" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_STRC))] row:0 column:1];

    // cell(0,2) :size:60,0 --> auto, Stretch
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(60,0)] name:@"0,2" params:WPLCellParams().requestViewSize(MICSize(S_AUTO, S_STRC))] row:0 column:2];

    // cell(1,0) : size:0,30 --> Stretch, auto
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,30)] name:@"1,0" params:WPLCellParams().requestViewSize(MICSize(S_STRC, S_AUTO))] row:1 column:0 rowSpan:0 colSpan:3];

    rootView.frame = MICRect(200,100);
    [rootView render];

    MICRect frame;
    frame = rootView.containerCell.view.frame;
    XCTAssertEqual(frame.width(), 200);
    XCTAssertEqual(frame.height(), 60);

    
    UIView* view = [container findByName:@"0,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 40);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 0);

    
    view = [container findByName:@"0,1"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 60);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 60);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"0,2"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 60);
    XCTAssertEqual(frame.height(), 20);
    XCTAssertEqual(frame.left(), 140);
    XCTAssertEqual(frame.top(), 0);

    view = [container findByName:@"1,0"].view;
    frame = view.frame;
    XCTAssertEqual(frame.width(), 200);
    XCTAssertEqual(frame.height(), 30);
    XCTAssertEqual(frame.left(), 0);
    XCTAssertEqual(frame.top(), 30);

}

- (void) testAutoAuto {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams()
                     .dimension(WPLGridDefinition()
                          .rows(@[AUTO, AUTO])
                          .cols(@[AUTO,AUTO,AUTO,AUTO]))
                    .requestViewSize(MICSize(S_AUTO,S_AUTO))];
    rootView.containerCell = container;
    rootView.frame = MICRect(500,500);

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,200)] name:@"0,0" params:WPLCellParams().requestViewSize(VSTRC, VAUTO)] row:0 column:0];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(300,100)] name:@"0,1" params:WPLCellParams().vertAlign(A_CENTER)] row:0 column:1];
    
    [rootView render];
    
    id<IWPLCell> cell;
    MICRect rc;
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 400);
    XCTAssertEqual(rc.height(), 200);
    
    cell = [container findByName:@"0,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 100);
    XCTAssertEqual(rc.height(), 200);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);

    cell = [container findByName:@"0,1"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 300);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 100);
    XCTAssertEqual(rc.top(), 50);

    //  200         300
    //  100,200     300,100     200
    //  200,100     100,400     400
    
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(200,100)] name:@"1,0" params:WPLCellParams().vertAlign(A_CENTER)] row:1 column:0];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,400)] name:@"1,1" params:WPLCellParams().align(A_CENTER)] row:1 column:1];
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 500);
    XCTAssertEqual(rc.height(), 600);
    
    cell = [container findByName:@"0,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(), 200);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);

    cell = [container findByName:@"0,1"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 300);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 200);
    XCTAssertEqual(rc.top(), 50);

    cell = [container findByName:@"1,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 200+150);

    cell = [container findByName:@"1,1"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 100);
    XCTAssertEqual(rc.height(), 400);
    XCTAssertEqual(rc.left(), 200+(300-100)/2);
    XCTAssertEqual(rc.top(), 200);
}

// spanを持つセルのサイズによって、未決定のグリッドセルのサイズが決定されるケースのテスト
- (void) testSubSpan {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams()
                     .dimension(WPLGridDefinition()
                          .rows(@[AUTO, AUTO])
                          .cols(@[AUTO,AUTO,AUTO]))
                    .requestViewSize(MICSize(S_AUTO,S_AUTO))];
    rootView.containerCell = container;
    rootView.frame = MICRect(500,500);

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize()] name:@"0,0-2" params:WPLCellParams().requestViewSize(400,100).vertAlign(A_CENTER)] row:0 column:0 rowSpan:1 colSpan:2];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize()] name:@"1,0" params:WPLCellParams().requestViewSize(VSTRC,100)] row:1 column:0];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize()] name:@"1,1" params:WPLCellParams().requestViewSize(100,VSTRC)] row:1 column:1];

    [rootView render];
    
    id<IWPLCell> cell;
    MICRect rc;
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 400);
    XCTAssertEqual(rc.height(), 200);

    cell = [container findByName:@"0,0-2"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 400);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);

    cell = [container findByName:@"1,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 300);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 100);
    
    cell = [container findByName:@"1,1"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 100);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 300);
    XCTAssertEqual(rc.top(), 100);
    
    container.cellSpacing = MICSize(10,0);
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 400);
    XCTAssertEqual(rc.height(), 200);

    cell = [container findByName:@"0,0-2"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 400);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);

    cell = [container findByName:@"1,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 290);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 100);

    cell = [container findByName:@"1,1"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 100);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 300);
    XCTAssertEqual(rc.top(), 100);
}

- (void) testStretch {
    // (S,A) (S2,A) (A,A)
    // (S,S) (S2,S) (A,S)

    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLGrid gridWithName:@"root"  params:WPLGridParams()
                     .dimension(WPLGridDefinition()
                          .cols(@[STRC,STRCx(2),AUTO])
                          .rows(@[AUTO, STRC]))
                    .requestViewSize(MICSize(VSTRC,VSTRC))];
    rootView.containerCell = container;
    rootView.frame = MICRect(600,400);

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize()] name:@"0,0" params:WPLCellParams().requestViewSize(50,100)] row:0 column:0];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize()] name:@"1,0" params:WPLCellParams().requestViewSize(VSTRC,VSTRC)] row:1 column:0];

    [rootView render];

    id<IWPLCell> cell;
    MICRect rc;

    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 600);
    XCTAssertEqual(rc.height(), 400);
    
    cell = [container findByName:@"0,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 50);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);
    
    cell = [container findByName:@"1,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(), 400-100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 100);
    
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize()] name:@"1,2" params:WPLCellParams().requestViewSize(120,VSTRC)] row:1 column:2];
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 600);
    XCTAssertEqual(rc.height(), 400);
    
    cell = [container findByName:@"0,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 50);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);
    
    cell = [container findByName:@"1,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), (600-120)/3);
    XCTAssertEqual(rc.height(), 400-100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 100);

    cell = [container findByName:@"1,2"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 120);
    XCTAssertEqual(rc.height(), 400-100);
    XCTAssertEqual(rc.left(), 600-120);
    XCTAssertEqual(rc.top(), 100);
    
    container.cellSpacing = MICSize(30,60);
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 600);
    XCTAssertEqual(rc.height(), 400);
    
    cell = [container findByName:@"0,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 50);
    XCTAssertEqual(rc.height(), 100);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 0);
    
    cell = [container findByName:@"1,0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), (600-120-30*2)/3);
    XCTAssertEqual(rc.height(), 400-100-60);
    XCTAssertEqual(rc.left(), 0);
    XCTAssertEqual(rc.top(), 100+60);

    cell = [container findByName:@"1,2"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.width(), 120);
    XCTAssertEqual(rc.height(), 400-100-60);
    XCTAssertEqual(rc.left(), 600-120);
    XCTAssertEqual(rc.top(), 100+60);


}

@end
