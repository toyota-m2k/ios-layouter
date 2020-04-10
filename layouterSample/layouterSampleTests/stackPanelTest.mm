//
//  StackPanelTest.m
//  layouterSampleTests
//
//  Created by Mitsuki Toyota on 2019/11/06.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WPLCellHostingView.h"
#import "WPLContainersL.h"
#import "WPLBinder.h"
#import "MICVar.h"
#import "WPLCell.h"
#import "MICUiRectUtil.h"
#import "WPLStackPanel.h"

@interface StackPanelTest : XCTestCase

@end

@implementation StackPanelTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
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


- (void) testBasic {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLStackPanel stackPanelWithName:@"root"
                                               params:WPLStackPanelParams().orientation(WPLOrientationVERTICAL)];
    rootView.containerCell = container;

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,20)] name:@"0" params:WPLCellParams()]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(200,40)] name:@"1" params:WPLCellParams()]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,30)] name:@"2" params:WPLCellParams()]];
    
    rootView.frame = MICRect(200,100);
    [rootView render];
    
    MICRect frame;
    
    frame = container.view.frame;
    XCTAssertEqual(frame.width(), 200);
    XCTAssertEqual(frame.height(), 90);
    XCTAssertEqual(frame.top(), 0);
    XCTAssertEqual(frame.left(), 0);
    
    id<IWPLCell> cell;
    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 0);

    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 20);

    cell = [container findByName:@"2"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 60);
}

- (void) testSpacing {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLStackPanel stackPanelWithName:@"root"
                                               params:WPLStackPanelParams().orientation(WPLOrientationVERTICAL).cellSpacing(20)];
    rootView.containerCell = container;

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,20)] name:@"0" params:WPLCellParams()]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(200,40)] name:@"1" params:WPLCellParams()]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,30)] name:@"2" params:WPLCellParams()]];
    
    rootView.frame = MICRect(200,100);
    [rootView render];
    
    MICRect frame;
    
    frame = container.view.frame;
    XCTAssertEqual(frame.width(), 200);
    XCTAssertEqual(frame.height(), 130);
    XCTAssertEqual(frame.top(), 0);
    XCTAssertEqual(frame.left(), 0);
    
    id<IWPLCell> cell;
    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 0);

    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 40);

    cell = [container findByName:@"2"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 100);
}

- (void) testCellMargin {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLStackPanel stackPanelWithName:@"root"
                                               params:WPLStackPanelParams().orientation(WPLOrientationVERTICAL)];
    rootView.containerCell = container;

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,20)] name:@"0"
                                         params:WPLCellParams().margin(MICEdgeInsets(10,20))]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(200,40)] name:@"1"
                                         params:WPLCellParams().margin(MICEdgeInsets(10,20))]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,30)] name:@"2"
                                         params:WPLCellParams().margin(MICEdgeInsets(10,20))]];

    rootView.frame = MICRect(200,100);
    [rootView render];
    
    MICRect frame;
    
    frame = container.view.frame;
    XCTAssertEqual(frame.width(), 220);
    XCTAssertEqual(frame.height(),210);
    XCTAssertEqual(frame.top(), 0);
    XCTAssertEqual(frame.left(), 0);
    
    id<IWPLCell> cell;
    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 20);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 20);

    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 80);
    XCTAssertEqual(cell.view.frame.size.width, 200);
    XCTAssertEqual(cell.view.frame.size.height, 40);

    cell = [container findByName:@"2"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 160);
    XCTAssertEqual(cell.view.frame.size.width, 150);
    XCTAssertEqual(cell.view.frame.size.height, 30);
}

- (void) testContainerMargin {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLStackPanel stackPanelWithName:@"root"
                                               params:WPLStackPanelParams().orientation(WPLOrientationVERTICAL)
                     .margin(MICEdgeInsets(20,10))];
    rootView.containerCell = container;

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,20)] name:@"0"
                                         params:WPLCellParams().margin(MICEdgeInsets(10,20))]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(200,40)] name:@"1"
                                         params:WPLCellParams().margin(MICEdgeInsets(10,20))]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,30)] name:@"2"
                                         params:WPLCellParams().margin(MICEdgeInsets(10,20))]];

    rootView.frame = MICRect(200,100);
    [rootView render];
    
    MICRect frame;
    
    frame = container.view.frame;
    XCTAssertEqual(frame.width(), 220);
    XCTAssertEqual(frame.height(),210);
    XCTAssertEqual(frame.top(), 10);
    XCTAssertEqual(frame.left(), 20);
    
    id<IWPLCell> cell;
    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 20);

    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 80);

    cell = [container findByName:@"2"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 160);
}


- (void) testMinMax {
    let rootView = [[WPLCellHostingView alloc] init];
    let container = [WPLStackPanel stackPanelWithName:@"root"
                                               params:WPLStackPanelParams().orientation(WPLOrientationVERTICAL)
                     .margin(MICEdgeInsets(20,10)).minHeight(400).maxWidth(200)];
    rootView.containerCell = container;

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,20)] name:@"0"
                                         params:WPLCellParams().margin(MICEdgeInsets(10,20))]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(200,40)] name:@"1"
                                         params:WPLCellParams().margin(MICEdgeInsets(10,20)).minWidth(250).minHeight(140)]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,30)] name:@"2"
                                         params:WPLCellParams().horzAlign(A_CENTER)]];

    rootView.frame = MICRect(200,100);
    [rootView render];
    
    MICRect rc;
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 200);
    XCTAssertEqual(rc.height(),400);
    XCTAssertEqual(rc.top(), 10);
    XCTAssertEqual(rc.left(), 20);
    
    id<IWPLCell> cell;
    cell = [container findByName:@"0"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.left(), 10);
    XCTAssertEqual(rc.top(), 20);
    XCTAssertEqual(rc.width(), 100);
    XCTAssertEqual(rc.height(), 20);

    cell = [container findByName:@"1"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.left(), 10);
    XCTAssertEqual(rc.top(), 80);
    XCTAssertEqual(rc.width(), 250);
    XCTAssertEqual(rc.height(), 140);

    cell = [container findByName:@"2"];
    rc = cell.view.frame;
    XCTAssertEqual(rc.left(), (200-150)/2+20);
    XCTAssertEqual(rc.top(), 80+140+20);
    XCTAssertEqual(rc.width(), 150);
    XCTAssertEqual(rc.height(), 30);
}

@end
