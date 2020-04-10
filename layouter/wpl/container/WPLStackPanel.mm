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
//#import <vector>

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

// inner class
@interface WPLStackPanelExtension : NSObject
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint point;
@property (nonatomic,readonly) CGRect rect;
@end

@implementation WPLStackPanelExtension
- (instancetype) init {
    self = [super init];
    if(nil!=self) {
        _width = 0;
        _height = 0;
        _x = 0;
        _y = 0;
    }
    return self;
}

- (CGSize)size {
    return MICSize(_width, _height);
}
- (void) setSize:(CGSize)size {
    _width = size.width;
    _height = size.height;
}

- (CGPoint)point {
    return MICPoint(_x, _y);
}
- (void)setPoint:(CGPoint)point {
    _x = point.x;
    _y = point.y;
}

- (CGRect) rect {
    return MICRect::XYWH(_x, _y, _width, _height);
}

@end


static inline WPLStackPanelExtension* EXT(id<IWPLCell> cell) {  return (WPLStackPanelExtension*)cell.extension; }

// Orientation == VERTICAL を基準に、
// Horizontal なら、width/height を入れ替えて返す
static inline CGFloat W(WPLStackPanel* me, const CGSize& size) {
    return me.orientation==WPLOrientationVERTICAL ? size.width : size.height;
}

static inline void W(WPLStackPanel* me, CGSize& size, CGFloat w) {
    if(me.orientation==WPLOrientationVERTICAL) { size.width=w; } else { size.height=w; }
}

static inline CGFloat H(WPLStackPanel* me, const CGSize& size) {
    return me.orientation==WPLOrientationVERTICAL ? size.height : size.width;
}

static inline void H(WPLStackPanel* me, CGSize& size, CGFloat h) {
    if(me.orientation==WPLOrientationVERTICAL) { size.height=h; } else { size.width=h; }
}

static inline void X(WPLStackPanel* me, CGPoint& point, CGFloat v) {
    if(me.orientation==WPLOrientationVERTICAL) { point.x = v; } else { point.y = v; }
}
static inline void Y(WPLStackPanel* me, CGPoint& point, CGFloat v) {
    if(me.orientation==WPLOrientationVERTICAL) { point.y = v; } else { point.x = v; }
}

/**
 * StackPanel セル-コンテナ クラス
 */
@implementation WPLStackPanel {
    WPLOrientation _orientation;
    CGFloat _cellSpacing;
    CGSize _cachedSize;
    
    bool _cacheHorz;
    bool _cacheVert;
    
//    std::vector<CGFloat> _growing_side_cell_size;
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

- (void) setCachedSize:(CGSize)cachedSize {
    _cachedSize = cachedSize;
}
- (CGSize) cachedSize {
    return _cachedSize;
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
    cell.extension = [[WPLStackPanelExtension alloc] init];
    [super addCell:cell];
}

/**
 * レイアウト計算　＆　セルの配置
 */
- (void) innerLayout:(CGFloat) fix {
    NSAssert(fix>=0,@"StackLayout.innerLayout: fix < 0");
    CGFloat max = fix;
    CGFloat sum = 0;
    for (id<IWPLCell> c in self.cells) {
        if(c.visibility==WPLVisibilityCOLLAPSED) {
            continue;
        }
        MICSize regSize( (self.orientation==WPLOrientationVERTICAL) ? fix : 0,
                         (self.orientation==WPLOrientationVERTICAL) ? 0 : fix  );
        CGSize size = [c layoutPrepare:regSize];
        if (fix == 0) {
            max = MAX(max, W(self, size));
        }
        MICPoint epoint(EXT(c).point);
        MICSize esize(EXT(c).size);
        X(self, epoint, 0);
        Y(self, epoint, sum);
        H(self, esize, H(self,size));
        EXT(c).point = epoint;
        EXT(c).size = esize;
        sum += (H(self, size)+_cellSpacing);
    }
    
    for (id<IWPLCell> c in self.cells) {
        MICSize esize(EXT(c).size);
        W(self, esize, max);
        EXT(c).size = esize;
        [c layoutCompleted:MICRect(EXT(c).point, EXT(c).size)];
    }
    
    W(self, _cachedSize, max);
    H(self, _cachedSize, sum==0 ? 0 : sum-_cellSpacing);
    self.needsLayoutChildren = false;
}

/**
 * レイアウトを開始する
 *
 * レイアウト計算　＆　セルの配置　＋　Viewサイズを更新
 */
- (CGSize) layout {
    if(self.needsLayoutChildren) {
        let fix = MAX(self.fixedSize, 0);   // innerLayout:に負値は渡さないようにする。
        [self innerLayout:fix];
    }
    // Viweの位置はそのままで、サイズだけ変更する
    if (MICSize(_cachedSize) != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    self.needsLayout = false;
    return MICSize(_cachedSize) + self.margin;
}

/**
 * レイアウト準備（仮配置）
 * セル内部の配置を計算し、セルサイズを返す。
 * このあと、親コンテナセルでレイアウトが確定すると、layoutCompleted: が呼び出されるので、そのときに、内部の配置を行う。
 * @param regulatingCellSize    stretch指定のセルサイズを決めるためのヒント
 *    セルサイズ決定の優先順位
 *      requestedViweSize       regulatingCellSize             内部コンテンツ(view/cell)サイズ
 *      -------------------     -------------------            -----------------------------------
 *      ○ 正値(fixed)                 無視                        requestedViewSizeにリサイズ
 *         ゼロ(auto)                  無視                     ○ 元のサイズのままリサイズしない
 *         負値(stretch)               ゼロ (auto)              ○ 元のサイズのままリサイズしない (regulatingCellSize の stretch 指定は無視する)
 *         負値(stretch)            ○ 正値 (fixed)                regulatingCellSize にリサイズ
 * @return セルサイズ（マージンを含む
 */
- (CGSize) layoutPrepare:(CGSize) regulatingCellSize {
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        self.needsLayout = false;
        _cachedSize = CGSizeZero;
        return CGSizeZero;
    }
    MICSize regSize([self limitRegulatingSize:[self sizeWithoutMargin:regulatingCellSize]]);
    if(self.needsLayoutChildren) {
        CGFloat req = W(self, self.requestViewSize);
        CGFloat fix = (req>=0) ? req : W(self, regSize);
        [self innerLayout:fix];
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
    if(self.fixedSize<0 /* stretch */ && W(self, finRect.size)!=W(self, _cachedSize)) {
        // Stretching
        [self innerLayout:W(self,finRect.size)];
    }
    // [super layoutCompleted:] は、auto-sizing のときにview のサイズを配置計算に使用するので、ここでサイズを設定しておく
    if (MICSize(_cachedSize) != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    [super layoutCompleted:finalCellRect];
}

@end

@implementation WPLStackPanel (WHRendering)

- (void)beginRendering:(WPLRenderingMode)mode {
    if(self.needsLayoutChildren || mode!=WPLRenderingNORMAL) {
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
- (void)endRenderingInRect:(CGRect) finalCellRect {
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
                    [cell endRenderingInRect:cellRect];
                    offset += cellSize.height;
                } else {
                    cellRect = MICRect(MICPoint(panelRect.left()+offset,panelRect.top()), MICSize(cellSize.width, panelRect.height()));
                    [cell endRenderingInRect:cellRect];
                    offset += cellSize.width;
                }
                offset += _cellSpacing;
            } else {
                // Collapsedの場合にもendRenderingInRectは呼ぶ必要がある
                [cell endRenderingInRect:MICRect::zero()];
            }
        }
    }
    [super endRenderingInRect:finalCellRect];
}

//- (void) alignCell:(id<IWPLCell>)cell offset:(CGFloat)offset size:(CGFloat)size panelRect:(const MICRect&)panelRect {
//    MICRect rc;
//    if(self.orientation==WPLOrientationVERTICAL) {
//        rc = MICRect::XYWH(panelRect.left(), panelRect.top()+offset, panelRect.width(), size);
//    } else {
//        rc = MICRect::XYWH(panelRect.left()+offset, panelRect.top(), size, panelRect.height());
//    }
//    [cell endRenderingInRect:rc];
//}

@end
