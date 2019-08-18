//
//  WPLCellHostingScrollView.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/18.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLCellHostingScrollView.h"
#import "WPLCellHostingHelper.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

@implementation WPLCellHostingScrollView {
    WPLCellHostingHelper* _hosting;
}

/**
 * 初期化 (UIViewの初期化と同じ）
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _hosting = [[WPLCellHostingHelper alloc] initWithView:self];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:MICRect::zero()];
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

@end
