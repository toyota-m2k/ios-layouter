//
//  MICUiSimpleStackLayoutView.h
//  スクロールやD&Dをサポートしないスタックレイアウトビュー
//
//  Created by 豊田 光樹 on 2016/02/18.
//  Copyright  2016年 M.TOYOTA Corporation. All rights reserved.
//

#import "MICUiSimpleLayoutView.h"
#import "MICUiStackLayout.h"

@interface MICUiSimpleStackLayoutView : MICUiSimpleLayoutView

@property (nonatomic,readonly) MICUiStackLayout* stackLayouter;

- (instancetype)initWithFrame:(CGRect)frame orientation:(MICUiOrientation)orientation alignment:(MICUiAlignEx) align;

- (void)addSpacer:(CGFloat)spacing;

@end
