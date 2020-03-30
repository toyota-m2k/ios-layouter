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

@interface WPLRxMultiCombinObservableData : WPLObservableData
- (instancetype)initWithSources:(NSArray<id<IWPLObservableData>>*)sources func:(WPLRxNProc) fn;
@end

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
    self.value = ((WPLRx1Proc)mFunc)(sx);
}

- (void) handleWhere:(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    if(((WPLRx1BoolProc)mFunc)(sx)) {
        self.value = sx.value;
    }
}

- (void) handleCombineLatest:(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    self.value = ((WPLRx2Proc)mFunc)(mSx,mSy);
}

- (void) handleMerge :(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    if(sx!=nil) {
        self.value = sx.value;
    } else if(sy.value) {
        self.value = sy.value;
    }
}

- (void) handleScan :(id<IWPLObservableData>) sx sy:(id<IWPLObservableData>) sy {
    self.value = ((WPLRx2Proc)mFunc)(self, sx);
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
 * ３つ以上のソースのCombine用
 */
+ (id<IWPLObservableData>) combineLatest:(NSArray<id<IWPLObservableData>>*) sources func:(WPLRxNProc)fn {
    return [[WPLRxMultiCombinObservableData alloc] initWithSources:sources func:fn];
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

@interface WPLRxDataSourceRec : NSObject
@property (nonatomic,readonly) id<IWPLObservableData> data;
@property (nonatomic,readonly) id key;
@end

@implementation WPLRxDataSourceRec
- (instancetype) initWithData:(id<IWPLObservableData>)data forKey:(id) key {
    self = [super init];
    if(nil!=self) {
        _data = data;
        _key = key;
    }
    return self;
}
@end

@implementation WPLRxMultiCombinObservableData {
    NSMutableArray<WPLRxDataSourceRec*>* mSources;
    WPLRxNProc mFunc;
    id mValue;
}

- (instancetype)initWithSources:(NSArray<id<IWPLObservableData>> *)sources func:(WPLRxNProc)fn {
    self = [super init];
    if(nil!=self) {
        mFunc = fn;
        mSources = [NSMutableArray arrayWithCapacity:sources.count];
        for(id s in sources) {
            [self addSource:s];
        }
        [self onSourceValueChanged:nil];
    }
    return self;
}

- (void) addSource:(id<IWPLObservableData>) src {
    id key = [src addValueChangedListener:self selector:@selector(onSourceValueChanged:)];
    let rec = [[WPLRxDataSourceRec alloc] initWithData:src forKey:key];
    [mSources addObject:rec];
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

- (void) onSourceValueChanged:(id)src {
    if(mFunc!=nil) {
        let ary = [NSMutableArray arrayWithCapacity:mSources.count];
        for(WPLRxDataSourceRec* rec in mSources) {
            [ary addObject:rec.data];
        }
        self.value = mFunc(ary);
    }
}

- (void)dispose {
    [super dispose];
    for(WPLRxDataSourceRec* r in mSources) {
        [r.data removeValueChangedListener:r.key];
    }
    [mSources removeAllObjects];
    mFunc = nil;
}

@end

