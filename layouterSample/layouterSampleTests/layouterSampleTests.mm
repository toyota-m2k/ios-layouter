//
//  layouterSampleTests.m
//  layouterSampleTests
//
//  Created by toyota-m2k on 2019/07/29.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WPLObservableMutableData.h"
#import "WPLDelegatedObservableData.h"
#import "MICVar.h"

@interface layouterSampleTests : XCTestCase

@end

@implementation layouterSampleTests {
    NSInteger _count;
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testObservableMutableData {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    _count = 0;
    let oba = [[WPLObservableMutableData alloc] init];
    XCTAssert(oba.intValue == 0);
    id key = [oba addValueChangedListener:self selector:@selector(observeValue:)];
    oba.intValue = 5;
    XCTAssert(_count == 5);
    oba.intValue = 6;
    XCTAssert(_count == 6);
    [oba removeValueChangedListener:key];
    oba.intValue = 10;
    XCTAssert(_count == 6);
    XCTAssert(oba.intValue == 10);
    [oba dispose];
}

- (void) observeValue:(id<IWPLObservableData>)data {
    _count = data.intValue;
}

- (void) testDelegatedObservableData {
    _count = 0;
    let oba = [[WPLObservableMutableData alloc] init];
    let obb = [[WPLObservableMutableData alloc] init];
    
    let doa = [WPLDelegatedObservableData newDataWithSourceBlock:^id (id _) {
        return [NSNumber numberWithInteger:oba.intValue+obb.intValue];
    }];
    let dob = [WPLDelegatedObservableData newDataWithSourceTarget:self selector:@selector(delegateSource:)];

    [oba addRelation:doa];
    [obb addRelation:doa];
    [doa addValueChangedListener:self selector:@selector(observeValue:)];
    [doa addRelation:dob];
    [dob addValueChangedListener:self selector:@selector(checkObservedValue:)];
    
    XCTAssert(doa.intValue==0);
    oba.intValue = 5;
    XCTAssert(doa.intValue==5);
    XCTAssert(dob.intValue==6);
    XCTAssert(_count==5);
    obb.intValue = 3;
    XCTAssert(doa.intValue==8);
    XCTAssert(_count==8);
    XCTAssert(dob.intValue==9);

    [oba dispose];
    [obb dispose];
    [doa dispose];
    [dob dispose];
}

- (id) delegateSource:(id)_ {
    return @(_count+1);
}

- (void) checkObservedValue:(id<IWPLObservableData>)data {
    XCTAssert(data.intValue == _count+1);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
