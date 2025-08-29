//
//  MICUiViewbox.h
//  Windows WPF/WinUI の Viewboxにインスパイアされたビュークラス
//  １個の子要素を持ち、Viewboxのサイズにぴったり合うサイズに縮小・拡大(optional)して表示する。
//
//  Created by Mitsuki Toyota on 2025/03/05.
//  Copyright © 2025 toyota-m2k Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface MICUiViewbox : UIView
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic) bool expandable;
@property (nonatomic) MICUiAlign horzAlign;
@property (nonatomic) MICUiAlign vertAlign;
@property (nonatomic) NSString* debugText;

@end

NS_ASSUME_NONNULL_END
