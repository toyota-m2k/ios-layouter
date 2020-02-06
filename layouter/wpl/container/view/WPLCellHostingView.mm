//
//  WPLCellHostingView.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/08.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCellHostingView.h"
#import "WPLCellHostingHelper.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

@implementation WPLCellHostingView {
    WPLCellHostingHelper* _hosting;
}

- (instancetype)initWithFrame:(CGRect)frame container:(id<IWPLContainerCell>) containerCell {
    self = [super initWithFrame:frame];
    if (self) {
        _hosting = [[WPLCellHostingHelper alloc] initWithView:self container:containerCell];
    }
    return self;
}

/**
 * 初期化 (UIViewの初期化のオーバーライド）
 *  --> 別途、containerCell を設定すること
 */
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame container:nil];
}

- (instancetype)init {
    return [self initWithFrame:MICRect::zero()];
}

/**
 * ビューが親ビューにアタッチ/デタッチされるタイミングでサイズ監視の開始/停止を行う
 */
- (void)didMoveToSuperview {
    if(nil!=self.superview) {
        [_hosting attach];
    } else {
        [_hosting detach];
    }
}

/**
 * containerCellプロパティ (setter)
 * コンテナーセルをアタッチする。
 */
- (void)setContainerCell:(id<IWPLContainerCell>)containerCell {
    _hosting.containerCell = containerCell;
}

- (id<IWPLContainerCell>) containerCell {
    return _hosting.containerCell;
}

- (WPLBinder *)binder {
    return _hosting.binder;
}

- (CGFloat)animationDuration {
    return _hosting.animationDuration;
}

- (void)setAnimationDuration:(CGFloat)animationDuration {
    _hosting.animationDuration = animationDuration;
}

/**
 * レンダリング完了通知を受け取るためのリスナー
 */
- (void) setLayoutCompletionEventListener:(id)target action:(SEL)action {
    [_hosting setLayoutCompletionEventListener:target action:action];
}

/**
 * デフォルトのDuration(0.15)でアニメーションの有効・無効を切り替える
 */
- (void) enableAnimation:(bool)sw {
    if(sw) {
        self.animationDuration = 0.15;
    } else {
        self.animationDuration = 0;
    }
}

/**
 * コンテナ内の再配置処理
 *  通常は内部セルの変更や、コンテナのサイズ変更を検出して自動的に呼び出されるが、addCellを実行したとき、
 *  配置の更新が実行される前に、子セルが一瞬見えてしまってブサイクなことがあるので、その場合は、addCell後に、明示的にこのメソッドを呼ぶことで回避できる（かも）。
 */
- (void) render {
    [_hosting renderCell];
}

- (UIView*) view {
    return self;
}

- (void) dispose {
    [_hosting dispose];
}

@end
