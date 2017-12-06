//
//  MICUiAccordionView.h
//
//  複数のAccordionCellViewを縦または横方向に並べて配置するアコーディオンビュー
//
//  Created by 豊田 光樹 on 2014/10/31.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiStackView.h"
#import "MICUiAccordionCellView.h"

/**
 * アコーディオンビュークラス
 *  StackViewを継承し、AccordionCellViewを子ビューとして保持することに特化したクラス。
 */
@interface MICUiAccordionView : MICUiStackView<MICUiAccordionCellLayoutDelegate,MICUiSizeDeterminableProtocol,MICUiStackLayoutGetCellSizeDelegate, MICUiDropAcceptorDelegate>

@property (nonatomic, readonly) int cellCount;          ///< 保持しているアコーディオンセルの数（＝StackViewの子の数）

- (MICUiAccordionView*) init;
- (MICUiAccordionView*) initWithFrame:(CGRect)frame;

- (id)addChild:(UIView *)view;
- (id)addChild:(UIView *)view updateLayout:(bool)update withAnimation:(bool)animation;
- (id)insertChild:(UIView*)view beforeSibling:(UIView*)sibling;
- (id)insertChild:(UIView*)view beforeSibling:(UIView*)sibling updateLayout:(bool)update withAnimation:(bool)animation;

- (MICUiAccordionCellView*) cellAt:(int)idx;

@end
