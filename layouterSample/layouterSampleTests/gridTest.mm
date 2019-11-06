//
//  gridTest.m
//  layouterSampleTests
//
//  Created by Mitsuki Toyota on 2019/11/05.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
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

@end
