//
//  WPLRxObservableData.mm
//
//  Created by @toyota-m2k on 2020/02/06.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLRxObservableData.h"
#import "MICVar.h"


enum RxType {
    RxSelect,
    RxCombineLatest,
    RxWhere,
    RxScan,
    RxMerge,
};

@implementation WPLRxObservableData {
    RxType mType;
    id<IWPLObservableData> mSx;
    id<IWPLObservableData> mSy;
    id mKeyX;
    id mKeyY;
    id mFunc;
    id mValue;
    MICTargetSelector* mHandler;
}


- (instancetype)initForType:(RxType)type sx:(id<IWPLObservableData>)sx func:(id)fn {
    return [self initForType:type sx:sx sy:nil func:fn];
}

- (instancetype)initForType:(RxType)type sx:(id<IWPLObservableData>)sx sy:(id<IWPLObservableData>)sy func:(id)fn {
    self = [super init];
    if(nil!=self) {
        mType = type;
        mSx = sx;
        mSy = sy;
        mFunc = fn;
        mValue = nil;
        mHandler = nil;
        
        mKeyX = [sx addValueChangedListener:self selector:@selector(onValueXChanged:)];
        mKeyY = nil;
        if(sy!=nil) {
            mKeyY = [sy addValueChangedListener:self selector:@selector(onValueYChanged:)];
        }
        
        switch(type) {
            case RxSelect:
                mHandler = [MICTargetSelector target:self selector:@selector(handleSelect:sy:)];
                break;
            case RxWhere:
                mHandler = [MICTargetSelector target:self selector:@selector(handleWhere:sy:)];
                break;
            case RxCombineLatest:
                mHandler = [MICTargetSelector target:self selector:@selector(handleCombineLatest:sy:)];
                break;
            case RxScan:
                mHandler = [MICTargetSelector target:self selector:@selector(handleScan:sy:)];
                break;
            case RxMerge:
                mHandler = [MICTargetSelector target:self selector:@selector(handleMerge:sy:)];
                break;
            default:
                NSAssert(false, @"unknown rx operator.");
        }
    }
    id p1 = sx, p2 = sy;
    [mHandler performWithParam:&p1 param2:&p2]; // 最初の１回目の呼び出し
    return self;
}

- (id) value {
    return mValue;
}

- (void) setValue:(id) v {
    if(![mValue isEqual:v]) {
        mValue  = v;
        [self valueChanged];
    }
}

- (void)dispose {
    [super dispose];
    if(mKeyX!=nil) {
        [mSx removeValueChangedListener:mKeyX];
        mKeyX = nil;
    }
    if(mKeyY!=nil) {
        [mSy removeValueChangedListener:mKeyY];
        mKeyY = nil;
    }
    mSx = nil;
    mSy = nil;
    mFunc = nil;
    mHandler = nil;
}

- (void) onValueXChanged:(id<IWPLObservableData>) sx {
    id p1 = sx;
    id p2 = nil;
    [mHandler performWithParam:&p1 param2:&p2];
}

- (void) onValueYChanged:(id<IWPLObservableData>) sy {
    id p1 = nil;
    id p2 = sy;
    [mHandler performWithParam:&p1 param2:&p2];
}

#pragma mark - Handlers for rx-operators

- (void) handleSelect:(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    self.value = ((WPLRx1Proc)mFunc)(sx.value);
}

- (void) handleWhere:(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    if(((WPLRx1BoolProc)mFunc)(sx.value)) {
        self.value = sx.value;
    }
}

- (void) handleCombineLatest:(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    self.value = ((WPLRx2Proc)mFunc)(mSx.value,mSy.value);
}

- (void) handleMerge :(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    if(sx!=nil) {
        self.value = sx.value;
    } else if(sy.value) {
        self.value = sy.value;
    }
}

- (void) handleScan :(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    self.value = ((WPLRx2Proc)mFunc)(self.value, sx.value);
}

#pragma mark - Factories

/**
 * Rx map / select(.net) 相当の値変換を行うObservableプロパティを生成
 * @param sx  変換元データ
 * @param fn  変換関数  id convert(id s)
 */
+ (id<IWPLObservableData>) select:(id<IWPLObservableData>)sx func:(WPLRx1Proc)fn {
    return [[WPLRxObservableData alloc] initForType:RxSelect sx:sx func:fn];
}

+ (id<IWPLObservableData>) map:(id<IWPLObservableData>)sx func:(WPLRx1Proc)fn {
    return [self select:sx func:fn];
}

/**
 * Rx combineLatest に相当。２系列のデータソースから、新しいObservableを生成。
 * @param sx    ソース１
 * @param sy    ソース２
 * @param fn    変換関数　id convert(id s1, id s2)
 */
+ (id<IWPLObservableData>) combineLatest:(id<IWPLObservableData>)sx with:(id<IWPLObservableData>)sy func:(WPLRx2Proc)fn {
    return [[WPLRxObservableData alloc] initForType:RxCombineLatest sx:sx sy:sy func:fn];
}

/**
 * Rx where に相当。２系列のデータソースを単純にマージ
 * @param sx    ソース
 * @param fn    フィルター関数(trueを返した値だけが有効になる)　bool filter(id s)
 */
+ (id<IWPLObservableData>) where:(id<IWPLObservableData>)sx func:(WPLRx1BoolProc)fn {
    return [[WPLRxObservableData alloc] initForType:RxWhere sx:sx func:fn];
}

/**
 * Rx merge に相当。２系列のデータソースを単純にマージ
 * @param sx  ソース１
 * @param sy  ソース２
 */
+ (id<IWPLObservableData>) merge:(id<IWPLObservableData>)sx with:(id<IWPLObservableData>) sy {
    return [[WPLRxObservableData alloc] initForType:RxMerge sx:sx sy:sy func:nil];
}

/**
 * Rx scan 相当の値変換を行うObservableプロパティを生成
 * @param sx   変換元データ
 * @param fn    変換関数　id convert(id previous, id current)
 */
+ (id<IWPLObservableData>) scan:(id<IWPLObservableData>)sx func:(WPLRx2Proc)fn {
    return [[WPLRxObservableData alloc] initForType:RxMerge sx:sx sy:nil func:fn];
}

@end
