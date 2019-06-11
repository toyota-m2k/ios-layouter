//
//  MICUiSimpleLayoutView.h
//  スクロールやD&Dをサポートしない単純なレイアウトビューの基底クラス
//
//  Created by @toyota-m2k on 2016/02/17.
//  Copyright  2016年 @toyota-m2k Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiLayout.h"

@interface MICUiSimpleLayoutView : UIView {
    id<MICUiLayoutProtocol> _layouter;
}

@property (nonatomic) id<MICUiLayoutProtocol> layouter;

- (instancetype)initWithFrame:(CGRect)frame andLayouter:(id<MICUiLayoutProtocol>)layouter;
@end
