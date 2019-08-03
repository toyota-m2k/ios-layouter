//
//  WPLDelegatedObservableData.mm
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLDelegatedObservableData.h"
#import "MICVar.h"

/**
 * 外部の値にデリゲートする監視可能データオブジェクト
 * valueChanged は、デリゲート供給オブジェクトからキックする。
 * WPLObservableMutableData の relations に登録することで、複数のデータソースにバインドして使うことができる。
 */
@implementation WPLDelegatedObservableData {
    WPLSourceDelegateProc _sourceDelegateBlock;
    MICTargetSelector* _sourceDelegateSelector;
}

+ (instancetype) newData {
    return [[WPLDelegatedObservableData alloc] init];
}

+ (instancetype) newDataWithSourceBlock:(WPLSourceDelegateProc)proc {
    WPLDelegatedObservableData* r = [self newData];
    r.sourceDelegateBlock = proc;
    return r;
}

+ (instancetype) newDataWithSourceTarget:(id)target selector:(SEL)selector {
    WPLDelegatedObservableData* r = [self newData];
    r.sourceDelegateSelector = [MICTargetSelector targetSelector:target selector:selector];
    return r;
}

+ (instancetype) newDataWithSourceTargetSelector:(MICTargetSelector*) ts {
    WPLDelegatedObservableData* r = [self newData];
    r.sourceDelegateSelector = ts;
    return r;
}

-(instancetype) init {
    self = [super init];
    if(nil!=self) {
        _sourceDelegateBlock = nil;
        _sourceDelegateSelector = nil;
    }
    return self;
}

// Block または、TargetSelector を指定。
// 両方設定している場合は blockの方を優先。
// @property (nonatomic) WPLSourceDelegateProc sourceDelegateBlock;
// @property (nonatomic) MICTargetSelector* sourceDelegateSelector;

- (void) setSourceDelegateBlock:(WPLSourceDelegateProc) proc {
    _sourceDelegateBlock = proc;
}

- (void) setSourceDelegateSelector:(MICTargetSelector*) ts {
    _sourceDelegateSelector = ts;
}

- (WPLSourceDelegateProc) sourceDelegateBlock {
    return _sourceDelegateBlock;
}

- (MICTargetSelector*) sourceDelegateSelector {
    return _sourceDelegateSelector;
}

- (id)value {
    if(_sourceDelegateBlock!=nil) {
        return _sourceDelegateBlock(self);
    } else if(_sourceDelegateSelector!=nil){
        id me = self;
        id result = nil;
        [_sourceDelegateSelector performWithParam:&me getResult:&result];
        return result;
    } else {
        return nil;
    }
}
@end