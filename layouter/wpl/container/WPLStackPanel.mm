//
//  WPLStackPanel.m
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
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
    CGSize _cachedSize;
}

/**
 * newCellWithView で呼び出されたときに備えて WPLCell#initWithView をオーバーライドしておく。
 */
- (instancetype) initWithView:(UIView *)view name:(NSString *)name margin:(UIEdgeInsets)margin requestViewSize:(CGSize)requestViewSize hAlignment:(WPLCellAlignment)hAlignment vAlignment:(WPLCellAlignment)vAlignment visibility:(WPLVisibility)visibility containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    return [self initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate orientation:(WPLOrientationVERTICAL)];
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
                  orientation:(WPLOrientation) orientation {
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
    if(nil!=self) {
        _orientation = orientation;
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
                          superview:(UIView*)superview {
    let view = [UIView new];
    if(nil!=superview) {
        [superview addSubview:view];
    }
    return [[WPLStackPanel alloc] initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment: hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate orientation:orientation];
}

/**
 * C++版インスタンス生成ヘルパー
 */
+ (instancetype) stackPanelWithName:(NSString*) name
                             params:(const WPLStackPanelParams&)params
                            superview:(UIView*)superview
                    containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {

    return [self stackPanelWithName:name margin:params._margin requestViewSize:params._requestViewSize hAlignment:params._align.horz vAlignment:params._align.vert visibility:params._visibility containerDelegate:containerDelegate orientation:params._orientation superview:superview];
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
    CGFloat max = fix;
    CGFloat sum = 0;
    for (id<IWPLCell> c in self.cells) {
        if(c.visibility==WPLVisibilityCOLLAPSED) {
            continue;
        }
        CGFloat regWidth = (self.orientation==WPLOrientationVERTICAL) ? fix : 0;
        CGFloat regHeight = (self.orientation==WPLOrientationVERTICAL) ? 0 : fix;
        CGSize size = [c calcMinSizeForRegulatingWidth:regWidth andRegulatingHeight:regHeight];
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
        sum += H(self, size);
    }
    
    for (id<IWPLCell> c in self.cells) {
        MICSize esize(EXT(c).size);
        W(self, esize, max);
        EXT(c).size = esize;
        [c layoutResolvedAt:EXT(c).point inSize:EXT(c).size];
    }
    
    W(self, _cachedSize, max);
    H(self, _cachedSize, sum);
    self.needsLayoutChildren = false;
}

/**
 * レイアウトを開始する
 *
 * レイアウト計算　＆　セルの配置　＋　Viewサイズを更新
 */
- (CGSize) layout {
    if(self.needsLayoutChildren) {
        [self innerLayout:self.fixedSize];
    }
    // Viweの位置はそのままで、サイズだけ変更する
    if (MICSize(_cachedSize) != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    self.needsLayout = false;
    return MICSize(_cachedSize) + self.margin;
}

/**
 * サイズ計算
 * 伸長方向： セルサイズの合計 (requestViewSizeは無視）
 * 固定方向： requestViewSize 設定されていなければ、全セルの最大サイズ
 */
- (CGSize) calcMinSizeForRegulatingWidth:(CGFloat) regulatingWidth andRegulatingHeight:(CGFloat) regulatingHeight {
    if(self.needsLayoutChildren) {
        CGFloat fix = self.orientation==WPLOrientationVERTICAL ? regulatingWidth : regulatingHeight;
        [self innerLayout:fix];
    }
    return MICSize(_cachedSize) + self.margin;
}

/**
 * セルの位置・サイズ確定
 */
- (void) layoutResolvedAt:(CGPoint)point inSize:(CGSize)size {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }
    MICSize s(MICSize(size) - self.margin);
    let align = self.orientation==WPLOrientationVERTICAL ? self.hAlignment : self.vAlignment;
    if(align == WPLCellAlignmentSTRETCH && self.fixedSize==0 && W(self, s)!=W(self, _cachedSize)) {
        // Stretching
        [self innerLayout:W(self,s)];
    }
    if (MICSize(_cachedSize) != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    [super layoutResolvedAt:point inSize:size];
}
@end
