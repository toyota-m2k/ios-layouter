//
//  bindingTests.m
//  layouterSampleTests
//
//  Created by Mitsuki Toyota on 2019/08/08.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WPLBindingDef.h"
#import "MICUiRectUtil.h"

@interface MockCell : NSObject<IWPLCell>
@end
@implementation MockCell
@synthesize actualViewSize;
@synthesize containerDelegate;
@synthesize extension;
@synthesize hAlignment;
@synthesize margin;
@synthesize name;
@synthesize needsLayout;
@synthesize enabled;
@synthesize requestViewSize;
@synthesize vAlignment;
@synthesize view;
@synthesize visibility;

- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        self.visibility = WPLVisibilityVISIBLE;
        self.enabled = true;
    }
    return self;
}

- (CGSize)calcMinSizeForRegulatingWidth:(CGFloat)regulatingWidth andRegulatingHeight:(CGFloat)regulatingHeight {
    return MICSize();
}

- (void)dispose {
    
}

- (void)layoutResolvedAt:(CGPoint)point inSize:(CGSize)size {
    
}

@end

@interface MockReadOnlySupportCell : MockCell<IWPLCellSuportReadonly>
@end
@implementation MockReadOnlySupportCell
@synthesize readonly;

- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        self.readonly = false;
    }
    return self;
}

@end

@interface MockValueSupportCell : MockCell<IWPLCellSupportValue>
@end
@implementation MockValueSupportCell


@synthesize value;


- (id)addInputChangedListener:(id)target selector:(SEL)selector {
    
}

- (void)removeInputListener:(id)key {
    <#code#>
}

@end



@interface bindingTests : XCTestCase

@end

@implementation bindingTests

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

@end
