//
//  MICMatrix.m
//  DTable
//
//  Created by 豊田 光樹 on 2014/10/31.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICMatrix.h"

//--------------------------------------------------------------------------------------
#pragma mark - マトリックス（ｎxｍ２次元配列）クラス

/**
 * ２次元配列クラス
 */
@implementation MICMatrix {
    NSMutableArray* _array;
    int _cx;
    int _cy;
}

- (id) init {
    self = [super init];
    if(nil!=self){
        _cx = 0;
        _cy = 0;
        _array =nil;
    }
    return self;
}

/**
 * マトリックスの内部配列を取り出す。
 */
- (NSMutableArray*) asArray {
    return _array;
}

/**
 * 初期化
 *
 * @param x     行数
 * @param y     列数
 */
- (id) initWithDimmensionX:(int)cx andY:(int)cy {
    self = [super init];
    if(nil!=self){
        _cx = cx;
        _cy = cy;
        _array = [[NSMutableArray alloc] initWithCapacity:cx*cy];
        for(int i=0, ci=cx*cy ; i<ci ; i++) {
            [_array addObject:[NSNull null]];
        }
    }
    return self;
}

/**
 * 初期化（コピーコンストラクタ）
 */
- (id) initWithMatrix:(MICMatrix*)src {
    self = [super init];
    if(nil!=self){
        _cx = src.cx;
        _cy = src.cy;
        _array = [[NSMutableArray alloc] initWithArray:[src asArray]];
    }
    return self;
}


/**
 * 指定された位置に値をセット
 *
 * @param x     行
 * @param y     列
 * @param v     値：nil可（その代わり、NSNullをセットしてもnilに変換してしまう）
 */
- (void) setAtX:(int)x andY:(int)y value:(id)v {
    if(v==nil) {
        v = [NSNull null];
    }
    _array[y*_cx + x] = v;
}

/**
 * 指定された位置の値を取得
 *
 * @param x     行
 * @param y     列
 * @return      値（NSNullは nil に変換して返す。）
 */
- (id) getAtX:(int)x andY:(int)y {
    id r = _array[y*_cx+x];
    return ([r isEqual:[NSNull null]]) ? nil : r;
}

/**
 * 指定された位置の値を取得
 * @param v  値（NSNullは nil に変換して返す。）
 */
-(BOOL)checkRangeX:(int)x andY:(int)y {
    return 0<=x && x < _cx && 0<=y && y<_cy;
}

/**
 * 再初期化
 * サイズが等しいか小さくなるときは再利用、大きくなるときは再作成する。
 */
-(void)reinitWithDimmensionX:(int)cx andY:(int)cy {
    if( nil!=_array && cx*cy <= _array.count) {
        _cx = cx;
        _cy = cy;
        for(int i=0, ci=cx*cy ; i<ci ; i++) {
            _array[i] = [NSNull null];
        }
    } else {
        _cx = cx;
        _cy = cy;
        _array = [[NSMutableArray alloc] initWithCapacity:cx*cy];
        for(int i=0, ci=cx*cy ; i<ci ; i++) {
            [_array addObject:[NSNull null]];
        }
    }
}



@end

