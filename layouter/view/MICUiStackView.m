﻿//
//  MICUiStackView.m
//
//  StackLayout（Viewを縦または横方向に並べて配置するレイアウター）を内包するスクロールビュー
//
//  Created by @toyota-m2k on 2014/10/31.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiStackView.h"

@implementation MICUiStackView

- (MICUiStackView*) init {
    self = [super init];
    if( nil!=self) {
        _stackLayout = [[MICUiStackLayout alloc] init];
        _stackLayout.parentView = self;
        _layouter = _stackLayout;
    }
    return self;
}

- (MICUiStackView*) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if( nil!=self) {
        _stackLayout = [[MICUiStackLayout alloc] init];
        [super setStrongLayouter:_stackLayout];
    }
    return self;
}

#pragma mark - MICUiSizeDeterminableProtocolの実装

/**
 * コンテントの表示に必要な最小矩形を取得する。
 */
- (CGSize) calcMinSizeOfContents {
    CGSize sizeCont = [_stackLayout getSize];
    CGSize sizeView = self.frame.size;
    if(_stackLayout.orientation == MICUiVertical) {
        sizeCont.height = sizeView.height;
    } else {
        sizeCont.width = sizeView.width;
    }
    return sizeCont;
}


@end
