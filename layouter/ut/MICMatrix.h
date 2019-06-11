//
//  MICMatrix.h
//  DTable
//
//  Created by @toyota-m2k on 2014/10/31.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

//--------------------------------------------------------------------------------------
#pragma mark - ２次元配列（ｍxｎマトリックス）クラス

/**
 * ２次元配列（ｍxｎマトリックス）クラス
 *
 * cx     行数
 * cy     列数
 */
@interface MICMatrix : NSObject {
}

@property (nonatomic) int cx;
@property (nonatomic) int cy;


- (id) init;

/**
 * 初期化
 *
 * @param cx     行
 * @param cy     列
 */
- (id) initWithDimmensionX:(int)cx andY:(int)cy;

/**
 * 初期化（コピーコンストラクタ）
 */
- (id) initWithMatrix:(MICMatrix*)src;


/**
 * 指定された位置に値をセット
 *
 * @param x     行
 * @param y     列
 * @param v     値：nil可（その代わり、NSNullをセットしてもnilに変換してしまう）
 */
- (void) setAtX:(int)x andY:(int)y value:(id)v;

/**
 * 指定された位置の値を取得
 *
 * @param x     行
 * @param y     列
 * @return      値（NSNullは nil に変換して返す。）
 */
- (id) getAtX:(int)x andY:(int)y;

/**
 * 行・列番号がこのオブジェクトの有効範囲内かどうかチェック
 *
 * @param x     行
 * @param y     列
 * @return      true: 範囲内　/ false:範囲外（getAt/setAtに渡すと例外が投げられる）
 */
- (BOOL) checkRangeX:(int)x andY:(int)y;


/**
 * 再初期化
 * サイズが等しいか小さくなるときは再利用、大きくなるときは再作成する。
 */
-(void)reinitWithDimmensionX:(int)cx andY:(int)cy;

@end
