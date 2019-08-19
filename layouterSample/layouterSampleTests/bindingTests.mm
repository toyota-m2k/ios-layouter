//
//  bindingTests.m
//  layouterSampleTests
//
//  Created by toyota-m2k on 2019/08/08.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WPLBinder.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

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

- (void)dispose {
    
}

- (void)layoutCompleted:(CGRect)finalCellRect {
    
}

- (CGSize)layoutPrepare:(CGSize)regulatingCellSize {
    return MICSize();
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
// @protected
- (void) onValueChanged;
@end
@implementation MockValueSupportCell {
    NSMutableArray<MICTargetSelector*>* _inputChangedListeners;
    id _value;
}

- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        _inputChangedListeners = nil;
        _value = nil;
        
    }
    return self;
}

- (void) dispose {
    if(_inputChangedListeners!=nil) {
        [_inputChangedListeners removeAllObjects];
        _inputChangedListeners = nil;
    }
}

/**
 * 値属性
 * please implement in sub-classes
 */
- (id) value {
    return _value;
}

- (void) setValue:(id)v {
    if(_value == v) {
        return;
    }
    if(_value!=nil && [_value isEqual:v]) {
        return;
    }
    _value = v;
    [self onValueChanged];
}

/**
 * Viewへの入力が更新されたときのリスナー登録
 * @param target        listener object
 * @param selector      (cell)->Unit
 * @return key  removeInputListenerに渡して解除する
 */
- (id) addInputChangedListener:(id)target selector:(SEL)selector {
    if(_inputChangedListeners==nil) {
        _inputChangedListeners = [NSMutableArray array];
    }
    
    let key = [[MICTargetSelector alloc] initWithTarget:target selector:selector];
    [_inputChangedListeners addObject:key];
    return key;
}

/**
 * リスナーの登録を解除
 */
- (void) removeInputListener:(id)key {
    if(_inputChangedListeners!=nil) {
        [_inputChangedListeners removeObject:key];
        if(_inputChangedListeners.count==0) {
            _inputChangedListeners = nil;
        }
    }
}

- (void) onValueChanged {
    if(nil!=_inputChangedListeners) {
        for(MICTargetSelector* ts in _inputChangedListeners) {
            id me = self;
            [ts performWithParam:&me];
        }
    }
}

@end

@interface MockFullSuportCell : MockValueSupportCell<IWPLCellSuportReadonly>
@end
@implementation MockFullSuportCell

@synthesize readonly;
- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        self.readonly = false;
    }
    return self;
}

@end


@interface bindingTests : XCTestCase

@end

@implementation bindingTests{
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

static inline NSString* bc_string(bool b, int c) {
    if(b) {
        return [NSString stringWithFormat:@"+%ld", (long)c];
    } else {
        return [NSString stringWithFormat:@"-%ld", (long)c];
    }
}

static inline NSString* braced_string(NSString* s) {
    return [NSString stringWithFormat:@"(%@)", s];
}

static inline NSString* label_braced_string(NSString* a, NSString* s) {
    return [NSString stringWithFormat:@"%@ (%@)", a, s];
}


- (void)testCellBinding {
    let cellA = [MockFullSuportCell new];
    let cellB = [MockFullSuportCell new];
    let cellC = [MockFullSuportCell new];
    let cellD = [MockFullSuportCell new];
    let cellBC = [MockFullSuportCell new];
    let cellNest = [MockFullSuportCell new];
    let cellNestA = [MockFullSuportCell new];


    let binder = [WPLBinder new];
    WPLBinderBuilder bb(binder);
    bb.property(@"AString", @"a")
    .property(@"BBool", true)
    .property(@"CInt", 1)
    .property(@"DFloat", 0.5)
    .dependentProperty(@"(BC)String", ^id(id<IWPLDelegatedDataSource> s) {
        let b = [binder propertyForKey:@"BBool"].boolValue;
        let c = [binder propertyForKey:@"CInt"].intValue;
        return bc_string(b, (int)c);
     }, @"BBool", @"CInt", nil)
    .dependentProperty(@"Nest", ^id(id<IWPLDelegatedDataSource> s) {
        let bc = [binder propertyForKey:@"(BC)String"].stringValue;
        return braced_string(bc);
    }, @"(BC)String", nil)
    .dependentProperty(@"NestA", ^id(id<IWPLDelegatedDataSource> s) {
        let a = [binder propertyForKey:@"AString"].stringValue;
        let bc = [binder propertyForKey:@"(BC)String"].stringValue;
        return label_braced_string(a, bc);
    }, @"(BC)String", @"AString", nil)
    .bindValue(@"AString",cellA, WPLBindingModeTWO_WAY)
    .bindValue(@"BBool", cellB, WPLBindingModeTWO_WAY)
    .bindValue(@"CInt", cellC, WPLBindingModeTWO_WAY)
    .bindValue(@"DFloat", cellD, WPLBindingModeTWO_WAY)
    .bindValue(@"(BC)String", cellBC, WPLBindingModeTWO_WAY)
    .bindValue(@"Nest", cellNest, WPLBindingModeTWO_WAY)
    .bindValue(@"NestA", cellNestA, WPLBindingModeTWO_WAY)
    .bindState(@"BBool", cellA, WPLBoolStateActionTypeVISIBLE_COLLAPSED, false)
    .bindState(@"BBool", cellB, WPLBoolStateActionTypeENABLED, false)
    .bindState(@"BBool", cellC, WPLBoolStateActionTypeREADONLY, true)
    .bindCustom(@"CInt", cellBC, ^(id<IWPLBinding> sender, bool fromView) {
        sender.cell.enabled = sender.source.intValue > 0;
    });
    
    let srcA = [binder mutablePropertyForKey:@"AString"];
    let srcB = [binder mutablePropertyForKey:@"BBool"];
    let srcC = [binder mutablePropertyForKey:@"CInt"];
    let srcD = [binder mutablePropertyForKey:@"DFloat"];
    let srcBC = [binder propertyForKey:@"(BC)String"];
    let srcNest = [binder propertyForKey:@"Nest"];
    let srcNestA = [binder propertyForKey:@"NestA"];
                
    XCTAssert(srcA!=nil);
    XCTAssert(srcB!=nil);
    XCTAssert(srcC!=nil);
    XCTAssert(srcD!=nil);

    XCTAssert([srcA.stringValue isEqualToString:@"a"]);
    XCTAssert(srcB.boolValue == true);
    XCTAssert(srcC.intValue == 1);
    XCTAssert(srcD.floatValue == 0.5);
    
    XCTAssert([cellA.value isEqualToString:@"a"]);
    XCTAssert([(NSNumber*)cellB.value boolValue] == true);
    XCTAssert([(NSNumber*)cellC.value intValue] == 1);
    XCTAssert([(NSNumber*)cellD.value doubleValue]== 0.5);
    
    XCTAssert([cellBC.value isEqualToString:bc_string(srcB.boolValue, (int)srcC.intValue)]);
    XCTAssert([cellNest.value isEqualToString:braced_string(cellBC.value)]);
    XCTAssert([cellNestA.value isEqualToString:label_braced_string(cellA.value, cellBC.value)]);

    XCTAssert([srcBC.stringValue isEqualToString:cellBC.value]);
    XCTAssert([srcNest.stringValue isEqualToString:cellNest.value]);
    XCTAssert([srcNestA.stringValue isEqualToString:cellNestA.value]);

    XCTAssert(cellA.visibility==WPLVisibilityVISIBLE);
    XCTAssert(cellB.enabled==true);
    XCTAssert(cellC.readonly==false);
    XCTAssert(cellBC.enabled==true);


    srcA.value = @"b";
    XCTAssert([cellA.value isEqualToString:@"b"]);
    XCTAssert([cellNestA.value isEqualToString:label_braced_string(cellA.value, cellBC.value)]);

    srcB.boolValue = false;
    XCTAssert([(NSNumber*)cellB.value boolValue] == false);
    XCTAssert([cellBC.value isEqualToString:bc_string(srcB.boolValue, (int)srcC.intValue)]);
    XCTAssert([cellNest.value isEqualToString:braced_string(cellBC.value)]);
    XCTAssert([cellNestA.value isEqualToString:label_braced_string(cellA.value, cellBC.value)]);

    XCTAssert(cellA.visibility==WPLVisibilityCOLLAPSED);
    XCTAssert(cellB.enabled==false);
    XCTAssert(cellC.readonly==true);
    XCTAssert(cellBC.enabled==true);

    srcC.intValue = -1;
    XCTAssert([(NSNumber*)cellC.value intValue] == -1);
    XCTAssert([cellBC.value isEqualToString:bc_string(srcB.boolValue, (int)srcC.intValue)]);
    XCTAssert([cellNest.value isEqualToString:braced_string(cellBC.value)]);
    XCTAssert([cellNestA.value isEqualToString:label_braced_string(cellA.value, cellBC.value)]);
    XCTAssert(cellBC.enabled==false);

    cellC.value = @(5);
    XCTAssert(srcC.intValue == 5);
    XCTAssert([cellBC.value isEqualToString:bc_string(srcB.boolValue, (int)srcC.intValue)]);
    XCTAssert([cellNest.value isEqualToString:braced_string(cellBC.value)]);
    XCTAssert([cellNestA.value isEqualToString:label_braced_string(cellA.value, cellBC.value)]);
    XCTAssert(cellBC.enabled==true);

    cellA.value = @"A";
    XCTAssert([srcA.stringValue isEqualToString:@"A"]);
    XCTAssert([cellBC.value isEqualToString:bc_string(srcB.boolValue, (int)srcC.intValue)]);
    XCTAssert([cellNest.value isEqualToString:braced_string(cellBC.value)]);
    XCTAssert([cellNestA.value isEqualToString:label_braced_string(cellA.value, cellBC.value)]);
    XCTAssert(cellBC.enabled==true);

    [binder dispose];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
