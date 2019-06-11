//
//  MICUiCellDragHandler.h
//
//  MICUiCellDragSupport/MICUiCellDragSupportEx 共通のイベントハンドラ実装
//
//  Created by @toyota-m2k on 2014/11/07.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiLayout.h"

/**
 * MICUiCellDragSupport/MICUiCellDragSupportEx でD&Dイベントをハンドリングするためのクラス
 *  内部利用専用なので、直接・単独使用することはないはず。
 */
@interface MICUiCellDragHandler : NSObject

/**
 * 初期化
 */
- (MICUiCellDragHandler*) initWithOwner:(id<MICUiDragSupporter>)owner;

/**
 * ロングプレスでのカスタマイズ開始、タップによるカスタマイズ終了を有効化・無効化する。
 */
- (void) enableLongPressRecognizer:(BOOL)longPress
                  andTapRecognizer:(BOOL)tap;
/**
 * ビューにタップジェスチャを設定・解除する
 */
- (void)setTapGesture:(bool)enable onView:(UIView*)view;
/**
 * ビューにロングプレスジェスチャを設定・解除する
 */
- (void)setLongPressGesture:(bool)enable onView:(UIView*)view;
/**
 * ビューにパンジェスチャを設定・解除する
 */
- (void)setPanGesture:(bool)enable onView:(UIView*)view;

@end


