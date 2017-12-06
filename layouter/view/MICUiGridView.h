//
//  MICUiGridView.h
//
//  GridLayout（Viewをタイル状に配置するレイアウター）を内包するスクロールビュー
//
//  Created by 豊田 光樹 on 2014/10/31.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiLayoutView.h"
#import "MICUiGridLayout.h"

@interface MICUiGridView : MICUiLayoutView

@property (nonatomic,readonly) MICUiGridLayout* gridLayout;

- (MICUiGridView*) init;

- (MICUiGridView*) initWithFrame:(CGRect) frame;

- (void)addChild:(UIView*) subview
           unitX:(int)unitX
           unitY:(int)unitY;

- (void)addChild:(UIView *)view
           unitX:(int)unitX
           unitY:(int)unitY
    updateLayout:(bool)update
   withAnimation:(bool)animation;

- (void)insertChild:(UIView*) subview
      beforeSibling:(UIView *)sibling
              unitX:(int)unitX
              unitY:(int)unitY;

- (void)insertChild:(UIView *)subview
      beforeSibling:(UIView *)sibling
              unitX:(int)unitX
              unitY:(int)unitY
       updateLayout:(bool)update
      withAnimation:(bool)animation;

@end
