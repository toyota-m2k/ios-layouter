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
