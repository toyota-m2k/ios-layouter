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
#define WPLInternalScrollCellView UIScrollView
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
    if(nil==view) {
        view = [WPLInternalScrollCellView new];
    }
    if(![view isKindOfClass:UIScrollView.class]) {
        NSAssert1(false, @"internal view of ScrollCell must be an instance of UIScrollView", name);
    }
    
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
    return [[self alloc] initWithView:nil name:name params:params];
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

- (void)endRendering:(CGRect)finalCellRect {
    [self calcCellWidth:finalCellRect.size.width];
    [self calcCellHeight:finalCellRect.size.height];
    
    MICRect contentRect(_cachedContentSize);
    [self.contentCell endRendering:contentRect];
    [(UIScrollView*)self.view setContentSize:_cachedContentSize];
    [super endRendering:finalCellRect];
}

@end
