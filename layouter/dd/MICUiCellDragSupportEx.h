//
//  MICUiCellDragSupportEx.h
//
//  異なるビューの間をD&Dできるドラッグサポータークラス
//
//  Created by 豊田 光樹 on 2014/11/05.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiCellDragSupport.h"

@interface MICUiCellDragSupportEx : MICUiCellDragSupport

/**
 * 初期化
 */
- (MICUiCellDragSupportEx*) init;

/**
 * レイアウターが入れ子になっていて、すべてのレイアウターの共通のルートレイアウターが唯一つ存在する場合（例：MICUiAccordionViewのレイアウターなど）に、
 * そのルートレイアウターを登録する。
 */
- (id) addRootLayouter:(id<MICUiDraggableLayoutProtocol>)layouter andContainerView:(UIView*)view;

/**
 * 構成上の親を持つレイアウターを登録する。
 * また、ルートに複数のレイアウターを並列に並べる場合（例：カスタマイズのために、２つのビューを並べる）には、addRootLayouterメソッドは呼ばないで、
 * このメソッドの　parentNodeにnilを渡す。
 */
- (id) addSubLayouter:(id<MICUiDraggableLayoutProtocol>)layouter andContainerView:(UIView*)view toParentNode:(id)parentNode;

/**
 * childLayoutは、parentLayoutの子孫か？
 */
- (bool) isLayout:(id<MICUiDraggableLayoutProtocol>)childLayout descendantOf:(id<MICUiDraggableLayoutProtocol>)parentLayout;

//
///**
// * コンテナビューとしてUIScrollView派生クラスを使用する場合に、
// * レイアウターのサイズ変更に合わせてスクロール領域を調整したり、D&Dによる自動スクロールを有効にする。
// * 早い話、layouterのdelegateに、このサポーターを設定する。
// *
// *  @param  enable  true:有効化　/ false: 無効化
// */
//- (void) enableScrollSupport:(BOOL)enable;
//
//
///**
// * 長押しによるカスタマイズ開始、タップによるカスタマイズ終了を有効化・無効化する。
// * 事前に、layouter(or strongLayouter)、containerViewプロパティに有効な値を設定しておく必要がある。
// *
// * @param longPress             true: 長押しで、カスタマイズ（D&D)モードへの移行を有効化
// * @param tap                   true: 画面タップで、カスタマイズモード終了を有効化
// */
//- (void) beginCustomizingWithLongPress:(BOOL)longPress
//                            endWithTap:(BOOL)tap;

@end
