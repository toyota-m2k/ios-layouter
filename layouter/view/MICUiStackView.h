//
//  MICUiStackView.h
//
//  StackLayout（Viewを縦または横方向に並べて配置するレイアウター）を内包するスクロールビュー
//
//  Created by 豊田 光樹 on 2014/10/31.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiLayoutView.h"
#import "MICUiStackLayout.h"

@interface MICUiStackView : MICUiLayoutView {
    MICUiStackLayout* _stackLayout;
}

@property (nonatomic,readonly) MICUiStackLayout* stackLayout;

- (MICUiStackView*) init;

- (MICUiStackView*) initWithFrame:(CGRect) frame;

@end
