//
//  MICUiLayoutView.h
//
//  レイアウター（MICUiLayoutProtocolに準拠するオブジェクト）を内包するスクロールビューの共通実装
//
//  Created by 豊田 光樹 on 2014/10/31.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiLayout.h"
#import "MICUiCellDragSupport.h"

/**
 * レイアウター（MICUiLayoutProtocolに準拠するオブジェクト）を内包するスクロールビュー基底クラス
 */
@interface MICUiLayoutView : UIScrollView<MICUiSizeDeterminableProtocol> {
@protected
    __weak id<MICUiLayoutProtocol> _layouter;
    __strong id<MICUiLayoutProtocol> _strongLayouter;
    id<MICUiDragSupporter> _dragSupport;
}

@property (nonatomic,weak) id<MICUiLayoutProtocol> layouter;                ///< レイアウター
@property (nonatomic,strong) id<MICUiLayoutProtocol> strongLayouter;        ///< このビューにレイアウターを保持させる場合は、こちらのプロパティにセットする。
@property (nonatomic,readonly) id<MICUiDragSupporter> dragSupport;          ///< ドラッグサポーターオブジェクト（通常は、MICUiCellDragSupport/Ex）
@property (nonatomic,weak) UIView* dragOverlayBaseView;                     ///< D&D操作用オーバーレイの親ビュー（nilなら、self.superviewを親にする）
@property (nonatomic) NSString* name;                                       ///< for debug

/**
 * サイズゼロで初期化
 */
- (MICUiLayoutView*) init;

/**
 * 初期サイズを与えて初期化
 */
- (MICUiLayoutView*) initWithFrame:(CGRect) frame;

/**
 * スクロールサポートの有効化
 */
- (void)enableScrollSupport:(BOOL)enable;

/**
 * 長押しによるカスタマイズ開始、タップによるカスタマイズ終了を有効化・無効化する。
 */
- (void) beginCustomizingWithLongPress:(BOOL)longPress
                            endWithTap:(BOOL)tap;

/**
 * カスタマイズ（D&Dモード）を開始する。
 */
- (void) beginCustomizing;

/**
 * カスタマイズ（D&Dモード）を終了する。
 */
- (void) endCustomizing;

/**
 * [PROTECTED] DragSupportインスタンスを作成
 * 
 * enableScrollSupport, beginCustomizingWithLongPress から必要に応じて呼び出される。外部から明示的に呼び出す必要はない。
 * サブクラスで、別のサポータを使いたい場合などにオーバーライドする。
 */
- (void) prepareDragSupporter;

// Note:
//
//  サブビューの追加・削除は専用メソッド(addChild/removeChild)を使用すること。
//
//  addSubview/insertSubviewやremoveFromSuperViewで子ビューの追加・削除を行うと、レイアウターの管理外に置かれるので要注意。
//  本当は、didAddSubview/willRemoveSubview を使って、自動的にセルを管理するようにしたかったが、D&D操作のときに、
//  子ビューをoverlayに移すために、一旦削除して追加し直すような処理が入っており、レイアウターが管理する子ビューとUIViewの子ビューが一致しない期間が存在してしまうため、
//  この方法は断念した。同様の理由で、addSubview/insertSubviewをオーバーライドして、セル管理を埋め込む作戦もうまくいかないため、
//  やむなく、専用メソッドを用意することとした。
//  逆に、レイアウターによって並べ替えられないサブビューを追加できる点をポジティブに評価してはどうだろう。
//

/**
 * 子ビューを追加（アニメーションなし）
 */
- (void)addChild:(UIView*)view;
/**
 * 子ビューを追加
 */
- (void)addChild:(UIView*)view updateLayout:(bool)update withAnimation:(bool)animation;

/**
 * 子ビューを挿入（アニメーションなし）
 */
- (void)insertChild:(UIView*)view beforeSibling:(UIView*)sibling;
/**
 * 子ビューを挿入
 */
- (void)insertChild:(UIView*)view beforeSibling:(UIView*)sibling updateLayout:(bool)update withAnimation:(bool)animation;

/**
 * 子ビューを削除（アニメーションなし）
 */
- (void)removeChild:(UIView*)view;
/**
 * 子ビューを削除
 */
- (void)removeChild:(UIView*)view updateLayout:(bool)update withAnimation:(bool)animation;

/**
 * レイアウトを更新
 */
- (void)updateLayout:(bool)animation;

@end
