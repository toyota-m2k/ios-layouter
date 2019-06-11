//
//  MICUiStackView.h
//
//  StackLayout（Viewを縦または横方向に並べて配置するレイアウター）を内包するスクロールビュー
//
//  Created by @toyota-m2k on 2014/10/31.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
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
