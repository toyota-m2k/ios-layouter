//
//  WPLStackPanel.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/03.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLStackPanel.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"

#ifdef DEBUG
@interface WPLInternalStackPanelView : UIView
@end
@implementation WPLInternalStackPanelView
@end
#else
#define WPLInternalStackPanelView UIView
#endif

/**
 * StackPanel セル-コンテナ クラス
 */
@implementation WPLStackPanel {
    WPLOrientation _orientation;
    CGFloat _cellSpacing;
    
    MICSize _cachedSize;
    bool _cacheHorz;
    bool _cacheVert;
}

/**
 * StackPanel の正統なコンストラクタ
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
                  orientation:(WPLOrientation) orientation
                  cellSpacing:(CGFloat)cellSpacing {
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
        _orientation = orientation;
        _cellSpacing = cellSpacing;
        _cachedSize = MICSize();
        
        _cacheHorz = false;
        _cacheVert = false;
    }
    return self;
}

/**
 * newCellWithView で呼び出されたときに備えて WPLCell#initWithView をオーバーライドしておく。
 */
- (instancetype) initWithView:(UIView *)view
                         name:(NSString *)name
                       margin:(UIEdgeInsets)margin
              requestViewSize:(CGSize)requestViewSize
                   limitWidth:(WPLMinMax) limitWidth
                  limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility {
    NSAssert(false, @"WPLStackPanel.newCellWithView is not recommended.");
    return [self initWithView:view
                         name:name
                       margin:margin
              requestViewSize:requestViewSize
                   limitWidth:limitWidth
                  limitHeight:limitHeight
                   hAlignment:hAlignment
                   vAlignment:vAlignment
                   visibility:visibility
                  orientation:WPLOrientationVERTICAL
                  cellSpacing:0];
}

/**
 * C++用コンストラクタ
 */
- (instancetype) initWithView:(UIView *)view
                         name:(NSString *)name
                       params:(const WPLStackPanelParams&)params {
    return [self initWithView:view
                         name:name
                       margin:params._margin
              requestViewSize:params._requestViewSize
                   limitWidth:params._limitWidth
                  limitHeight:params._limitHeight
                   hAlignment:params._align.horz
                   vAlignment:params._align.vert
                   visibility:params._visibility
                  orientation:params._orientation
                  cellSpacing:params._cellSpacing];
}

/**
 * C++版インスタンス生成ヘルパー
 */
+ (instancetype) stackPanelWithName:(NSString*) name
                             params:(const WPLStackPanelParams&)params {
    return [[self alloc] initWithView:[WPLInternalStackPanelView new] name:name params:params];
}

/**
 * C++版インスタンス生成ヘルパー
 */
+ (instancetype) stackPanelWithView:(UIView*)view
                               name:(NSString*) name
                             params:(const WPLStackPanelParams&)params {
    return [[self alloc] initWithView:view name:name params:params];
}

- (WPLOrientation) orientation {
    return _orientation;
}

- (void) setOrientation:(WPLOrientation)orientation {
    if(_orientation!=orientation) {
        _orientation = orientation;
        self.needsLayout = true;
    }
}

- (CGFloat) cellSpacing {
    return _cellSpacing;
}

- (void)setCellSpacing:(CGFloat)cellSpacing {
    if(_cellSpacing!=cellSpacing) {
        _cellSpacing = cellSpacing;
        self.needsLayout = true;
    }
}

// スタック伸長方向に垂直は方向のサイズ (Vertical --> Width, Horizontal --> Height)
// 0なら中身に合わせて伸縮する
- (CGFloat) fixedSize {
    return self.orientation==WPLOrientationVERTICAL ? self.requestViewSize.width : self.requestViewSize.height;
}

/**
 * セルを追加
 */
- (void) addCell:(id<IWPLCell>) cell {
//    cell.extension = [[WPLStackPanelExtension alloc] init];
    [super addCell:cell];
}

- (void)beginRendering:(WPLRenderingMode)mode {
    if(self.needsLayoutChildren || mode!=WPLRenderingNORMAL) {
        _cachedSize.setEmpty();
        _cacheHorz = false;
        _cacheVert = false;
    }
    [super beginRendering:mode];
}



/**
 * セル幅（マージンを含む）を計算
 */
- (CGFloat)calcCellWidth:(CGFloat)regulatingWidth {
    if(!_cacheHorz) {
        if(self.orientation == WPLOrientationVERTICAL) {
            // Fixed Side
            _cachedSize.width = [self calcFixedSide:MAX(0,regulatingWidth-MICEdgeInsets::dw(self.margin)) requestedSize:self.requestViewSize.width];
        } else {
            // Growing Side
            _cachedSize.width = [self calcGrowingSide];
        }
        _cacheHorz = true;
    }
    // 最小・最大サイズでクリップして、マージンを追加
    return WPLCMinMax(self.limitWidth).clip(_cachedSize.width) + MICEdgeInsets::dw(self.margin);
}

/**
 * セル高さ（マージンを含む）を計算
 */
- (CGFloat)calcCellHeight:(CGFloat)regulatingHeight {
    if(!_cacheVert) {
        if(self.orientation == WPLOrientationHORIZONTAL) {
            // Fixed Side
            _cachedSize.height =[self calcFixedSide:MAX(0,regulatingHeight-MICEdgeInsets::dh(self.margin)) requestedSize:self.requestViewSize.height];
        } else {
            // Growing Side
            _cachedSize.height = [self calcGrowingSide];
        }
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
 * 固定側のサイズ（マージンを含まない）を計算
 */
- (CGFloat) calcFixedSide:(CGFloat)regulatingSize
            requestedSize:(CGFloat)requestedSize {
    if(requestedSize>0 /*this.FIXED*/) {
        // BottomUp || Independent
        // 自身がFIXEDなら、そのサイズを採用
        return requestedSize;
    }
    if(requestedSize<0 && regulatingSize>0) {
        // TopDown
        // 自身がSTRCで親がAUTOでない --> 親のサイズを採用（ただし、marginを含むのでそれを除外する）
        return regulatingSize;
    }
    // Auto --> 子セルに委ねる
    CGFloat max = 0;
    for(id<IWPLCell>cell in self.cells) {
        if(cell.visibility!=WPLVisibilityCOLLAPSED) {
            CGFloat s;
            if(self.orientation == WPLOrientationVERTICAL) {
                s = [cell calcCellWidth:0/*AUTO*/];
            } else {
                s = [cell calcCellHeight:0/*AUTO*/];
            }
            max = MAX(max,s);
        }
    }
    return max;
}

/**
 * 伸長側のサイズ（マージンを含まない）を計算
 */
- (CGFloat) calcGrowingSide {
    CGFloat len = 0;
    for(id<IWPLCell>cell in self.cells) {
        if(cell.visibility!=WPLVisibilityCOLLAPSED) {
            CGFloat s;
            if(self.orientation == WPLOrientationVERTICAL) {
                s = [cell calcCellHeight:0/*AUTO*/];
            } else {
                s = [cell calcCellWidth:0/*AUTO*/];
            }
            len += s;
            len += _cellSpacing;
        }
    }
    if(len>0) {
        len -= _cellSpacing;
    }
    return len;
}

- (CGFloat) getFixedSideCell:(id<IWPLCell>)cell
              regulatingSize:(CGFloat)regulatingSize
               requestedSize:(CGFloat)requestedSize {
    if(requestedSize>0 /*this.FIXED*/) {
        // BottomUp || Independent
        // 自身がFIXEDなら、そのサイズを採用
        return requestedSize;
    }
    if(requestedSize<0 && regulatingSize>0) {
        // TopDown
        // 自身がSTRCで親がAUTOでない --> 親のサイズを採用（ただし、marginを含むのでそれを除外する）
        return regulatingSize;
    }
    if(self.orientation == WPLOrientationVERTICAL) {
        return [cell calcCellWidth:0/*AUTO*/];
    } else {
        return [cell calcCellHeight:0/*AUTO*/];
    }
}

- (CGFloat) getGrowingSideCell:(id<IWPLCell>)cell {
    if(self.orientation == WPLOrientationVERTICAL) {
        return [cell calcCellWidth:0/*AUTO*/];
    } else {
        return [cell calcCellHeight:0/*AUTO*/];
    }
}

/**
 * @param panelWidth     StackPanelのビューサイズ（マージンを含まない）
 */
- (CGFloat) getCell:(id<IWPLCell>) cell widthInPanelWidth:(CGFloat)panelWidth {
    if(self.orientation==WPLOrientationVERTICAL) {
        // Fixed Side
        CGFloat requestedSize = self.requestViewSize.width;
        if(requestedSize>0) {
            // FIXED
            return requestedSize;
        } else if(requestedSize<0) {
            // STRC
            return panelWidth;
        }
    }
    return [cell calcCellWidth:panelWidth];
}

- (CGFloat) getCell:(id<IWPLCell>) cell heightInPanelHeight:(CGFloat)panelHeight {
    if(self.orientation==WPLOrientationHORIZONTAL) {
        // Fixed Side
        CGFloat requestedSize = self.requestViewSize.height;
        if(requestedSize>0) {
            // FIXED
            return requestedSize;
        } else if(requestedSize<0) {
            // STRC
            return panelHeight;
        }
    }
    return [cell calcCellHeight:panelHeight];

}


/**
 * セルの位置、サイズを確定し、ビューを再配置する。
 * @param   finalCellRect  セルを配置可能な矩形領域（親ビュー座標系）
 */
- (void)endRendering:(CGRect) finalCellRect {
    if(self.visibility!=WPLVisibilityCOLLAPSED) {
        // StackPanelビュー座標系の領域（マージンを除く：origin=0,0）
        // パネルサイズ：regulatingSizeにはゼロ(auto)を渡して、このスタックパネルセルのサイズを取得
        // もし、親コンテナから特別な指定がある場合は、事前にcalcCellWidth/Heightが呼ばれ、結果がキャッシュされているはず。
        MICRect panelRect([self calcCellWidth:0], [self calcCellHeight:0]);
        int offset = 0;
        for(id<IWPLCell>cell in self.cells) {
            if(cell.visibility!=WPLVisibilityCOLLAPSED) {
                MICSize cellSize([self getCell:cell widthInPanelWidth:panelRect.width()], [self getCell:cell heightInPanelHeight:panelRect.height()]);
                MICRect cellRect;
                if(self.orientation == WPLOrientationVERTICAL) {
                    cellRect = MICRect(MICPoint(panelRect.left(),panelRect.top()+offset), MICSize(panelRect.width(), cellSize.height));
                    [cell endRendering:cellRect];
                    offset += cellSize.height;
                } else {
                    cellRect = MICRect(MICPoint(panelRect.left()+offset,panelRect.top()), MICSize(cellSize.width, panelRect.height()));
                    [cell endRendering:cellRect];
                    offset += cellSize.width;
                }
                offset += _cellSpacing;
            } else {
                // Collapsedの場合にもendRenderingは呼ぶ必要がある
                [cell endRendering:MICRect::zero()];
            }
        }
    }
    [super endRendering:finalCellRect];
}

@end
