//
//  MICArray.m
//
//  Created by @toyota-m2k on 2014/11/04.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICArray.h"

@implementation MICRectArray {
    NSMutableArray* _array;
}

/**
 * 空のインスタンスを生成
 */
- (MICRectArray*) init {
    self = [super init];
    if(nil!=self){
        _array = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 * キャパシティを指定して空のインスタンスを生成
 */
- (MICRectArray*) initWithCapacity:(int)capacity {
    self = [super init];
    if(nil!=self){
        _array = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)capacity];
    }
    return self;
}

/**
 * 配列の複製
 */
- (MICRectArray*) initWithArray:(MICRectArray*)src {
    self = [super init];
    if(nil!=self){
        _array = [[NSMutableArray alloc] initWithArray:_array];
    }
    return self;
}

/**
 * 配列に要素を追加
 */
- (void) add:(CGRect)rc {
    [_array addObject:[NSValue valueWithCGRect:rc]];
}

/**
 * 配列に要素を挿入
 */
- (void) insert:(CGRect)rc at:(int)idx {
    [_array insertObject:[NSValue valueWithCGRect:rc] atIndex:idx];
}

/**
 * 配列から要素を削除
 */
- (void) removeAt:(int) idx {
    [_array removeObjectAtIndex:idx];
}

/**
 * 配列から要素を取得
 */
- (CGRect) getAt:(int)idx {
    return [_array[idx] CGRectValue];
}


@end

