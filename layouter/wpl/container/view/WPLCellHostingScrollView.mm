//
//  WPLCellHostingScrollView.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/18.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCellHostingScrollView.h"
#import "WPLCellHostingHelper.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

@implementation WPLCellHostingScrollView {
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
 * コンテナ内の再配置処理
 *  通常は内部セルの変更や、コンテナのサイズ変更を検出して自動的に呼び出されるが、addCellを実行したとき、
 *  配置の更新が実行される前に、子セルが一瞬見えてしまってブサイクなことがあるので、その場合は、addCell後に、明示的にこのメソッドを呼ぶことで回避できる（かも）。
 */
- (void) render {
    [_hosting renderCell];
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

@end
