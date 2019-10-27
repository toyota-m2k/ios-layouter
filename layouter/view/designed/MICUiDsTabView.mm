//
//  MICUiDsTabView.m
//
//  タブビュー（タブ耳と切り替わるボディビューから構成されるビュー）クラス
//
//  Created by @toyota-m2k on 2014/12/15.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiDsTabView.h"
#import "MICUiRectUtil.h"
#import "MICUiDsTabButton.h"
#import "MICUiDsDefaults.h"
#import "MICUiDsSvgIconButton.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"
#import "MICUiColorUtil.h"

#define DEF_TABBAR_HEIGHT 30

@implementation MICUiDsTabView {
    MICUiDsTabButton* _tabSelected;
}

#pragma mark - 初期化・プロパティ

- (void) prevTab:(id)sender {
    [self.tabBar scrollPrev];
}
- (void) nextTab:(id)sender {
    [self.tabBar scrollNext];
}


/**
 * 初期化
 */
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(nil!=self) {
        _borderWidth = MIC_TAB_BORDER_WIDTH;
        _roundRadius = MIC_TAB_ROUND_RADIUS;
        _fontSize = MIC_TAB_FONT_SIZE;
        _contentMargin = MIC_TAB_CONTENT_MARGIN;
        _iconTextMargin = MIC_TAB_ICON_TEXT_MARGIN;
        
        _tabSelected = nil;
        MICRect rcTabbar = frame;
        rcTabbar = rcTabbar.partialTopRect(DEF_TABBAR_HEIGHT);
        MICUiTabBarView* tabbar = [[MICUiTabBarView alloc] initWithFrame:rcTabbar];
        tabbar.bar.stackLayout.cellSpacing = -_borderWidth;
        tabbar.backgroundColor = MICCOLOR_TAB_BACKGROUND;

        let prev = [self.class createArrowButton:false];
        [prev setTarget:self action:@selector(prevTab:)];
        let next = [self.class createArrowButton:true];
        [next setTarget:self action:@selector(nextTab:)];

//        UIButton* prev = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [prev setTitle:@"<" forState:UIControlStateNormal];
//        prev.frame = MICRect::XYWH(0,400,30,30);
//        prev.backgroundColor = [UIColor grayColor];
//        [prev setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//
//        UIButton* next = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [next setTitle:@">" forState:UIControlStateNormal];
//        next.frame = MICRect::XYWH(50,400,30,30);
//        next.backgroundColor = [UIColor grayColor];
//        [next setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

//        [prev addTarget:self action:@selector(prevTab:) forControlEvents:UIControlEventTouchUpInside];
//        [next addTarget:self action:@selector(nextTab:) forControlEvents:UIControlEventTouchUpInside];

        [tabbar addLeftFuncButton:prev function:MICUiTabBarFuncButtonSCROLL_PREV];
        [tabbar addRightFuncButton:next function:MICUiTabBarFuncButtonSCROLL_NEXT];
        
        [self setLabelView:tabbar];
    }
    return self;
}

/**
 * tabHeightプロパティのセッター
 */
- (void) setTabHeight:(CGFloat)height {
    if(_tabHeight!=height) {
        _tabHeight = height;
        MICUiTabBarView* tabbar = [self tabBar];
        MICRect frame = tabbar.frame;
        frame.setHeight(height);
        tabbar.frame = frame;
        self.needsCalcLayout = true;
    }
}

/**
 * 内部で使われているタブバーを取得
 */
- (MICUiTabBarView*) tabBar {
    return (MICUiTabBarView*)self.labelView;
}

/**
 * 選択中のタブ（キー）を取得
 */
- (NSString*) selectedTab {
    return (nil!=_tabSelected) ? _tabSelected.key : nil;
}

- (void) setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.tabBar.bar.stackLayout.cellSpacing = -borderWidth;
}

#pragma mark - タブ操作

/**
 * タブボタンを取得
 */
- (MICUiDsTabButton*) getTabButton:(NSString *)key {
    UIView* btn = [self.tabBar findTab:^(UIView* v){
        if([v isKindOfClass:MICUiDsTabButton.class] && [((MICUiDsTabButton*)v).key isEqualToString:key]) {
            return true;
        }
        return false;
    }];
    return (MICUiDsTabButton*)btn;
}

- (CGSize) calcTabSize:(MICUiDsTabButton*)tab {
    CGFloat width = 0;
    if(_tabWidth>0) {
        width = _tabWidth;
    } else {
        // NORMALのアイコンを前提にサイズを計算
        // もし、Stateに応じてアイコンサイズが変わる、アイコンの有無が変わる（チェックアイコンなど）場合には、
        // ここの実装を見直す必要がある。
        width = [tab calcPlausibleButtonSizeFotHeight:_tabHeight forState:MICUiViewStateNORMAL].width;
        if(_tabMinWidth>0 && width<_tabMinWidth) {
            width = _tabMinWidth;
        } else if(_tabMaxWidth>0 && width>_tabMaxWidth) {
            width = _tabMaxWidth;
        }
        
    }
    return MICSize(width, _tabHeight);
}

/**
 * タブを追加
 */
- (void)addTab:(NSString*)key label:(NSString *)label color:(id<MICUiStatefulResourceProtocol>)colors icon:(id<MICUiStatefulResourceProtocol>)icons updateView:(bool)updateView{
    MICUiDsTabButton* btn = [[MICUiDsTabButton alloc] init];
    btn.text = label;
    btn.key = key;
    btn.colorResources = (nil!=colors) ? colors : MICUiDsDefaults.tabColor;
    btn.iconResources = icons;
    btn.borderWidth = _borderWidth;
    btn.fontSize = _fontSize;
    btn.contentMargin = _contentMargin;
    btn.iconTextMargin = _iconTextMargin;
    btn.roundRadius = _roundRadius;
    btn.attachBottom = _attachBottom;
    btn.customButtonDelegate = self;
    btn.turnOver = _turnOver;

    btn.frame = MICRect(CGPointZero, [self calcTabSize:btn]);
    [self.tabBar addTab:btn updateView:updateView];
}

/**
 * タブを削除
 */
- (void) removeTab:(NSString*)key {
    UIView* btn = [self getTabButton:key];
    if(nil!=btn) {
        [self.tabBar removeTab:btn updateView:false];
    }
}

/**
 * タブを選択
 * @param   key タブを指定するキー（nilを渡すと選択解除）
 */
- (void) selectTab:(NSString *)key {
    if(nil == key) {
        if(nil!=_tabSelected) {
            _tabSelected.selected = false;
            _tabSelected = nil;
        }
    } else {
        MICUiDsTabButton* seltab = [self getTabButton:key];
        if(nil!=seltab && _tabSelected!=seltab) {
            _tabSelected.selected = false;
            _tabSelected.selected = true;
            _tabSelected = seltab;
            if(nil!=_tabViewDelegate) {
                [_tabViewDelegate onTabSelected:self selectTab:_tabSelected.key];
            }
        }
    }
}

/**
 * D&Dによるタブ並び順のカスタマイズを開始
 */
- (void) beginCustomize {
    [self.tabBar beginCustomizing];
}

/**
 * D&Dによるタブ並び順のカスタマイズを終了
 */
- (void) endCustomize {
    [self.tabBar endCustomizing];
}

#pragma mark - MICUiDsCustomButtonDelegate

/**
 * ボタンの状態(buttonStateプロパティ)が変更されたときの通知
 */
- (void)onCustomButtonStateChangedAt:(MICUiDsCustomButton *)view from:(MICUiViewState)before to:(MICUiViewState)after {
}

/**
 * ボタンがタップされたときの通知
 */
- (void)onCustomButtonTapped:(MICUiDsCustomButton *)view {
    if(_tabSelected == view) {
        // 選択中のタブがもう一度タップされた→折り畳み状態をトグル
        [self toggleFolding:true onCompleted:nil];
    } else {
        if( nil!=_tabSelected ) {
            _tabSelected.selected = false;
        }
        _tabSelected = (MICUiDsTabButton*)view;
        _tabSelected.selected = true;
        [self.tabBar ensureTabVisible:view animated:true];
        if(nil!=_tabViewDelegate) {
            [_tabViewDelegate onTabSelected:self selectTab:_tabSelected.key];
        }
    }
}

#define SVG_PATH_NEXT   @"M8.59,16.58L13.17,12L8.59,7.41L10,6L16,12L10,18L8.59,16.58Z"
#define SVG_PATH_PREV   @"M15.41,16.58L10.83,12L15.41,7.41L14,6L8,12L14,18L15.41,16.58Z"

/**
 * 矢印ボタンを作成
 */
+ (MICUiDsSvgIconButton*) createArrowButton:(bool) next {
    MICSize iconSize(MICSize(24,24));
    MICSize viewboxSize(24,24);

    let btn = [[MICUiDsSvgIconButton alloc] initWithFrame:MICRect(iconSize) iconSize:iconSize pathViewboxSize:viewboxSize];
    btn.colorResources = [[MICUiStatefulResource alloc] initWithDictionary:
                                @{
                                  MICUiStatefulSvgPathNORMAL: next ? SVG_PATH_NEXT : SVG_PATH_PREV,
                                  MICUiStatefulBgColorNORMAL: UIColor.darkGrayColor,
                                  MICUiStatefulFgColorNORMAL: UIColor.whiteColor,
                                  MICUiStatefulFgColorACTIVATED: MICUiColorRGB256(0,122,255),
                                  MICUiStatefulFgColorDISABLED: UIColor.grayColor,
                                }];
    btn.stretchIcon = true;
    return btn;
}
@end
