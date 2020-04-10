//
//  WPLFrame.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/08.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLFrame.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

#ifdef DEBUG
@interface WPLInternalFrameView : UIView
@end
@implementation WPLInternalFrameView
@end
#else
#define WPLInternalFrameView UIView
#endif

@implementation WPLFrame {
    MICSize _cachedSize;
    bool _cacheHorz;
    bool _cacheVert;
}

- (instancetype)initWithView:(UIView *)view name:(NSString *)name margin:(UIEdgeInsets)margin requestViewSize:(CGSize)requestViewSize limitWidth:(WPLMinMax)limitWidth limitHeight:(WPLMinMax)limitHeight hAlignment:(WPLCellAlignment)hAlignment vAlignment:(WPLCellAlignment)vAlignment visibility:(WPLVisibility)visibility {
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize limitWidth:limitWidth limitHeight:limitHeight hAlignment:hAlignment vAlignment:vAlignment visibility:visibility];
    if(nil!=self) {
        _cacheVert = false;
        _cacheHorz = false;
    }
    return self;
}


- (instancetype)initWithView:(UIView *)view name:(NSString *)name params:(WPLCellParams)params {
    return [self initWithView:view
                         name:name
                       margin:params._margin
              requestViewSize:params._requestViewSize
                   limitWidth:params._limitWidth
                  limitHeight:params._limitHeight
                   hAlignment:params._align.horz
                   vAlignment:params._align.vert
                   visibility:params._visibility];
}

+ (instancetype) frameWithName:(NSString*)name
                        params:(WPLCellParams) params {
    return [self newCellWithView:[WPLInternalFrameView new] name:name params:params];
}

+ (instancetype) frameWithView:(UIView*)view
                        name:(NSString*)name
                        params:(WPLCellParams) params {
    return [self newCellWithView:view name:name params:params];
}

- (void) setCachedSize:(CGSize)cachedSize {
    _cachedSize = cachedSize;
}
- (CGSize) cachedSize {
    return _cachedSize;
}

/**
 * @param fixedSize コンテナセルに対して与えたサイズ（もし、これが実際のセルサイズより小さければ、alignにしたがってoffsetを調整する必要がある。
 */
- (void) alignContainerCell:(id<IWPLCell>)cell ofSize:(CGSize)size inSize:(CGSize)fixedSize {
    if(![cell conformsToProtocol:@protocol(IWPLContainerCell)]) {
        // コンテナのセルは、WPLCell.completeLayoutで正しくアラインされる
        return;
    }
    
    MICVector move;
    MICRect rc(cell.view.frame);
    if(cell.hAlignment!=WPLCellAlignmentSTART && size.width < fixedSize.width) {
        if(cell.hAlignment == WPLCellAlignmentCENTER) {
            move.dx = (fixedSize.width-size.width)/2;
        } else if (cell.hAlignment == WPLCellAlignmentEND) {
            move.dx = fixedSize.width-size.width;
        }
    }
    if(cell.vAlignment!=WPLCellAlignmentSTART && size.height < fixedSize.height) {
        if(cell.vAlignment == WPLCellAlignmentCENTER) {
            move.dy = (fixedSize.height-size.height)/2;
        } else if (cell.vAlignment == WPLCellAlignmentEND) {
            move.dy = fixedSize.height-size.height;
        }
    }
    if(!move.isZero()) {
        cell.view.frame = rc + move;
    }
}

/**
 * レイアウト内部処理
 * @param innerRegulatingSize   親コンテナによって要求されるセルサイズ（マージンを含まない＝ビューのサイズ）
 *                              負値(STRC)は入らず、STRCの場合は親コンテナのサイズが入っている。
 *                              親がAUTOの場合はゼロが入っている。
 */
- (void) innerLayout:(const MICSize&)innerRegulatingSize {
    // 子セルに渡すregulatingSize
    MICSize innerSize( (self.requestViewSize.width >= 0) ? self.requestViewSize.width  : innerRegulatingSize.width,
                       (self.requestViewSize.height>= 0) ? self.requestViewSize.height : innerRegulatingSize.height );
    MICSize calcedSize;
    for(id<IWPLCell>cell in self.cells) {
        MICSize size;
        if(cell.visibility!=WPLVisibilityCOLLAPSED) {
            size = [cell layoutPrepare:innerSize];
            calcedSize.width = MAX(calcedSize.width, size.width);
            calcedSize.height = MAX(calcedSize.height, size.height);
        }
        [cell layoutCompleted:MICRect(size)];
    }
    // _cachedSize: このセルのサイズ（マージンを含まない）
    // 親：STRC/FIXED > 子:STRC の場合のみTopDown --> innerRegulatingSize
    // それ以外は、BottomUp --> calcedSize
    _cachedSize = MICSize( (innerRegulatingSize.width  != 0 && self.requestViewSize.width  < 0 ) ? innerRegulatingSize.width  : calcedSize.width,
                           (innerRegulatingSize.height != 0 && self.requestViewSize.height < 0 ) ? innerRegulatingSize.height : calcedSize.height );
    self.needsLayoutChildren = false;
}

//- (void) innerLayout:(const MICSize&)fixedSize {
//    MICSize cellSize;
//    for(id<IWPLCell>cell in self.cells) {
//        MICSize size;
//        if(cell.visibility!=WPLVisibilityCOLLAPSED) {
//            size = [cell layoutPrepare:fixedSize];
//            cellSize.width = MAX(cellSize.width, size.width);
//            cellSize.height = MAX(cellSize.height, size.height);
//        }
//        [cell layoutCompleted:MICRect(size)];
//    }
//    // AUTOの場合はBottomUp --> 計算結果のセルサイズを返す
//    // 子がSTRCの場合はTopDown --> fixedSizeを返す。
//
//    _cachedSize = MICSize( fixedSize.width==0  ? cellSize.width  : fixedSize.width,
//                           fixedSize.height==0 ? cellSize.height : fixedSize.height);
//    self.needsLayoutChildren = false;
//}



/**
 * サイズに負値が入らないようにして返す
 */
static inline MICSize positiveSize(const CGSize& size) {
    return MICSize(MAX(size.width, 0), MAX(size.height,0));
}

- (CGSize)layout {
    if(self.needsLayoutChildren) {
        [self innerLayout:positiveSize(self.requestViewSize)];
    }
    // Viweの位置はそのままで、サイズだけ変更する
    if (MICSize(_cachedSize) != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    self.needsLayout = false;
    return _cachedSize+self.margin;
}

/**
 * レイアウト準備（仮配置）
 * セル内部の配置を計算し、セルサイズを返す。
 * このあと、親コンテナセルでレイアウトが確定すると、layoutCompleted: が呼び出されるので、そのときに、内部の配置を行う。
 *
 * @param regulatingCellSize    stretch指定のセルサイズを決めるためのヒント
 *                              通常、親コンテナ（またはグリッドセル）のサイズが入っている（STRC=トップダウンor FIXEDによるレイアウト用）
 *                              親コンテナ（またはグリッドセル）がAUTO の場合はゼロが入っている。
 *                              負値は入らない。
 *
 *
 *    セルサイズ決定の優先順位
 *    　子セルの指定            親コンテナからの指定
 *      requestedViweSize       regulatingCellSize          内部コンテンツ(view/cell)サイズ
 *      -------------------     -------------------         -----------------------------------
 *      ○ 正値(fixed)                 無視                      requestedViewSizeにリサイズ
 *         ゼロ(auto)                  無視                   ○ 元のサイズのままリサイズしない
 *         負値(stretch)               ゼロ (auto)            ○ 元のサイズのままリサイズしない
 *         負値(stretch)            ○ 正値 (fixed)              regulatingCellSize にリサイズ
 *
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
        [self innerLayout:positiveSize(innerSize)];
    }
    return [self sizeWithMargin:[self limitSize:_cachedSize]];
}

//- (CGSize) layoutPrepare:(CGSize) regulatingCellSize {
//    if(self.visibility==WPLVisibilityCOLLAPSED) {
//        _cachedSize.setEmpty();
//        return CGSizeZero;
//    }
//
//    MICSize regSize([self limitRegulatingSize:[self sizeWithoutMargin:regulatingCellSize]]);
//    if(self.needsLayoutChildren) {
//        MICSize fixSize( (self.requestViewSize.width >= 0) ? self.requestViewSize.width  : regSize.width,
//                         (self.requestViewSize.height>= 0) ? self.requestViewSize.height : regSize.height );
//        [self innerLayout:positiveSize(fixSize)];
//    }
//    return [self sizeWithMargin:[self limitSize:_cachedSize]];
//}


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
    MICSize viewSize([self limitRegulatingSize:[self sizeWithoutMargin:finalCellRect.size]]);
    if(  (viewSize.width  != _cachedSize.width  && self.requestViewSize.width < 0 /* stretch */)
       ||(viewSize.height != _cachedSize.height && self.requestViewSize.height < 0 /* stretch */) ) {
        // STRETCH の場合に、与えられたサイズを使って配置を再計算する
        [self innerLayout:viewSize];
    }
    // [super layoutCompleted:] は、auto-sizing のときにview のサイズを配置計算に使用するので、ここでサイズを設定しておく
    if (_cachedSize != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    [super layoutCompleted:finalCellRect];
}

@end

@implementation WPLFrame (WHRendering)

- (void)beginRendering:(WPLRenderingMode)mode {
    if(self.needsLayoutChildren || mode!=WPLRenderingNORMAL) {
        _cacheHorz = false;
        _cacheVert = false;
    }
    [super beginRendering:mode];
}

//typedef CGFloat (^GetCellSizeProc)(id<IWPLCell> cell, CGFloat regulatingSize);

class FRAccessor {
public:
    enum Orientation { HORZ, VERT };
    Orientation orientation;
    
    FRAccessor(Orientation orientation_) {
        orientation = orientation_;
    }
    
    CGFloat calcSize(id<IWPLCell>cell, CGFloat regulatingSize) {
        if(orientation==HORZ) {
            return [cell calcCellWidth:regulatingSize];
        } else {
            return [cell calcCellHeight:regulatingSize];
        }
    }
    
    CGFloat requestedSize(id<IWPLCell> cell) {
        if(orientation==HORZ) {
            return cell.requestViewSize.width;
        } else {
            return cell.requestViewSize.height;
        }
    }
    
};

/**
 * ビューサイズ（マージンを含まない）を計算
 */
- (CGFloat)calcCellSize:(CGFloat) regulatingSize    // マージンを含まない
                    acc:(FRAccessor&)acc {
    let requestedSize = acc.requestedSize(self);
    CGFloat fixedSize = 0;
    if(requestedSize>0) {
        // Any > FIXED
        // Independent | BottomUp
        fixedSize = requestedSize;
    }
    if(requestedSize<0 && regulatingSize>0) {
        // STRC|FIXED > STRC
        fixedSize =  regulatingSize;
    }

    if(fixedSize>0) {
        // FIXED|STRC
        for(id<IWPLCell>cell in self.cells) {
            acc.calcSize(cell, fixedSize);
        }
        return fixedSize;
    } else {
        // AUTO sizing
        CGFloat size = 0;
        int stretchCount = 0;
        for(id<IWPLCell>cell in self.cells) {
            if(acc.requestedSize(cell)<0) {
                // STRC cell
                if(fixedSize>0) {
                    // FIXED|STRC > STRC
                    acc.calcSize(cell, fixedSize);
                } else {
                    // AUTO > STRC ... 他のサイズが決まるまで保留
                    stretchCount++;
                }
            } else {
                // ANY > FIXED|AUTO
                size = MAX(size, acc.calcSize(cell,regulatingSize));
            }
        }
        if(stretchCount>0) {
            // AUTO > STRC
            // 1) size >0: STRCでないセルによってサイズが確定できた --> STRCなセルはそのサイズに合わせる
            // 2) size==0: すべてがSTRC --> AUTOとしてレイアウト（sizeを更新）
            CGFloat size2 = 0;  // 2)のケースのsize更新用
            for(id<IWPLCell>cell in self.cells) {
                if(acc.requestedSize(cell)<0) {
                    size2 = MAX(size2, acc.calcSize(cell, size));
                }
            }
            if(size==0) {
                size = size2;
            }
        }
        return size;
    }
}


- (CGFloat) calcCellWidth:(CGFloat)regulatingWidth {
    if(!_cacheHorz) {
        FRAccessor acc(FRAccessor::HORZ);
        _cachedSize.width = [self calcCellSize:regulatingWidth - MICEdgeInsets::dw(self.margin) acc:acc];
        _cacheHorz = true;
    }
    // 最小・最大サイズでクリップして、マージンを追加
    return WPLCMinMax(self.limitWidth).clip(_cachedSize.width) + MICEdgeInsets::dw(self.margin);
}

- (CGFloat) calcCellHeight:(CGFloat)regulatingHeight {
    if(!_cacheVert) {
        FRAccessor acc(FRAccessor::VERT);
        _cachedSize.height = [self calcCellSize:regulatingHeight - MICEdgeInsets::dh(self.margin) acc:acc];
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


- (void)endRenderingInRect:(CGRect)finalCellRect {
    if(self.visibility!=WPLVisibilityCOLLAPSED) {
        MICRect panelRect([self calcCellWidth:0]-MICEdgeInsets::dw(self.margin), [self calcCellHeight:0]-MICEdgeInsets::dh(self.margin));
        for(id<IWPLCell> cell in self.cells) {
            [cell endRenderingInRect:panelRect];
        }
    }
    [super endRenderingInRect:finalCellRect];
}


@end
