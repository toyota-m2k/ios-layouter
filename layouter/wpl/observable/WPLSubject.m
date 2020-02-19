//
//  WPLSubject.m
//
//  Created by toyota-m2k on 2019/12/11.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLSubject.h"

/**
 * valueプロパティのセッターで、値が変化していなくても、valueChangedを発行する点を除いて、
 * WPLObservableMutableData と同じ。
 * 他のObservableたちと同じ流儀で、event を扱えるようにしたかった。
 */
@implementation WPLSubject {
    NSMutableArray<WPLSubjectActionProc>* _subscribers;
    id _subscribersKey;
}

- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        _subscribers = nil;
        _subscribersKey = nil;
    }
    return self;
}

- (void)dispose {
    [super dispose];
    if(nil!=_subscribers) {
        [_subscribers removeAllObjects];
        _subscribers = nil;
    }
}

- (void)setValue:(id)value {
    if(![self.value isEqual:value]) {
        [super setValue:value];
    } else {
        [self valueChanged];
    }
}

- (void) trigger {
    [self valueChanged];
}

- (void) trigger:(id)value {
    [self setValue:value];
}

/**
 * リスナー(OnNext的なやつ）を登録
 * ... addValueChangedListener のエイリアス
 *
 * @param target 通知先
 * @param selector メソッドのセレクタ
 * @return 登録されたリスナーを識別するキー --> removeListener に渡して登録解除する
 */
- (id) addListener:(id)target selector:(SEL)selector {
    return [self addValueChangedListener:target selector:selector];
}

/**
 * リスナーを登録解除する
 * ... removeValueChangedListener のエイリアス
 *
 * @param key addListener の戻り値
 */
- (void) removeListener:(id)key {
    [self removeValueChangedListener:key];
}

- (void)subscribe:(WPLSubjectActionProc)action {
    if(_subscribersKey==nil) {
        _subscribersKey = [self addListener:self selector:@selector(onEmit:)];
        _subscribers = [NSMutableArray array];
    }
    [_subscribers addObject:action];
}

- (void) onEmit:(id)_ {
    if(_subscribers!=nil) {
        for(WPLSubjectActionProc fn in _subscribers) {
            fn(self.value);
        }
    }
}

@end
