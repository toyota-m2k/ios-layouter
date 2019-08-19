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

/**
 * StackPanel セル-コンテナ クラス
 */

// inner class
@interface WPLStackPanelExtension : NSObject
@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint point;
@end

@implementation WPLStackPanelExtension
- (instancetype) init {
    self = [super init];
    if(nil!=self) {
        _size = MICSize();
        _point = MICPoint();
    }
    return self;
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
}

/**
 * newCellWithView で呼び出されたときに備えて WPLCell#initWithView をオーバーライドしておく。
 */
- (instancetype) initWithView:(UIView *)view name:(NSString *)name margin:(UIEdgeInsets)margin requestViewSize:(CGSize)requestViewSize hAlignment:(WPLCellAlignment)hAlignment vAlignment:(WPLCellAlignment)vAlignment visibility:(WPLVisibility)visibility containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    return [self initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate orientation:(WPLOrientationVERTICAL) cellSpacing:0];
}

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
                  orientation:(WPLOrientation) orientation
                  cellSpacing:(CGFloat)cellSpacing {
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
    if(nil!=self) {
        _orientation = orientation;
        _cellSpacing = cellSpacing;
        _cachedSize = MICSize();
    }
    return self;
}

/**
 * インスタンス生成ヘルパー
 * StackPanel用のUIViewは、自動的に作成され、superviewにaddSubviewされる。
 */
+ (instancetype) stackPanelWithName:(NSString*) name
                             margin:(UIEdgeInsets) margin
                    requestViewSize:(CGSize) requestViewSize
                         hAlignment:(WPLCellAlignment)hAlignment
                         vAlignment:(WPLCellAlignment)vAlignment
                         visibility:(WPLVisibility)visibility
                  containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                        orientation:(WPLOrientation) orientation
                        cellSpacing:(CGFloat)cellSpacing
                          superview:(UIView*)superview {
    let view = [UIView new];
    if(nil!=superview) {
        [superview addSubview:view];
    }
    return [[WPLStackPanel alloc] initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment: hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate orientation:orientation cellSpacing:cellSpacing];
}

/**
 * C++版インスタンス生成ヘルパー
 */
+ (instancetype) stackPanelWithName:(NSString*) name
                             params:(const WPLStackPanelParams&)params
                            superview:(UIView*)superview
                    containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {

    return [self stackPanelWithName:name margin:params._margin requestViewSize:params._requestViewSize hAlignment:params._align.horz vAlignment:params._align.vert visibility:params._visibility containerDelegate:containerDelegate orientation:params._orientation cellSpacing:params._cellSpacing superview:superview];
}

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) stackPanelWithName:(NSString*) name
                             params:(const WPLStackPanelParams&)params {
    return [self stackPanelWithName:name params:params superview:nil containerDelegate:nil];
}

//+ (instancetype)stackPanelViewWithName:(NSString*) name
//                           orientation:(WPLOrientation)orientation
//                             xalignment:(WPLCellAlignment)xalignment
//                     containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
//    let hAlignment = (orientation==WPLOrientationVERTICAL) ? xalignment : WPLCellAlignmentSTART;
//    let vAlignment = (orientation==WPLOrientationVERTICAL) ? WPLCellAlignmentSTART : xalignment;
//    return [self stackPanelViewWithName:name margin:MICEdgeInsets() requestViewSize:MICSize() hAlignment:hAlignment vAlignment:vAlignment visibility:WPLVisibilityVISIBLE containerDelegate:containerDelegate orientation:orientation];
//}


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
 *      requestedViweSize       regulatingCellSize          内部コンテンツ(view/cell)サイズ
 *      ○ 正値(fixed)                無視                       requestedViewSizeにリサイズ
 *        ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしない
 *        負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない (regulatingCellSize の stretch 指定は無視する)
 *        負値(stretch)            ○ 正値 (fixed)               regulatingCellSize にリサイズ
 * @return  セルサイズ（マージンを含む
 */
- (CGSize) layoutPrepare:(CGSize) regulatingCellSize {
    MICSize regSize([self sizeWithoutMargin:regulatingCellSize]);
    if(self.needsLayoutChildren) {
        CGFloat req = W(self, self.requestViewSize);
        CGFloat fix = (req>=0) ? req : W(self, regSize);
        [self innerLayout:fix];
    }
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
