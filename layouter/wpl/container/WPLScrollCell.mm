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
    bool _cacheVert;
    bool _cacheHorz;
}

#pragma mark - 構築・初期化
/**
 * ScrollCell の正統なコンストラクタ
 */
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   limitWidth:(WPLMinMax) limitWidth
                  limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            scrollOrientation:(WPLScrollOrientation) scrollOrientation {
    if(![view isKindOfClass:UIScrollView.class]) {
        NSAssert1(false, @"internal view of ScrollCell must be an instance of UIScrollView", name);
    }
//    if(requestViewSize.height == VAUTO && (scrollOrientation&WPLScrollOrientationVERT)!=0) {
//        NSLog(@"WARNING: AUTO-sizing to height of vertical scrollable ScrollCell (%@) is not allowd, assume it as STRETCH.", name);
//        requestViewSize.height = VSTRC;
//    }
//    if(requestViewSize.width == VAUTO && (scrollOrientation&WPLScrollOrientationHORZ)!=0) {
//        NSLog(@"WARNING: AUTO-sizing to width of horizontal scrollable ScrollCell (%@) is not allowd, assume it as STRETCH.", name);
//        requestViewSize.width = VSTRC;
//    }
    
    self = [super initWithView:view
                          name:name
                        margin:margin
               requestViewSize:requestViewSize
                    limitWidth:limitWidth
                   limitHeight:limitHeight
                    hAlignment:hAlignment
                    vAlignment:vAlignment
                    visibility:visibility];
    if(nil!=self) {
        _scrollOrientation = scrollOrientation;
        _cacheHorz = _cacheVert = false;
    }
    return self;
}

/**
 * newCellWithView で呼び出されたときに備えて WPLCell#initWithView をオーバーライドしておく。
 */
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   limitWidth:(WPLMinMax) limitWidth
                  limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility  {
    return [self initWithView:view
                         name:name
                       margin:margin
              requestViewSize:requestViewSize
                   limitWidth:limitWidth
                  limitHeight:limitHeight
                   hAlignment:hAlignment
                   vAlignment:vAlignment
                   visibility:visibility
            scrollOrientation:WPLScrollOrientationBOTH];
}

- (instancetype) initWithView:(UIView *)view
                         name:(NSString *)name
                       params:(const WPLScrollCellParams&)params {
    return [self initWithView:view
                         name:name
                       margin:params._margin
              requestViewSize:params._requestViewSize
                   limitWidth:params._limitWidth
                  limitHeight:params._limitHeight
                   hAlignment:params._align.horz
                   vAlignment:params._align.vert
                   visibility:params._visibility
            scrollOrientation:params._scrollOrientation];
}

/**
 * C++版インスタンス生成ヘルパー
 */
+ (instancetype) scrollCellWithName:(NSString*) name
                             params:(const WPLScrollCellParams&)params {
    return [[self alloc] initWithView:[[WPLInternalScrollCellView alloc] init] name:name params:params];
}

+ (instancetype) scrollCellWithName:(UIView*)view
                               name:(NSString*) name
                             params:(const WPLScrollCellParams&)params {
    return [[self alloc] initWithView:view name:name params:params];
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
 *
 *    セルサイズ決定の優先順位
 *    　子セルの指定            親コンテナからの指定
 *      requestedViweSize       regulatingCellSize          内部コンテンツ(view/cell)サイズ
 *      -------------------     -------------------         -----------------------------------
 *      ○ 正値(fixed)                 無視                      requestedViewSizeにリサイズ
 *         ゼロ(auto)                  無視                   ○ 元のサイズのままリサイズしない
 *         負値(stretch)               ゼロ (auto)            ○ 元のサイズのままリサイズしない
 *         負値(stretch)            ○ 正値 (fixed)              regulatingCellSize にリサイズ
 * @return  セルサイズ（マージンを含む
 */
- (CGSize) layoutPrepare:(CGSize) regulatingCellSize {
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        self.needsLayout = false;
        _cachedSize.setEmpty();
        return CGSizeZero;
    }

    if(self.needsLayoutChildren) {
        MICSize innerSize([self limitRegulatingSize:[self sizeWithoutMargin:regulatingCellSize]]);
        let content = self.contentCell;
        if(nil!=content) {
            MICSize contentSize(innerSize);
            if((_scrollOrientation&WPLScrollOrientationHORZ)!=0) {  // 横スクロール可
                contentSize.width = 0;
            }
            if((_scrollOrientation&WPLScrollOrientationVERT)!=0) {  // 縦スクロール可
                contentSize.height = 0;
            }
            _cachedContentSize = [content layoutPrepare:contentSize];
        }
        _cachedSize = MICSize( (self.requestViewSize.width > 0) ? self.requestViewSize.width  : innerSize.width,
                               (self.requestViewSize.height> 0) ? self.requestViewSize.height : innerSize.height );
        self.needsLayoutChildren = false;
    }
    return [self sizeWithMargin:[self limitSize:_cachedSize]];
}

/**
 * レイアウトを確定する。
 * layoutPrepareが呼ばれた後に呼び出される。
 * @param finalCellRect     確定したセル領域（マージンを含む）
 *
 *  リサイズ＆配置ルール
 *      requestedViweSize       finalCellRect                 内部コンテンツ(view/cell)サイズ
 *      -------------------     -------------------           -----------------------------------
 *      ○ 正値(fixed)                無視                        requestedViewSizeにリサイズし、alignmentに従ってfinalCellRect内に配置
 *         ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしないで、alignmentに従ってfinalCellRect内に配置
 *         負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない、alignmentに従ってfinalCellRect内に配置 (regulatingCellSize の stretch 指定は無視する)
 *         負値(stretch)           ○ 正値 (fixed)                finalCellSize にリサイズ（regulatingCellSize!=finalCellRect.sizeの場合は再計算）。alignmentは無視
 */
- (void) layoutCompleted:(CGRect) finalCellRect {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }

    MICRect finRect([self rectWithoutMargin:finalCellRect]);
    // layoutPrepareの計算結果とセルサイズが異なる場合、STRETCH 指定なら、与えられたサイズを使って配置を再計算する
    if (self.requestViewSize.width <=0 /* stretch|auto */ && finRect.size.width  != _cachedSize.width ) {
        _cachedSize.width = finRect.size.width;
    }
    if (self.requestViewSize.height<=0 /* stretch|auto */ && finRect.size.height != _cachedSize.height ) {
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

@implementation WPLScrollCell (WHRendering)

class SCAccessor {
private:
    bool horz;
public:
    CGFloat cellSize;
    CGFloat contentSize;
    
    enum Orientation {
        HORZ, VERT,
    };
    SCAccessor(Orientation o)
    : horz(o==HORZ)
    , cellSize(0)
    , contentSize(0){}

    CGFloat requestedSize(id<IWPLCell>cell) {
        return horz ? cell.requestViewSize.width : cell.requestViewSize.height;
    }
    CGFloat isScrollable(WPLScrollCell* cell) {
        let mask = horz ?WPLScrollOrientationHORZ : WPLScrollOrientationVERT;
        return (cell.scrollOrientation & mask) !=0;
    }
    CGFloat calcSize(id<IWPLCell> cell, CGFloat regulatingSize) {
        return horz ? [cell calcCellWidth:regulatingSize] : [cell calcCellHeight:regulatingSize];
    }
    
};

- (void)beginRendering:(WPLRenderingMode)mode {
    if(self.needsLayoutChildren || mode!=WPLRenderingNORMAL) {
        _cacheHorz = false;
        _cacheVert = false;
    }
    [super beginRendering:mode];
}

- (CGFloat)calcCellWidth:(CGFloat)regulatingWidth {
    if(!_cacheHorz) {
        SCAccessor acc(SCAccessor::HORZ);
        [self calcCellSize:regulatingWidth-MICEdgeInsets::dw(self.margin) acc:acc];
        _cachedSize.width = acc.cellSize;
        _cachedContentSize.width = acc.contentSize;
        _cacheHorz = true;
    }
    // 最小・最大サイズでクリップして、マージンを追加
    return WPLCMinMax(self.limitWidth).clip(_cachedSize.width) + MICEdgeInsets::dw(self.margin);
}

- (CGFloat)calcCellHeight:(CGFloat)regulatingHeight {
    if(!_cacheVert) {
        SCAccessor acc(SCAccessor::VERT);
        [self calcCellSize:regulatingHeight-MICEdgeInsets::dh(self.margin) acc:acc];
        _cachedSize.height = acc.cellSize;
        _cachedContentSize.height = acc.contentSize;
        _cacheVert = true;
    }
    // 最小・最大サイズでクリップして、マージンを追加
    return WPLCMinMax(self.limitHeight).clip(_cachedSize.height) + MICEdgeInsets::dh(self.margin);
}

- (CGFloat)recalcCellWidth:(CGFloat)regulatingWidth {
    _cacheHorz = false;
    return [self calcCellWidth:regulatingWidth];
}

- (CGFloat)recalcCellHeight:(CGFloat)regulatingHeight {
    _cacheVert = false;
    return [self calcCellHeight:regulatingHeight];
}

/**
 * ビューサイズ（マージンを含まない）を計算
 */
- (void)calcCellSize:(CGFloat) regulatingSize    // マージンを含まない
                 acc:(SCAccessor&) acc {
    acc.cellSize = 0;
    let requestedSize = acc.requestedSize(self);
    if(requestedSize>0) {
        // Any > FIXED
        // Independent | BottomUp
        acc.cellSize = requestedSize;
    }
    if(requestedSize<0 && regulatingSize>0) {
        // STRC|FIXED > STRC
        acc.cellSize = regulatingSize;
    }

    // Content Size
    acc.contentSize = acc.calcSize(self.contentCell, acc.isScrollable(self) ? 0/*AUTO*/ : acc.cellSize);
    if(acc.cellSize==0 /*auto*/) {
        acc.cellSize = acc.contentSize;
    } else {
        if(acc.contentSize<acc.cellSize || !acc.isScrollable(self)) {
            acc.contentSize = acc.cellSize;
        }
    }
}

- (void)endRenderingInRect:(CGRect)finalCellRect {
    [self calcCellWidth:finalCellRect.size.width];
    [self calcCellHeight:finalCellRect.size.height];
    
    MICRect contentRect(_cachedContentSize);
    [self.contentCell endRenderingInRect:contentRect];
    [(UIScrollView*)self.view setContentSize:_cachedContentSize];
    [super endRenderingInRect:finalCellRect];
}

@end
