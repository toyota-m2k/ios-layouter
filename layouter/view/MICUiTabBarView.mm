//
//  MICUiTabView.m
//
//  タブ（ボタンなど）を並べるタブバービュークラス
//
//  Created by @toyota-m2k on 2014/11/20.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiTabBarView.h"
#import "MICUiRectUtil.h"

@interface FuncButton : NSObject
@property UIView* view;
@property MICUiTabBarFuncButton func;
@property bool right;
@end

@implementation FuncButton

- (instancetype) initWithView:(UIView*)view forFunc:(MICUiTabBarFuncButton)func toRight:(bool)right {
    self = [super init];
    if(nil!=self) {
        _view = view;
        _func = func;
        _right = right;
    }
    return self;
}
@end


/**
 * タブシートで使用するタブが並んでいるバーをタブバーと呼んでみるテスト
 */
@interface MICUiTabBarView () {
    MICUiStackLayout* _barLayout;           ///< 両端のスクロールボタンとタブコンテナ（StackView）を保持するためのレイアウター
//    UIView* _prevButton;                    ///< 左スクロールボタン
//    UIView* _nextButton;                    ///< 右スクロールボタン
    NSMutableArray* _funcButtons;
    
    bool _needsCalcLayout;                  ///< 配置再計算フラグ
    bool _needsUpdateFuncButtons;
}

@end

@implementation MICUiTabBarView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _barLayout = [[MICUiStackLayout alloc] initWithOrientation:MICUiHorizontal alignment:MICUiAlignExFILL];
        _barLayout.orientation = MICUiHorizontal;
        //        _barLayout.parentView = self;
        _bar = [[MICUiStackView alloc] init];
        _bar.stackLayout.name = @"Tab Buttons Layout";
        [_barLayout addChild:_bar];
        [self addSubview:_bar];
        _bar.bounces = false;
        _bar.delegate = self;
        _bar.stackLayout.layoutDelegate = self;
        _bar.stackLayout.orientation = MICUiHorizontal;
        _bar.scrollEnabled = false;
        _funcButtons = [[NSMutableArray alloc] init];
        _needsUpdateFuncButtons = false;
        _needsCalcLayout = false;
    }
    return self;
}

/**
 * タブの総数
 */
-(int) tabCount {
    return _bar.stackLayout.childCount;
}

/**
 * 指定位置のタブを取得
 */
- (UIView*) tabAt:(int)index {
    return [_bar.stackLayout childAt:index];
}

- (int) indexOfTab:(UIView*) view {
    return [_bar.stackLayout indexOfChild:view];
}

- (UIView*) findTab:(bool (^)(UIView *tab))isMatch {
    for(MICUiLayoutCell* cell in _bar.stackLayout.children) {
        if( isMatch(cell.view) ) {
            return cell.view;
        }
    }
    return nil;
}

/**
 * 親ビューにアタッチされる/デタッチされる→ビューサイズ監視の開始・終了
 */
- (void)didMoveToSuperview {
    if(nil!=self.superview) {
        // アタッチされる
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        // デタッチされる
        [self removeObserver:self forKeyPath:@"frame"];
    }
    //NSLog(@"did move to superview: %@", [self.superview description]);
}

/**
 * ビューのサイズ変更監視
 */
- (void)didChangeValueForKey:(NSString *)key {
    if([key isEqualToString:@"frame"]) {
        _needsCalcLayout = true;
        [self updateLayout];
    }
}

/**
 * タブバーの左側にファンクションボタンを追加する。
 */
- (void)addLeftFuncButton:(UIView *)button function:(MICUiTabBarFuncButton)func {
    [_funcButtons addObject:[[FuncButton alloc] initWithView:button forFunc:func toRight:false]];
    [self addSubview:button];
    _needsCalcLayout = true;
    _needsUpdateFuncButtons = true;
}

/**
 * タブバーの右側にファンクションボタンを追加する。
 */
- (void)addRightFuncButton:(UIView *)button function:(MICUiTabBarFuncButton)func {
    [_funcButtons addObject:[[FuncButton alloc] initWithView:button forFunc:func toRight:true]];
    [self addSubview:button];
    _needsCalcLayout = true;
    _needsUpdateFuncButtons = true;
}

/**
 * タブ（UIView*）を追加する
 * @param   update  true:updateLayoutを呼び出す  /false:呼び出さない
 */
- (void) addTab:(UIView*)tab updateView:(bool)update {
    [_bar addChild:tab];
    if( update){
        [_bar updateLayout:false];
    }
}

/**
 * タブ（UIView*）を指定位置に挿入する。
 * @param   update  true:updateLayoutを呼び出す  /false:呼び出さない
 */
- (void) insertTab:(UIView*)tab beforeSibling:(UIView*)sibling updateView:(bool)update {
    [_bar insertChild:tab beforeSibling:sibling];
    if( update){
        [_bar updateLayout:false];
    }
}

/**
 * タブ（UIView*）を削除する
 * @param   update  true:updateLayoutを呼び出す  /false:呼び出さない
 */
- (void) removeTab:(UIView*)tab updateView:(bool)update {
    [_bar removeChild:tab];
    if( update){
        [_bar updateLayout:false];
    }
}

/**
 * (PRIVATE)隣のタブを取得
 */
- (MICUiLayoutCell*)getNeighborOfCell:(MICUiLayoutCell*)cell next:(bool)next {
    if(nil==cell) {
        return nil;
    }
    int i = [_bar.stackLayout indexOfCell:cell];
    if(i<0) {
        return nil;
    }
    if(!next) {
        i--;
    }
    if(i<0) {
        i=0;
    }
    if(i>=_bar.stackLayout.childCount) {
        i = _bar.stackLayout.childCount-1;
    }
    return [_bar.stackLayout cellAt:i];
}

/**
 * タブバーを左方向へスクロールする。
 */
- (void) scrollPrev {
    MICRect rc(_bar.contentOffset, _bar.frame.size);

    MICUiLayoutCell* cell = [self getNeighborOfCell:[_bar.stackLayout hitTestAtX:rc.left() andY:rc.center().y] next:false];
    if(nil==cell) {
        rc -= MICVector(rc.width()/5, 0);
    } else {
        rc = [_bar.stackLayout getCellRect:cell];
    }
    [_bar scrollRectToVisible:rc animated:true];
}

/**
 * タブバーを右方向へスクロールする。
 */
- (void) scrollNext {
    MICRect rc(_bar.contentOffset, _bar.frame.size);

    MICUiLayoutCell* cell = [self getNeighborOfCell:[_bar.stackLayout hitTestAtX:rc.right() andY:rc.center().y] next:true];
    if(nil==cell) {
        rc += MICVector(rc.width()/5, 0);
    } else {
        rc = [_bar.stackLayout getCellRect:cell];
    }
    [_bar scrollRectToVisible:rc animated:true];
}

- (void)ensureTabVisible:(UIView *)tab animated:(bool)anim{
    [_bar scrollRectToVisible:tab.frame animated:anim];
}


/**
 * レイアウトを計算する。
 */
- (void) calcLayout {
    if(_needsUpdateFuncButtons) {
        [self updateFuncButtons];
    }
    CGSize size = self.bounds.size;
    _barLayout.fixedSideSize = size.height;

    CGFloat width = size.width;
    for(FuncButton* f in _funcButtons) {
        if(!f.view.hidden) {
            width -= f.view.frame.size.width;
        }
    }
    
    MICRect frame = _bar.frame;
    if(width!=frame.width()) {
        frame.setWidth(width);
        _bar.frame = frame;
        [_barLayout requestRecalcLayout];
        [_barLayout calcLayout];
        [self updateScrollButtonVisibility];
    }
    _needsCalcLayout = false;
}

/**
 * タブの再配置を実行する。
 */
- (void) updateLayout {
    if(_needsCalcLayout) {
        [_barLayout requestRecalcLayout];
        [self calcLayout];
    }
    [_barLayout updateLayout:false onCompleted:nil];
    [_bar updateLayout:false];
}

/**
 * (PRIVATE)スクロールボタン表示の有効／無効の切り替え
 */
- (void) enableScrollButton:(MICUiTabBarFuncButton)func toState:(bool)enable{
    
    for(FuncButton* btn in _funcButtons) {
        if(btn.func == func && !btn.view.hidden) {
            if(btn.view.userInteractionEnabled != enable) {
                btn.view.userInteractionEnabled = enable;
                if(nil!=_tabViewDelegate) {
                    [_tabViewDelegate onFuncButtonStateChanged:btn.view enabled:enable];
                } else {
                    btn.view.alpha = (enable)?1.0f : 0.5f;
                }
            }
        }
    }
}

/**
 * スクロールボタンの表示状態を更新する
 */
- (void)updateButtonState {
    CGFloat contentOffset = _bar.contentOffset.x;
    CGFloat contentSize = _bar.contentSize.width;
    CGFloat viewSize = _bar.frame.size.width;

    bool left = contentOffset > 0;                              // 左にスクロール可能
    bool right = contentOffset + viewSize < contentSize;        // 右にスクロール可能
    [self enableScrollButton:MICUiTabBarFuncButtonSCROLL_PREV toState:left];
    [self enableScrollButton:MICUiTabBarFuncButtonSCROLL_NEXT toState:right];
}

/**
 * ファンクションボタンの配置を更新する。
 *  非表示のボタンをレイアウターから除外し、表示するボタンだけをレイアウターに登録する。
 */
- (void)updateFuncButtons {
    [_barLayout removeAllChildren];
    [_barLayout addChild:_bar];
    for(FuncButton* btn in _funcButtons) {
        if(!btn.view.hidden) {
            if(!btn.right) {
                [_barLayout insertChild:btn.view before:_bar];
            } else {
                [_barLayout addChild:btn.view];
            }
        }
    }
    _needsUpdateFuncButtons = false;
}

/**
 * スクロールボタンの表示・非表示を更新する。
 */
- (bool) updateScrollButtonVisibility {
    CGFloat contentSize = [_bar.stackLayout getSize].width;
    CGFloat viewSize = self.frame.size.width;
    for(FuncButton* btn in _funcButtons) {
        if(btn.func!=MICUiTabBarFuncButtonSCROLL_NEXT&&btn.func!=MICUiTabBarFuncButtonSCROLL_PREV&&!btn.view.hidden) {
            viewSize-=btn.view.frame.size.width;
        }
    }
    
    bool statusChanged = false;
    bool hidden = viewSize >= contentSize;
    for(FuncButton* btn in _funcButtons) {
        if(btn.func == MICUiTabBarFuncButtonSCROLL_PREV || btn.func == MICUiTabBarFuncButtonSCROLL_NEXT) {
            if(btn.view.hidden != hidden) {
                btn.view.hidden = hidden;
                statusChanged = true;
            }
        }
    }
    
    if(statusChanged) {
        _needsCalcLayout = _needsUpdateFuncButtons = true;
        [self calcLayout];
        [self updateButtonState];
        return true;
    }
    return false;
}

/**
 * コンテントのサイズが変更になった。
 *  スクロール領域 (UIScrollView#contentSize)を更新する。
 *  @param  layout  レイアウター
 *  @param  size    マージンを含むコンテント領域のサイズ
 */
- (void) onContentSizeChanged:(id) layout size:(CGSize)size {
    _bar.contentSize = size;
    if([self updateScrollButtonVisibility]) {
        [self updateLayout];
    }
}

/**
 * 指定された矩形領域が画面内に入るようスクロールすることを要求
 *  @param  layout  要求元のレイアウター
 *  @param  rect    領域指定（コンテナ（＝セルの親）：通常はUIScrollView)の座標系での領域）
 */
- (void) ensureRectVisible:(id) layout rect:(CGRect)rect {
    [_bar scrollRectToVisible:rect animated:true];
}

/**
 * タブバーのスクロールが終わったタイミングで、スクロールボタンの表示を更新する。
 * protocol UIScrollViewDelegate
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateButtonState];
}

#pragma mark - タブの並べ替え

/**
 * 長押しによるカスタマイズ開始、タップによるカスタマイズ終了を有効化・無効化する。
 * 事前に、layouter(or strongLayouter)、containerViewプロパティに有効な値を設定しておく必要がある。
 *
 * @param longPress             true: 長押しで、カスタマイズ（D&D)モードへの移行を有効化
 * @param tap                   true: 画面タップで、カスタマイズモード終了を有効化
 */
- (void) beginCustomizingWithLongPress:(BOOL)longPress
                            endWithTap:(BOOL)tap {
    [_bar beginCustomizingWithLongPress:longPress endWithTap:tap];
}

/**
 * カスタマイズ（D&Dモード）を開始する。
 */
- (void) beginCustomizing {
    [_bar beginCustomizing];
}

/**
 * カスタマイズ（D&Dモード）を終了する。
 */
- (void) endCustomizing {
    [_bar endCustomizing];
}



@end
