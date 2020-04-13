//
//  frameTest.m
//  layouterSampleTests
//
//  Created by @toyota-m2k on 2020/04/09.
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

@interface FrameTest : XCTestCase

@end

@implementation FrameTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (UIView*) viewOfSize:(CGSize) size {
    return [[UIView alloc] initWithFrame:MICRect(size)];
}


- (void)testBasic {
    let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_CENTER)];
    let container = rootView.container;
    
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,20)] name:@"0" params:WPLCellParams().align(A_LEFT,A_TOP)]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,40)] name:@"1" params:WPLCellParams().align(A_CENTER,A_CENTER)]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,30)] name:@"2" params:WPLCellParams().align(A_RIGHT,A_BOTTOM)]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize()] name:@"3" params:WPLCellParams().requestViewSize(VSTRC,VSTRC)]];

    rootView.frame = MICRect(400,300);
    [rootView render];
    
    MICRect rc;
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 150);
    XCTAssertEqual(rc.height(), 40);

    id<IWPLCell> cell;
    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 0);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 20);

    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x, 25);
    XCTAssertEqual(cell.view.frame.origin.y, 0);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 40);

    cell = [container findByName:@"2"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 10);
    XCTAssertEqual(cell.view.frame.size.width, 150);
    XCTAssertEqual(cell.view.frame.size.height, 30);

    cell = [container findByName:@"3"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 0);
    XCTAssertEqual(cell.view.frame.size.width, 150);
    XCTAssertEqual(cell.view.frame.size.height, 40);

    container.requestViewSize = MICSize(VSTRC,VSTRC);
    [rootView render];  // 強制的にrenderを呼んで再配置させる。プロパティ変更による自動的な再レンダリングは遅延されるので次のテストに間に合わない。
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(),  400);
    XCTAssertEqual(rc.height(), 300);

    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 0);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 20);

    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x, (400-100)/2);
    XCTAssertEqual(cell.view.frame.origin.y, (300-40)/2);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 40);

    cell = [container findByName:@"2"];
    XCTAssertEqual(cell.view.frame.origin.x, 400-150);
    XCTAssertEqual(cell.view.frame.origin.y, 300-30);
    XCTAssertEqual(cell.view.frame.size.width, 150);
    XCTAssertEqual(cell.view.frame.size.height, 30);

    cell = [container findByName:@"3"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 0);
    XCTAssertEqual(cell.view.frame.size.width, 400);
    XCTAssertEqual(cell.view.frame.size.height, 300);
}

- (void) testMargin {
    let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_LEFT,A_TOP).margin(10,20,30,40)];
    let container = rootView.container;
    
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,20)] name:@"0"
                                         params:WPLCellParams().align(A_LEFT,A_TOP).margin(MICEdgeInsets(10,20))]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,40)] name:@"1"
                                         params:WPLCellParams().align(A_CENTER,A_CENTER).margin(MICEdgeInsets(30,0))]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(150,30)] name:@"2"
                                         params:WPLCellParams().align(A_RIGHT,A_BOTTOM).margin(0,10,0,5)]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize()] name:@"3"
                                         params:WPLCellParams().requestViewSize(VSTRC,VSTRC).margin(1,2,3,4)]];
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(10,4)] name:@"4"
                                         params:WPLCellParams().align(A_CENTER,A_CENTER).margin(1,2,3,4)]];

    MICRect rc;
    id<IWPLCell> cell;

    rootView.frame = MICRect(400,300);
    [rootView render];

    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 160);
    XCTAssertEqual(rc.height(), 60);
    XCTAssertEqual(rc.left(), 10);
    XCTAssertEqual(rc.top(), 20);


    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 20);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 20);

    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x, 30);
    XCTAssertEqual(cell.view.frame.origin.y, 10);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 40);

    // Bottom/Right
    cell = [container findByName:@"2"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 30-5);
    XCTAssertEqual(cell.view.frame.size.width, 150);
    XCTAssertEqual(cell.view.frame.size.height, 30);

    cell = [container findByName:@"3"];
    XCTAssertEqual(cell.view.frame.origin.x, 1);
    XCTAssertEqual(cell.view.frame.origin.y, 2);
    XCTAssertEqual(cell.view.frame.size.width, 160-1-3);
    XCTAssertEqual(cell.view.frame.size.height, 60-2-4);

    cell = [container findByName:@"4"];
    XCTAssertEqual(cell.view.frame.origin.x, (160-10-1-3)/2+1);
    XCTAssertEqual(cell.view.frame.origin.y, (60-4-2-4)/2+2);
    XCTAssertEqual(cell.view.frame.size.width, 10);
    XCTAssertEqual(cell.view.frame.size.height, 4);

    container.requestViewSize = MICSize(VSTRC,VSTRC);
    [rootView render];  // 強制的にrenderを呼んで再配置させる。プロパティ変更による自動的な再レンダリングは遅延されるので次のテストに間に合わない。

    rc = container.view.frame;
    XCTAssertEqual(rc.width(),  400-10-30); // 360
    XCTAssertEqual(rc.height(), 300-20-40); // 240

    // Top/Left
    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 10);
    XCTAssertEqual(cell.view.frame.origin.y, 20);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 20);

    // Center
    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x,(360-100)/2);
    XCTAssertEqual(cell.view.frame.origin.y, (240-40)/2);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 40);

    // Bottom/Right
    cell = [container findByName:@"2"];
    XCTAssertEqual(cell.view.frame.origin.x, 360-150);
    XCTAssertEqual(cell.view.frame.origin.y, 240-30-5);
    XCTAssertEqual(cell.view.frame.size.width, 150);
    XCTAssertEqual(cell.view.frame.size.height, 30);

    // Stretch
    cell = [container findByName:@"3"];
    XCTAssertEqual(cell.view.frame.origin.x, 1);
    XCTAssertEqual(cell.view.frame.origin.y, 2);
    XCTAssertEqual(cell.view.frame.size.width, 360-1-3);
    XCTAssertEqual(cell.view.frame.size.height, 240-2-4);

    // centering with asymetric margin
    cell = [container findByName:@"4"];
    XCTAssertEqual(cell.view.frame.origin.x, (360-10-1-3)/2+1);
    XCTAssertEqual(cell.view.frame.origin.y, (240-4-2-4)/2+2);
    XCTAssertEqual(cell.view.frame.size.width, 10);
    XCTAssertEqual(cell.view.frame.size.height, 4);
}

- (void) testStretchStretchMinMax {
    MICRect rc;
    id<IWPLCell> cell;

    // Stretch > Stretch
    let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_RIGHT,A_BOTTOM).requestViewSize(VSTRC,VSTRC).maxWidth(400).maxHeight(300)];
    let container = rootView.container;
    rootView.frame = MICRect(500,600);
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(100,250)] name:@"0"
                                         params:WPLCellParams().align(A_LEFT,A_TOP)
                                                    .requestViewSize(VSTRC,VSTRC)
                                                    .limitWidth(WPLCMinMax(200,300))
                                                    .limitHeight(WPLCMinMax().setMax(200))]];
    [rootView render];
    
    rc = container.view.frame;
    XCTAssertEqual(rc.width(), 400);
    XCTAssertEqual(rc.height(), 300);
    XCTAssertEqual(rc.left(), 500-400);
    XCTAssertEqual(rc.top(), 600-300);

    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, 0);
    XCTAssertEqual(cell.view.frame.origin.y, 0);
    XCTAssertEqual(cell.view.frame.size.width, 300);
    XCTAssertEqual(cell.view.frame.size.height, 200);
}

- (void) testAutoAutoMinMax {
    MICRect rc;
    id<IWPLCell> cell;

    // Auto > Auto
    let rootView = [WPLFrameView frameViewWithName:@"root" params:WPLCellParams().align(A_RIGHT,A_BOTTOM).requestViewSize(VAUTO,VAUTO).limitWidth(200, 400).limitHeight(100, 300)];
    let container = rootView.container;
    rootView.frame = MICRect(500,600);

    [rootView render];

    rc = container.view.frame;
    XCTAssertEqual(rc.width(),  200);
    XCTAssertEqual(rc.height(), 100);

    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(50,400)] name:@"0"
                                         params:WPLCellParams().align(A_CENTER,A_CENTER)
                                                    .requestViewSize(VAUTO,VAUTO)
                                                    .limitWidth(100,300)
                                                    .maxHeight(200)]];      // 100,200 になるはず
    [rootView render];

    rc = container.view.frame;
    XCTAssertEqual(rc.width(),  200);
    XCTAssertEqual(rc.height(), 200);

    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, (200-100)/2);
    XCTAssertEqual(cell.view.frame.origin.y, 0);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 200);

    
    [container addCell:[WPLCell newCellWithView:[self viewOfSize:MICSize(0,0)] name:@"1"
                                         params:WPLCellParams().align(A_CENTER,A_CENTER)
                                                    .requestViewSize(VAUTO,VAUTO)
                                                    .minWidth(500)
                                                    .minHeight(500)]];      // 500,500 になるはず
    [rootView render];

    rc = container.view.frame;
    XCTAssertEqual(rc.width(),  400);
    XCTAssertEqual(rc.height(), 300);

    cell = [container findByName:@"0"];
    XCTAssertEqual(cell.view.frame.origin.x, (400-100)/2);
    XCTAssertEqual(cell.view.frame.origin.y, (300-200)/2);
    XCTAssertEqual(cell.view.frame.size.width, 100);
    XCTAssertEqual(cell.view.frame.size.height, 200);

    cell = [container findByName:@"1"];
    XCTAssertEqual(cell.view.frame.origin.x, (400-500)/2);
    XCTAssertEqual(cell.view.frame.origin.y, (300-500)/2);
    XCTAssertEqual(cell.view.frame.size.width, 500);
    XCTAssertEqual(cell.view.frame.size.height, 500);

}

@end

