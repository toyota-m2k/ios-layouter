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
