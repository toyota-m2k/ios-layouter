//
//  MICUiGridView.m
//
//  GridLayout（Viewをタイル状に配置するレイアウター）を内包するスクロールビュー
//
//  Created by 豊田 光樹 on 2014/10/31.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiGridView.h"

@implementation MICUiGridView {
}

/**
 * 最小限の情報でビューを初期化する。
 * 実際に使う前には、cellSizeやfixedSideCountなどの属性を設定すること。
 * また、D&Dやスクロール範囲の自動更新を有効にするには、enableDragSupportBeginCustomizingOnLongPress:endCustomizingOnTap:を呼び出しておく必要がある。
 */
- (MICUiGridView*) init {
    self = [super init];
    if( nil!=self) {
        _gridLayout = [[MICUiGridLayout alloc] init];
        _gridLayout.parentView = self;
        _layouter = _gridLayout;
    }
    return self;
}

/**
 *
 */
- (MICUiGridView*) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if( nil!=self) {
        _gridLayout = [[MICUiGridLayout alloc] init];
        [super setStrongLayouter:_gridLayout];
    }
    return self;
}

- (void)addChild:(UIView*) subview
           unitX:(int)unitX
           unitY:(int)unitY {
    [self insertChild:subview beforeSibling:nil unitX:unitX unitY:unitY updateLayout:false withAnimation:false];
}

- (void)addChild:(UIView *)subview
           unitX:(int)unitX
           unitY:(int)unitY
    updateLayout:(bool)update
   withAnimation:(bool)animation {
    [self insertChild:subview beforeSibling:nil unitX:unitX unitY:unitY updateLayout:update withAnimation:animation];
}

- (void)insertChild:(UIView*) subview
      beforeSibling:(UIView *)sibling
              unitX:(int)unitX
              unitY:(int)unitY {
    [self insertChild:subview beforeSibling:sibling unitX:unitX unitY:unitY updateLayout:false withAnimation:false];
}

- (void)insertChild:(UIView *)subview
      beforeSibling:(UIView *)sibling
              unitX:(int)unitX
              unitY:(int)unitY
       updateLayout:(bool)update
      withAnimation:(bool)animation {
    if(nil!=_gridLayout) {
        [_gridLayout insertChild:subview unitX:unitX unitY:unitY before:sibling];
        if(update) {
            [_gridLayout updateLayout:animation onCompleted:nil];
        }
    }
}


#pragma mark - MICUiSizeDeterminableProtocolの実装

/**
 * コンテントの表示に必要な最小矩形を取得する。
 */
- (CGSize) calcMinSizeOfContents {
    CGSize sizeCont = [_gridLayout getSize];
    CGSize sizeView = self.frame.size;
    if(_gridLayout.growingOrientation == MICUiVertical) {
        sizeCont.height = sizeView.height;
    } else {
        sizeCont.width = sizeView.width;
    }
    return sizeCont;
}


@end
