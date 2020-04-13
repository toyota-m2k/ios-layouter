//
//  acomTests.m
//  layouterSampleTests
//
//  Created by @toyota-m2k on 2019/08/21.
//  Copyright (c) 2019 @toyota-m2k. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MICAcom.h"
#import "MICVar.h"

@interface acomTests : XCTestCase

@end



@implementation acomTests {
    bool _finished;
    NSInteger _value;
    NSInteger _check;
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    __block bool finished = false;
    __block NSInteger value = 0;
    BEGIN_AIFUL_LAUNCH
        MICAiful()
        .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            return MICAcomRESOLVE(@(1));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            let v = MPSV_INT(chainedResult);
            return MICAcomRESOLVE(@(v+1));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            let v = MPSV_INT(chainedResult);
            return MICAcomRESOLVE(@(v+2));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            value = MPSV_INT(chainedResult);
            finished = true;
            return MICAcom.resolve;
        })
    END_AIFUL
    
    while(!finished) {
        
    }
    XCTAssert(value==4);
}

- (void) launchFunc {
    BEGIN_AIFUL_LAUNCH
        MICAiful()
        .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            return MICAcomRESOLVE(@(1));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            let v = MPSV_INT(chainedResult);
            return MICAcomRESOLVE(@(v+1));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            let v = MPSV_INT(chainedResult);
            return MICAcomRESOLVE(@(v+2));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            self->_value = MPSV_INT(chainedResult);
            self->_finished = true;
            return MICAcomRESOLVE(chainedResult);
        })
    END_AIFUL
    _check = 1;
}

- (void) testLaunchFuncCall {
    _value = 0;
    _check = 0;
    _finished = false;
    [self launchFunc];

    XCTAssert(_check==1);
    while(!_finished) {
        
    }
    XCTAssert(_value==4);
}

- (void) awaitFunc {
    let awaiter = BEGIN_AIFUL_ASYNC
    MICAiful()
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        [NSThread sleepForTimeInterval:0.2];
        return MICAcomRESOLVE(@(1));
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        [NSThread sleepForTimeInterval:0.2];
        let v = MPSV_INT(chainedResult);
        return MICAcomRESOLVE(@(v+1));
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        [NSThread sleepForTimeInterval:0.2];
        let v = MPSV_INT(chainedResult);
        return MICAcomRESOLVE(@(v+2));
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        [NSThread sleepForTimeInterval:0.2];
        return MICAcomRESOLVE(chainedResult);
    })
    END_AIFUL
    
    // awaiter.await は、サブスレッドで実行する必要がある。
    [MICAsync.executor execute:^{
        let r = awaiter.await;
        if(r.error==nil) {
            self->_check = 1;
            self->_value = MPSV_INT(r.result);
        } else {
            self->_check = 0;
            self->_value = 0;
        }
        self->_finished = true;
    }];
}


- (void) testAwaitFuncCal {
    _value = 0;
    _check = 0;
    _finished = false;
    [self awaitFunc];
    
    while(!_finished) {
        
    }
    XCTAssert(_check==1);
    XCTAssert(_value==4);
}

- (MICPromise) promiseCall {
    return MICAiful()
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        [NSThread sleepForTimeInterval:0.2];
        return MICAcomRESOLVE(@(self->_value+1));
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        [NSThread sleepForTimeInterval:0.2];
        let v = MPSV_INT(chainedResult);
        return MICAcomRESOLVE(@(v+1));
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        [NSThread sleepForTimeInterval:0.2];
        let v = MPSV_INT(chainedResult);
        return MICAcomRESOLVE(@(v+2));
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        [NSThread sleepForTimeInterval:0.2];
        self->_value = MPSV_INT(chainedResult);
        self->_finished = true;
        return MICAcomRESOLVE(chainedResult);
    });
}


- (void) testAwaitCalls {
    _value = 0;
    _check = 0;
    _finished = false;

    __block bool finish = false;
    BEGIN_AIFUL_LAUNCH
    MICAiful()
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        acom_await( [self promiseCall] );
        XCTAssert(self->_finished);
        XCTAssert(self->_value==4);

        self->_finished = false;
        acom_await( [self promiseCall] );
        XCTAssert(self->_finished);
        XCTAssert(self->_value==8);
        return MICAcom.resolve;
    })
    .anyway(^(id  _Nullable param) {
        finish = true;
        self->_value ++;
    })
    END_AIFUL
    while(!finish) {
        
    }
    XCTAssert(_value==9);
}

- (void) testErrorAlways {
    _value = 0;
    _check = 0;
    _finished = false;
    __block bool finished = false;

    BEGIN_AIFUL_LAUNCH
    MICAiful().then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        return [self promiseCall];
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        return MICAcomREJECT(@"hoge");
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        XCTAssert(false);
        return [self promiseCall];
    }).failed(^(id  _Nullable error) {
        XCTAssert([@"hoge" isEqualToString:error]);
        XCTAssert(self->_value==4);
        self->_value++;
    }).anyway(^(id  _Nullable param) {
        XCTAssert([@"hoge" isEqualToString:param]);
        XCTAssert(self->_value==5);
        self->_value++;
        finished = true;
    })
    END_AIFUL
    
    while(!finished) {
        
    }
    
    XCTAssert(_value==6);
}

- (void) testErrorIgnore {
    _value = 0;
    _check = 0;
    _finished = false;
    __block bool finished = false;
    
    BEGIN_AIFUL_LAUNCH
    MICAiful().then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        return [self promiseCall];
    }).ignore(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        // ignore ブロック内でのreject は、resolveとして扱われる。
        return MICAcomREJECT(@"hoge");
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        XCTAssert([@"hoge" isEqualToString:chainedResult]);
        return [self promiseCall];
    }).failed(^(id  _Nullable error) {
        XCTAssert(false);
        XCTAssert([@"hoge" isEqualToString:error]);
        self->_value++;
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        // failed ノードは、（実行されないし）chainedResult に影響を与えない
        XCTAssert(MPSV_INT(chainedResult)==8);
        XCTAssert(self->_value==8);
        return [self promiseCall];
    }).anyway(^(id  _Nullable param) {
        XCTAssert(MPSV_INT(param)==12);
        XCTAssert(self->_value==12);
        self->_value++;
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        // anyway ノードは、chainedResult に影響を与えない
        XCTAssert(MPSV_INT(chainedResult)==12);
        XCTAssert(self->_value==13);
        return [self promiseCall];
    }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        finished = true;
        return MICAcomRESOLVE(nil);
    })
    END_AIFUL
    
    while(!finished) {
        
    }
    XCTAssert(_value == 17);

}

/**
 * サブスレッドで重い処理を実行し、完了したら、completedコールバックを呼び出す、よくある形のメソッド
 */
- (void) someFunc:(void(^)(NSInteger result)) completed {
    [MICAsync.executor execute:^{
        // 時間がかかる処理
        [NSThread sleepForTimeInterval:0.2];
        completed(17);
    }];
}

- (MICPromise) promisticSomeFunc {
    return MICAiful()
    .then_(^(id  chainedResult, MICAcomix promix) {
        [self someFunc:^(NSInteger result) {
            promix.resolve(@(result));
        }];
    });
}

- (void)testCallbackToPromise {
    __block bool finished = false;
    
    MICPromise promise = [self promisticSomeFunc];
    BEGIN_AIFUL_LAUNCH
        MICAiful(promise)
        .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            XCTAssert(MPSV_INT(chainedResult)==17);
            return MICAcom.resolve;
        })
        .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            finished = true;
            return MICAcom.resolve;
        })
    END_AIFUL
    
    while(!finished) {
        
    }
}

-(void) testSequential {
    __block bool chain1Finished = false;
    __block bool chain2Finished = false;
    __block bool chain3Finished = false;
    __block bool finished = false;
    __block int count = 0;

    let chain1 = MICAiful()
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        count++;
        return MICAcom.resolve;
    })
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        chain1Finished = true;
        return MICAcom.resolve;
    });
    
    let chain2 = MICAiful()
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        count++;
        return MICAcom.resolve;
    })
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        chain2Finished = true;
        return MICAcom.resolve;
    });

    let chain3 = MICAiful()
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        count++;
        return MICAcom.resolve;
    })
    .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
        chain3Finished = true;
        return MICAcom.resolve;
    });

    
    BEGIN_AIFUL_LAUNCH
        MICAiful()
        .seq(@[(MICAcom*)chain1, (MICAcom*)chain2, (MICAcom*)chain3])
        .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            XCTAssert(count==3);
            XCTAssert(chain1Finished);
            XCTAssert(chain2Finished);
            XCTAssert(chain3Finished);
            return MICAcom.resolve;
        })
        .anyway(^(id  _Nullable param) {
            finished = true;
    })
    END_AIFUL
    
    while(!finished) {
        
    }

}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


@end
