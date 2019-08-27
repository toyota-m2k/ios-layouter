//
//  WPLCellHostingScrollView.h
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/18.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPLContainerDef.h"
#import "WPLBinder.h"

@interface WPLCellHostingScrollView : UIScrollView<UIScrollViewDelegate>

/**
 * ホスティングするセルツリーのルートコンテナセル
 * （実体は、WPLCellHostingHelperが持っている）
 */
@property (nonatomic) id<IWPLContainerCell> containerCell;

/**
 * セルとのバインディングを保持するバインダーインスタンス
 * （実体は、WPLCellHostingHelperが持っている）
 */
@property (nonatomic,readonly) WPLBinder* binder;

/**
 * セル移動時のアニメーションのDuration
 *  <=0: アニメーションしない
 *  >0: Duration
 * （実体は、WPLCellHostingHelperが持っている）
 */
@property (nonatomic) CGFloat animationDuration;

/**
 * デフォルトのDuration(0.15)でアニメーションの有効・無効を切り替える
 */
- (void) enableAnimation:(bool)sw;

/**
 * 初期化
 */
- (instancetype)initWithFrame:(CGRect)frame container:(id<IWPLContainerCell>) containerCell;

/**
 * コンテナ内の再配置処理
 *  通常は内部セルの変更や、コンテナのサイズ変更を検出して自動的に呼び出されるが、addCellを実行したとき、
 *  配置の更新が実行される前に、子セルが一瞬見えてしまってブサイクなことがあるので、その場合は、addCell後に、明示的にこのメソッドを呼ぶことで回避できる（かも）。
 */
- (void) render;

@end

