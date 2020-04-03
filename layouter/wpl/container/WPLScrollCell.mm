//
//  WPLScrollCell.m
//
//  Created by @toyota-m2k on 2020/04/02.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLScrollCell.h"
#import "WPLContainersL.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"

#ifdef DEBUG
@interface WPLInternalScrollCellView : UIScrollView
@end
@implementation WPLInternalScrollCellView
@end
#else
#define WPLInternalGridView UIScrollView
#endif

#pragma mark -
@implementation WPLScrollCell {
    MICSize _cachedSize;
    MICSize _cachedContentSize;
}

#pragma mark - 構築・初期化
/**
 * StackPanel の正統なコンストラクタ
 */
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
            scrollOrientation:(WPLScrollOrientation) scrollOrientation {
    if(![view isKindOfClass:UIScrollView.class]) {
        NSAssert1(false, @"internal view of ScrollCell must be an instance of UIScrollView", name);
    }
    if(requestViewSize.height == VAUTO && (scrollOrientation&WPLScrollOrientationVERT)!=0) {
        NSLog(@"WARNING: AUTO-sizing to height of vertical scrollable ScrollCell (%@) is not allowd, assume it as STRETCH.", name);
        requestViewSize.height = VSTRC;
    }
    if(requestViewSize.width == VAUTO && (scrollOrientation&WPLScrollOrientationHORZ)!=0) {
        NSLog(@"WARNING: AUTO-sizing to width of horizontal scrollable ScrollCell (%@) is not allowd, assume it as STRETCH.", name);
        requestViewSize.width = VSTRC;
    }
    
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
    if(nil!=self) {
        _scrollOrientation = scrollOrientation;
    }
    return self;
}

/**
 * newCellWithView で呼び出されたときに備えて WPLCell#initWithView をオーバーライドしておく。
 */
- (instancetype) initWithView:(UIView *)view name:(NSString *)name margin:(UIEdgeInsets)margin requestViewSize:(CGSize)requestViewSize hAlignment:(WPLCellAlignment)hAlignment vAlignment:(WPLCellAlignment)vAlignment visibility:(WPLVisibility)visibility containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    return [self initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate scrollOrientation:WPLScrollOrientationBOTH];
}

- (instancetype) initWithView:(UIView *)view
                         name:(NSString *)name
                       params:(const WPLScrollCellParams&)params
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    return [self initWithView:view name:name margin:params._margin requestViewSize:params._requestViewSize hAlignment:params._align.horz vAlignment:params._align.vert visibility:params._visibility containerDelegate:containerDelegate scrollOrientation:params._scrollOrientation];
}

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) scrollCellWithName:(NSString*) name
                             params:(const WPLScrollCellParams&)params {
    return [[self alloc] initWithView:[[WPLInternalScrollCellView alloc] init] name:name params:params containerDelegate:nil];
}

+ (instancetype) scrollCellWithName:(UIView*)view
                               name:(NSString*) name
                             params:(const WPLScrollCellParams&)params {
    return [[self alloc] initWithView:view name:name params:params containerDelegate:nil];
}


- (void)addCell:(id<IWPLCell>)cell {
    if(self.cells.count>0) {
        NSAssert1(false, @"ScrollCell(%@) already has a child. no more children can be added.", self.name);
    }
    [super addCell:cell];
}

- (id<IWPLCell>) contentCell {
    return (self.cells.count>0) ? self.cells[0] : nil;
}

#pragma mark - レンダリング

/**
 * レイアウト準備（仮配置）
 * セル内部の配置を計算し、セルサイズを返す。
 * このあと、親コンテナセルでレイアウトが確定すると、layoutCompleted: が呼び出されるので、そのときに、内部の配置を行う。
 * @param regulatingCellSize    stretch指定のセルサイズを決めるためのヒント
 *    セルサイズ決定の優先順位
 *      requestedViweSize       regulatingCellSize          内部コンテンツ(view/cell)サイズ
 *      ○ 正値(fixed)                無視                       requestedViewSizeにリサイズ
 *        ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしない
 *        負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない (regulatingCellSize の stretch 指定は無視する)
 *        負値(stretch)            ○ 正値 (fixed)               regulatingCellSize にリサイズ
 * @return  セルサイズ（マージンを含む
 */
- (CGSize) layoutPrepare:(CGSize) regulatingCellSize {
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        _cachedSize.setEmpty();
        return CGSizeZero;
    }

    MICSize regSize([self sizeWithoutMargin:regulatingCellSize]);

    if(self.needsLayoutChildren) {
        let content = self.contentCell;
        if(nil!=content) {
            MICSize contentSize(regSize);
            if((_scrollOrientation&WPLScrollOrientationHORZ)!=0) {
                contentSize.width = 0;
            }
            if((_scrollOrientation&WPLScrollOrientationVERT)!=0) {
                contentSize.height = 0;
            }
            _cachedContentSize = [content layoutPrepare:contentSize];
        }
        self.needsLayoutChildren = false;
    }
    
    _cachedSize = MICSize( (self.requestViewSize.width > 0) ? self.requestViewSize.width  : regSize.width,
                           (self.requestViewSize.height> 0) ? self.requestViewSize.height : regSize.height );
    return [self sizeWithMargin:_cachedSize];
}

/**
 * レイアウトを確定する。
 * layoutPrepareが呼ばれた後に呼び出される。
 * @param finalCellRect     確定したセル領域（マージンを含む）
 *
 *  リサイズ＆配置ルール
 *      requestedViweSize       finalCellRect                 内部コンテンツ(view/cell)サイズ
 *      ○ 正値(fixed)                無視                       requestedViewSizeにリサイズし、alignmentに従ってfinalCellRect内に配置
 *        ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしないで、alignmentに従ってfinalCellRect内に配置
 *        負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない、alignmentに従ってfinalCellRect内に配置 (regulatingCellSize の stretch 指定は無視する)
 *        負値(stretch)            ○ 正値 (fixed)               finalCellSize にリサイズ（regulatingCellSize!=finalCellRect.sizeの場合は再計算）。alignmentは無視
 */
- (void) layoutCompleted:(CGRect) finalCellRect {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }

    MICRect finRect([self rectWithoutMargin:finalCellRect]);
    // layoutPrepareの計算結果とセルサイズが異なる場合、STRETCH 指定なら、与えられたサイズを使って配置を再計算する
    if (self.requestViewSize.width <0 /* stretch */ && finRect.size.width  != _cachedSize.width ) {
        _cachedSize.width = finRect.size.width;
    }
    if (self.requestViewSize.height<0 /* stretch */ && finRect.size.height != _cachedSize.height) {
        _cachedSize.height = finRect.size.height;
    }
    // [super layoutCompleted:] は、auto-sizing のときにview のサイズを配置計算に使用するので、ここでサイズを設定しておく
    if (MICSize(_cachedSize) != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    // contentSize
    let content = self.contentCell;
    if(content!=nil) {
        MICSize contentSize(_cachedContentSize);
        if(contentSize.width<_cachedSize.width || (_scrollOrientation&WPLScrollOrientationHORZ)==0) {
            contentSize.width = _cachedSize.width;
        }
        if(contentSize.height<_cachedSize.height || (_scrollOrientation&WPLScrollOrientationVERT)==0) {
            contentSize.height = _cachedSize.height;
        }
        [content layoutCompleted:MICRect(contentSize)];
        [(UIScrollView*)self.view setContentSize:contentSize];
    }
    [super layoutCompleted:finalCellRect];
}

- (CGSize)layout {
    NSAssert(false, @"really?");
    return CGSizeZero;
}

@end
