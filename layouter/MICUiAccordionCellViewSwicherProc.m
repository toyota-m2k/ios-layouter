//
//  MICUiAccordionCellViewSwicherProc.m
//  LayoutDemo
//
//  Created by @toyota-m2k on 2015/01/07.
//  Copyright (c) 2015年 @toyota-m2k. All rights reserved.
//

#import "MICUiAccordionCellViewSwicherProc.h"

@implementation MICUiAccordionCellViewSwicherProc {
    bool _changing;
    bool _reserved;
}

- (instancetype) init {
    self = [super init];
    if( nil!=self) {
        _changing = false;
        _reserved = false;
    }
    return self;
}

- (void)setStrongLayouter:(id<MICUiLayoutProtocol>)strongLayouter {
    _strongLayouter = strongLayouter;
    _layouter = strongLayouter;
}

- (void)setStrongSwitcher:(MICUiSwitchingViewMediator *)strongSwitcher {
    _strongSwitcher = strongSwitcher;
    _switcher = strongSwitcher;
}

- (void)setViewVisibility:(UIView *)view visible:(bool)show onCompleted:(void (^)(BOOL))onCompleted{
    if([view isKindOfClass:MICUiAccordionCellView.class]) {
        bool anim = true; // !_changing;
        if(show) {
            [((MICUiAccordionCellView*)view) unfold:anim onCompleted:onCompleted];
        } else {
            [((MICUiAccordionCellView*)view) fold:anim onCompleted:onCompleted];
        }
    } else {
        if(nil!=onCompleted) {
            onCompleted(false);
        }
    }
    return;
}

- (bool)isViewVisible:(UIView *)view {
    if([view isKindOfClass:MICUiAccordionCellView.class]) {
        return !((MICUiAccordionCellView*)view).folding;
    }
    return false;
}

#if 0
// アコーディオンセルの開閉に伴う、switcherによる副次的な状態変更を、セルの開閉イベントをベースにswitcherとlayouterに通知する実装。
//　個々のセルが開閉されるたびに、updateView:trueで、setViewVisibilityと、updateLayoutWithReservingCellを呼び出すため、
//  再帰的に、画面更新が走り、効率が悪くなる可能性がある。
//  swiching中のsetViewVisibilityは、完全に無駄。
//

- (void)accordionCellFolded:(MICUiAccordionCellView *)sender fold:(BOOL)folded lastFrame:(CGRect)frame {
    [_switcher setViewVisibility:[_switcher getViewName:sender] visible:!folded updateView:true];
}

- (void)accordionCellFolding:(MICUiAccordionCellView *)sender fold:(BOOL)folded lastFrame:(CGRect)frame {
    [_layouter updateLayoutWithReservingCell:sender atLocation:frame animated:true onCompleted:nil];
}

- (void)willSwitchViewVisibility:(MICUiSwitchingViewMediator *)sender {
    
}

- (void)didSwitchViewVisibility:(MICUiSwitchingViewMediator *)sender changed:(bool)changed {
    if(changed) {
        [_layouter requestRecalcLayout];
        [_layouter updateLayout:true onCompleted:nil];
    }
}

#else
// switcherによる開閉操作中は、setViewVisibilityを抑制し、画面更新も保留し、最後にまとめて１度だけ updateLayoutを呼ぶようにした実装。
// アコーディオンセル開閉時に、updateLayoutWithReservingCellを呼ばないため、AccordionCellの開閉動作とLayouterの再配置動作が
// 別々（２段階）に起きるのが難点といえば難点。
// しかし、上の方法だと、１個のアコーディオンセルの開閉に関しては、Layouterの再配置が同時に実行されるが、複数のセルの開閉動作を
// 同時には実行しないため、結局、段階的に変化するように見えてしまい、どちらがよいともいえない。


/**
 * アコーディオンの開閉操作が実行される前に呼び出される。
 *  @param sender   呼び出し元アコーディオン
 *  @param folded   true:折りたたまれる　/ false:展開される
 *  @param frame    操作完了後のフレーム矩形
 */
- (void)accordionCellFolding:(MICUiAccordionCellView *)sender fold:(BOOL)folded lastFrame:(CGRect)frame {
    if(!_changing) {
        [_layouter updateLayoutWithReservingCell:sender atLocation:frame animated:true onCompleted:nil];
    }
}

/**
 * アコーディオンの開閉操作が実行された後に呼び出される。
 *  @param sender   呼び出し元アコーディオン
 *  @param folded   true:折りたたまれた　/ false:展開された
 *  @param frame    操作完了後のフレーム矩形
 */
- (void)accordionCellFolded:(MICUiAccordionCellView *)sender fold:(BOOL)folded lastFrame:(CGRect)frame {
    if(!_changing) {
        _reserved = true;
        [_switcher setViewVisibility:[_switcher getViewName:sender] visible:!folded updateView:true];
    }
}

- (void)willSwitchViewVisibility:(MICUiSwitchingViewMediator *)sender {
    _changing = true;
    
}

- (void)didSwitchViewVisibility:(MICUiSwitchingViewMediator *)sender changed:(bool)changed {
    if(changed||_reserved) {
        [_layouter requestRecalcLayout];
        [_layouter updateLayout:true onCompleted:nil];
        _reserved = false;
    }
    _changing = false;
}
#endif

@end
