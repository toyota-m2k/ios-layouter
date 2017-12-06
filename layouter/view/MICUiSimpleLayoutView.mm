//
//  MICUiSimpleLayoutView.m
//  スクロールやD&Dをサポートしない単純なレイアウトビューの基底クラス
//
//  Created by 豊田 光樹 on 2016/02/17.
//  Copyright  2016年 M.TOYOTA Corporation. All rights reserved.
//

#import "MICUiSimpleLayoutView.h"
#import "MICUiStackLayout.h"
#import "MICUiRectUtil.h"

@implementation MICUiSimpleLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andLayouter:nil];
}

- (instancetype)initWithFrame:(CGRect)frame andLayouter:(id<MICUiLayoutProtocol>)layouter {
    self = [super initWithFrame:frame];
    if(nil!=self){
        _layouter = nil;
        if(nil!=layouter) {
            self.layouter = layouter;
        }
    }
    return self;
}

- (void)setLayouter:(id<MICUiLayoutProtocol>)layouter {
    _layouter = layouter;
    if( nil!=_layouter) {
        _layouter.parentView = self;
    }
}

- (void)sizeToFit {
    self.frame = MICRect(self.frame.origin, [_layouter getSize]);
}

@end
