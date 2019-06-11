//
//  MICUiSimpleStackLayoutView.m
//  スクロールやD&Dをサポートしない単純なスタックレイアウトビュー
//
//  Created by @toyota-m2k on 2016/02/18.
//  Copyright  2016年 @toyota-m2k Corporation. All rights reserved.
//

#import "MICUiSimpleStackLayoutView.h"
#import "MICUiStackView.h"

@implementation MICUiSimpleStackLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame orientation:MICUiVertical alignment:MICUiAlignExLEFT];
}

- (instancetype)initWithFrame:(CGRect)frame orientation:(MICUiOrientation)orientation alignment:(MICUiAlignEx) align {
    self = [super initWithFrame:frame];
    if (self) {
        _layouter = [[MICUiStackLayout alloc] initWithOrientation:orientation alignment:align];
    }
    return self;
}

- (MICUiStackLayout *)stackLayouter {
    return (MICUiStackLayout*)self.layouter;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    [self.layouter addChild:view];
}

- (void)addSpacer:(CGFloat)spacing {
    [self.stackLayouter addSpacer:spacing];
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    MICUiStackLayout *layouter = self.stackLayouter;
    if(MICUiVertical == layouter.orientation) {
        layouter.fixedSideSize = frame.size.width - layouter.marginRight - layouter.marginLeft;
        if(layouter.fitGrowingSideSize>0) {
            layouter.fitGrowingSideSize = frame.size.height;
        }
    } else {
        layouter.fixedSideSize = frame.size.height - layouter.marginTop - layouter.marginBottom;
        if(layouter.fitGrowingSideSize>0) {
            layouter.fitGrowingSideSize = frame.size.width;
        }
    }
    [layouter updateLayout:false onCompleted:nil];
}

@end
