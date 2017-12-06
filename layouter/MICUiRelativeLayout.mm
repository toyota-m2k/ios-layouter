//
//  MICUiRelativeLayout.m
//
//  親ビューまたは、兄弟ビューとの相対位置によってビューの配置を決定するレイアウタークラス
//  (AndroidのRelativeLayout風）
//
//  Created by 豊田 光樹 on 2014/11/26.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiRelativeLayout.h"
#import "MICUiRectUtil.h"
#import "MICSpan.h"

//------------------------------------------------------------------------------------------
#pragma mark - Attach情報

/**
 * Viewの各辺のアタッチ方法を指定するための情報クラス
 */
@implementation MICUiRelativeLayoutAttachInfo

/**
 * 初期化（PRIVATE）
 */
- (instancetype) initWithAttach:(MICUiRelativeLayoutAttach)attach toView:(UIView*)attachTo byValue:(CGFloat)value {
    self = [super init];
    if(nil!=self) {
        _attach = attach;
        _attachTo = attachTo;
        _value = value;
    }
    return self;
}

- (void) setParam:(MICUiRelativeLayoutAttach)attach toView:(UIView*)attachTo byValue:(CGFloat)value {
    _attach = attach;
    _attachTo = attachTo;
    _value = value;
}


/**
 * 自由端（反対側の辺の位置とサイズから自動的に決定される）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachFree {
    return [[MICUiRelativeLayoutAttachInfo alloc] initWithAttach:MICUiRelativeLayoutAttachFREE toView:nil byValue:0];
}

/**
 * 親（RelativeLayout）にアタッチ
 *  @param 親の各辺からの距離（負値を与えると、親枠の外側になる）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachParent:(CGFloat)distance {
    return [[MICUiRelativeLayoutAttachInfo alloc] initWithAttach:MICUiRelativeLayoutAttachPARENT toView:nil byValue:distance];
}

/**
 * 兄弟の隣接する辺にアタッチ
 *  @param sibling  隣のView
 *  @param distance ２つのViewの隣り合う辺の距離（負値を与えるとViewが重なる）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachAdjacent:(UIView*)sibling inDistance:(CGFloat)distance {
    return [[MICUiRelativeLayoutAttachInfo alloc] initWithAttach:MICUiRelativeLayoutAttachADJACENT toView:sibling byValue:distance];
}

/**
 * 兄弟の対応する辺にアタッチ（右揃え、左揃えなど）
 *  @param sibling  基準とするView
 *  @param distance 基準Viewの基準辺からの距離（正値なら基準ビューの内側、負値なら基準ビューの外側になる）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachFitTo:(UIView*)sibling inDistance:(CGFloat)distance {
    return [[MICUiRelativeLayoutAttachInfo alloc] initWithAttach:MICUiRelativeLayoutAttachFITTO toView:sibling byValue:distance];
}

/**
 * 親(RelativeLayout)に対する中央揃え
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachCenter {
    return [[MICUiRelativeLayoutAttachInfo alloc] initWithAttach:MICUiRelativeLayoutAttachCENTEROF toView:nil byValue:0];
}

/**
 * 兄弟に対する中央揃え
 *  @param sibling  基準とするView（このビューに対する中央揃えで配置）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachCenterOfView:(UIView*)sibling {
    return [[MICUiRelativeLayoutAttachInfo alloc] initWithAttach:MICUiRelativeLayoutAttachCENTEROF toView:sibling byValue:0];
}


/**
 * 自由端（反対側の辺の位置とサイズから自動的に決定される）
 */
- (void) setAttachFree {
    [self setParam:MICUiRelativeLayoutAttachFREE toView:nil byValue:0];
}

/**
 * 親（RelativeLayout）にアタッチ
 *  @param 親の各辺からの距離（負値を与えると、親枠の外側になる）
 */
- (void) setAttachParent:(CGFloat)distance {
    [self setParam:MICUiRelativeLayoutAttachPARENT toView:nil byValue:distance];
}

/**
 * 兄弟の隣接する辺にアタッチ
 *  @param sibling  隣のView
 *  @param distance ２つのViewの隣り合う辺の距離（負値を与えるとViewが重なる）
 */
- (void) setAttachAdjacent:(UIView*)sibling inDistance:(CGFloat)distance {
    [self setParam:MICUiRelativeLayoutAttachADJACENT toView:sibling byValue:distance];
}

/**
 * 兄弟の対応する辺にアタッチ（右揃え、左揃えなど）
 *  @param sibling  基準とするView
 *  @param distance 基準Viewの基準辺からの距離（正値なら基準ビューの内側、負値なら基準ビューの外側になる）
 */
- (void) setAttachFitTo:(UIView*)sibling inDistance:(CGFloat)distance {
    [self setParam:MICUiRelativeLayoutAttachFITTO toView:sibling byValue:distance];
}

/**
 * 親(RelativeLayout)に対する中央揃え
 */
- (void) setAttachCenter {
    [self setParam:MICUiRelativeLayoutAttachCENTEROF toView:nil byValue:0];
}

/**
 * 兄弟に対する中央揃え
 *  @param sibling  基準とするView（このビューに対する中央揃えで配置）
 */
- (void) setAttachCenterOfView:(UIView*)sibling {
    [self setParam:MICUiRelativeLayoutAttachCENTEROF toView:sibling byValue:0];
}

@end

//------------------------------------------------------------------------------------------
#pragma mark - Scaling情報

/**
 * Viewの縦・横サイズを決定する方法を指定するための情報クラス
 */
@implementation MICUiRelativeLayoutScalingInfo

/**
 * 初期化（PRIVATE）
 */
- (instancetype) initWithScaling:(MICUiRelativeLayoutScaling)scaling referToView:(UIView*)referTo byValue:(CGFloat)value {
    self = [super init];
    if(nil!=self) {
        _scaling = scaling;
        _referTo = referTo;
        _value = value;
    }
    return self;
}

- (void) setParam:(MICUiRelativeLayoutScaling)scaling referToView:(UIView*)referTo byValue:(CGFloat)value {
    _scaling = scaling;
    _referTo = referTo;
    _value = value;
}

/**
 * 可変幅
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingFree {
    return [[MICUiRelativeLayoutScalingInfo alloc] initWithScaling:MICUiRelativeLayoutScalingFREE referToView:nil byValue:0];
}

/**
 * サイズ変更なし
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingNoSize {
    return [[MICUiRelativeLayoutScalingInfo alloc] initWithScaling:MICUiRelativeLayoutScalingNOSIZE referToView:nil byValue:0];
}

/**
 * 固定サイズ
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingFixed:(CGFloat)size {
    return [[MICUiRelativeLayoutScalingInfo alloc] initWithScaling:MICUiRelativeLayoutScalingFIXED referToView:nil byValue:size];
}

/**
 * 親（RelativeLayout）相対サイズ
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingRelative:(CGFloat)ratio {
    return [[MICUiRelativeLayoutScalingInfo alloc] initWithScaling:MICUiRelativeLayoutScalingRELATIVE referToView:nil byValue:ratio];
}

/**
 * 兄弟View相対サイズ
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingRelativeToView:(UIView*)sibling inRatio:(CGFloat)ratio {
    return [[MICUiRelativeLayoutScalingInfo alloc] initWithScaling:MICUiRelativeLayoutScalingRELATIVE referToView:sibling byValue:ratio];
}





/**
 * 可変幅
 */
- (void) setScalingFree {
    [self setParam:MICUiRelativeLayoutScalingFREE referToView:nil byValue:0];
}

/**
 * サイズ変更なし
 */
- (void) setScalingNoSize {
    [self setParam:MICUiRelativeLayoutScalingNOSIZE referToView:nil byValue:0];
}

/**
 * 固定サイズ
 */
- (void) setScalingFixed:(CGFloat)size {
    [self setParam:MICUiRelativeLayoutScalingFIXED referToView:nil byValue:size];
}

/**
 * 親（RelativeLayout）相対サイズ
 */
- (void) setScalingRelative:(CGFloat)ratio {
    [self setParam:MICUiRelativeLayoutScalingRELATIVE referToView:nil byValue:ratio];
}

/**
 * 兄弟View相対サイズ
 */
- (void) setScalingRelativeToView:(UIView*)sibling inRatio:(CGFloat)ratio {
    [self setParam:MICUiRelativeLayoutScalingRELATIVE referToView:sibling byValue:ratio];
}

@end

//------------------------------------------------------------------------------------------
#pragma mark - レイアウト情報

@implementation MICUiRelativeLayoutInfo

/**
 * 初期化（あとで、すべてのレイアウト情報をセットしてください。）
 */
- (instancetype) init {
    return [self initWithHorz:nil left:nil right:nil vert:nil top:nil bottom:nil];
    
}

/**
 * レイアウト情報を与えて初期化
 */
- (instancetype) initWithHorz:(MICUiRelativeLayoutScalingInfo*)horz
                         left:(MICUiRelativeLayoutAttachInfo*)left
                        right:(MICUiRelativeLayoutAttachInfo*)right
                         vert:(MICUiRelativeLayoutScalingInfo*)vert
                          top:(MICUiRelativeLayoutAttachInfo*)top
                       bottom:(MICUiRelativeLayoutAttachInfo*)bottom {
    self = [super init];
    if(nil!=self) {
        _vert = vert;
        _top = top;
        _bottom = bottom;
        _horz = horz;
        _left = left;
        _right = right;
    }
    return self;
}

/**
 * 横方向のレイアウト情報を設定
 */
- (void) setHorzParam:(MICUiRelativeLayoutScalingInfo*)horz
                 left:(MICUiRelativeLayoutAttachInfo*)left
                right:(MICUiRelativeLayoutAttachInfo*)right {
    _horz = horz;
    _left = left;
    _right = right;
}

/**
 * 縦方向のレイアウト情報を設定
 */
- (void) setVertParam:(MICUiRelativeLayoutScalingInfo*)vert
                  top:(MICUiRelativeLayoutAttachInfo*)top
               bottom:(MICUiRelativeLayoutAttachInfo*)bottom {
    _vert = vert;
    _top = top;
    _bottom = bottom;
}
@end

//------------------------------------------------------------------------------------------
#pragma mark - セル情報

/**
 * セルの位置・サイズ解決済フラグ
 */
enum ResolvedFlag {
    RS_LEFT = 0x1,
    RS_RIGHT = 0x2,
    RS_TOP = 0x4,
    RS_BOTTOM = 0x8,
    RS_WIDTH = 0x10,
    RS_HEIGHT = 0x20,
};
static const int RS_ALL = (RS_LEFT|RS_RIGHT|RS_TOP|RS_BOTTOM|RS_WIDTH|RS_HEIGHT);

/**
 * セルの位置・サイズ解決済フラグチェック用マクロ
 */
#define ISRESOLVED(v) ((_resolveFlags&(v))==(v))

@interface MICUiRelativeCell ()
@property (nonatomic) int resolveFlags;                         ///< 配置確定済みフラグ
@property (nonatomic) CGRect bounds;                            ///< 計算された配置位置

- (void) resolved:(int)flag;
- (void) unresolved;
- (bool) isResolved;
- (bool) isResolvedAt:(int)flag;

/**
 * セル情報を与えて初期化
 */
- (id) initWithView:(UIView*)view layoutInfo:(MICUiRelativeLayoutInfo*)info;
@end

@implementation MICUiRelativeCell {
    MICRect _bounds;
}

- (CGRect) bounds {
    return (!self.isLocationReserved) ? _bounds : _reservedLocation;
}

- (void) setBounds:(CGRect)bounds {
    _bounds = bounds;
}

- (CGSize) viewSize {
    return (!self.isLocationReserved) ? _view.frame.size : _reservedLocation.size;
}

- (id) initWithView:(UIView*)view layoutInfo:(MICUiRelativeLayoutInfo*)info {
    self = [super initWithView:view];
    if(nil!=self) {
        _layoutInfo = info;
        _resolveFlags = false;
    }
    return self;
}

/**
 * 指定部位を解決済みにする
 */
- (void) resolved:(int)flag {
    _resolveFlags |= flag;
}

/**
 * すべて未解決にする。
 */
- (void) unresolved {
    _resolveFlags = 0;
}

/**
 * すべて解決済みか？
 */
- (bool) isResolved {
    return _resolveFlags == RS_ALL;
}


/**
 * 指定部位は解決済みか？
 */
- (bool) isResolvedAt:(int)flag {
    return (_resolveFlags & flag ) == flag;
}

/**
 * 上辺の位置を確定する
 */
- (void) setTop:(CGFloat)v {
    if(ISRESOLVED(RS_HEIGHT)) {
        _bounds.origin.y = v;
        _resolveFlags |= (RS_TOP|RS_BOTTOM);
    } else {
        _bounds.setTop(v);
        _resolveFlags |= RS_TOP;
        if(ISRESOLVED(RS_BOTTOM)) {
            _resolveFlags |= RS_HEIGHT;
        }
    }
}

/**
 * 下辺の位置を確定する
 */
- (void) setBottom:(CGFloat)v {
    if(ISRESOLVED(RS_HEIGHT)) {
        _bounds.origin.y = v - _bounds.height();
        _resolveFlags |= (RS_TOP|RS_BOTTOM);
    } else {
        _bounds.setBottom(v);
        _resolveFlags |= RS_BOTTOM;
        if(ISRESOLVED(RS_TOP)) {
            _resolveFlags |= RS_HEIGHT;
        }
    }
}

/**
 * 左辺の位置を確定する
 */
- (void) setLeft:(CGFloat)v {
    if(ISRESOLVED(RS_WIDTH)) {
        _bounds.origin.x = v;
        _resolveFlags |= (RS_LEFT|RS_RIGHT);
    } else {
        _bounds.setLeft(v);
        _resolveFlags |= RS_LEFT;
        if(ISRESOLVED(RS_RIGHT)) {
            _resolveFlags |= RS_WIDTH;
        }
    }
}

/**
 * 右辺の位置を確定する
 */
- (void) setRight:(CGFloat)v {
    if(ISRESOLVED(RS_WIDTH)) {
        _bounds.origin.x = v - _bounds.width();
        _resolveFlags |= (RS_LEFT|RS_RIGHT);
    } else {
        _bounds.setRight(v);
        _resolveFlags |= RS_RIGHT;
        if(ISRESOLVED(RS_LEFT)) {
            _resolveFlags |= RS_WIDTH;
        }
    }
}

/**
 * 高さを確定する
 */
- (void) setHeight:(CGFloat)v {
    _resolveFlags |= RS_HEIGHT;
    if(ISRESOLVED(RS_TOP)) {
        _resolveFlags |= RS_BOTTOM;
        _bounds.size.height = v;
    } else if(ISRESOLVED(RS_BOTTOM)) {
        _resolveFlags |= RS_TOP;
        _bounds.setTop(_bounds.bottom()-v);
    } else {
        _bounds.size.height = v;
    }
}

/**
 * 幅を確定する
 */
- (void) setWidth:(CGFloat)v {
    _resolveFlags |= RS_WIDTH;
    if(ISRESOLVED(RS_LEFT)) {
        _resolveFlags |= RS_RIGHT;
        _bounds.size.width = v;
    } else if(ISRESOLVED(RS_RIGHT)) {
        _resolveFlags |= RS_LEFT;
        _bounds.setLeft(_bounds.right()-v);
    } else {
        _bounds.size.width = v;
    }
}

/**
 * アタッチ情報を取得
 */
- (MICUiRelativeLayoutAttachInfo*) attachInfoAt:(MICUiPos)pos {
    switch(pos) {
        case MICUiPosTOP:
            return _layoutInfo.top;
        case MICUiPosBOTTOM:
            return _layoutInfo.bottom;
        case MICUiPosLEFT:
            return _layoutInfo.left;
        case MICUiPosRIGHT:
            return _layoutInfo.right;
    }
}

/**
 * スケーリング情報を取得
 */
- (MICUiRelativeLayoutScalingInfo*) scalingInfoAt:(MICUiOrientation)pos {
    switch(pos) {
        case MICUiVertical:
            return _layoutInfo.vert;
        case MICUiHorizontal:
            return _layoutInfo.horz;
    }
}

@end

//------------------------------------------------------------------------------------------
#pragma mark - D&D情報クラス
/**
 * D&D情報クラス
 */
@interface MICUiRelativeDraggingInfo : MICUiCellDraggingInfo
@end

@implementation MICUiRelativeDraggingInfo
/**
 * D&D情報を初期化
 */
- (id) initWithCell:(MICUiRelativeCell*)cell originalIndex:(int)index children:(NSMutableArray *)children {
    self = [super initWithCell:cell originalIndex:index children:children];
    if(nil!=self) {
    }
    return self;
}

@end




//------------------------------------------------------------------------------------------
#pragma mark - 相対レイアウトクラス

/**
 * 相対レイアウトクラス
 */
@implementation MICUiRelativeLayout {
    MICSize _contentSize;
}

//------------------------------------------------------------------------------------------
#pragma mark - プロパティ

/**
 * マージンを含まないコンテント領域のサイズ
 */
- (CGSize)overallSize {
    return _contentSize;
}

- (void)setOverallSize:(CGSize)overallSize {
    if(_contentSize!=overallSize){
        _contentSize = overallSize;
        _needsRecalcLayout = true;
    }
}

/**
 * (PROTECTED, ABSTRACT) レイアウターの表示サイズを取得する。
 * @return マージンを含むレイアウター全体のサイズ（スクロール領域の計算に使用することを想定）
 */
- (CGSize) getSize {
    MICSize size(_contentSize);
    size.inflate([super margin]);
    return size;
}

/**
 * (PROTECTED, ABSTRACT) レイアウターのマージンを除く、正味のコンテント領域の領域を取得する。
 *
 * @return  コンテナビュー座標系（bounds内）での矩形領域（ヒットテストなどに利用されることを想定）。
 */
- (CGRect) getContentRect {
    return MICRect(MICPoint(_marginLeft,_marginTop), _contentSize);
}

//------------------------------------------------------------------------------------------
#pragma mark - 子ビュー管理

/**
 * 子ビューを追加する
 */
- (void) addChild:(UIView *)view andInfo:(MICUiRelativeLayoutInfo*)info {
    MICUiRelativeCell* cell = [[MICUiRelativeCell alloc] initWithView:view layoutInfo:info];
    [self insertCell:cell atIndex:-1];
}

/**
 * 子ビューを挿入する。
 */
- (void) insertChild:(UIView *)view beforeSibling:(UIView*)siblingView andInfo:(MICUiRelativeLayoutInfo*)info {
    MICUiRelativeCell* cell = [[MICUiRelativeCell alloc] initWithView:view layoutInfo:info];
    int idx = (nil!=siblingView) ? [self indexOfChild:siblingView] : -1;
    [super insertCell:cell atIndex:idx];
}

/**
 * (PROTECTED, ABSTRACT) セル情報インスタンスを生成する。
 */
- (MICUiLayoutCell*)createCell:(UIView*)view {
    MICUiRelativeLayoutInfo* info = [[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                             left:[MICUiRelativeLayoutAttachInfo newAttachCenter]
                                                                            right:[MICUiRelativeLayoutAttachInfo newAttachCenter]
                                                                             vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                              top:[MICUiRelativeLayoutAttachInfo newAttachCenter]
                                                                           bottom:[MICUiRelativeLayoutAttachInfo newAttachCenter]];
    return [[MICUiRelativeCell alloc] initWithView:view layoutInfo:info];
}

/**
 * 子ビューのレイアウト情報を取得
 */
- (MICUiRelativeLayoutInfo*) layoutInfoOfView:(UIView*)view {
    MICUiRelativeCell* cell = (MICUiRelativeCell*)[self findCell:view];
    return (nil!=cell) ? cell.layoutInfo : nil;
}

//------------------------------------------------------------------------------------------
#pragma mark - レンダリング

/**
 * ビューの位置を計算する。
 */
- (bool) getPositionOfCell:(MICUiRelativeCell*)cell forPosition:(MICUiPos)pos {
    MICUiRelativeLayoutAttachInfo* at = [cell attachInfoAt:pos];
    switch( at.attach ) {
        case MICUiRelativeLayoutAttachPARENT:
        {
            MICRect rc = [self getContentRect];
            switch (pos) {
                case MICUiPosLEFT:
                    [cell setLeft:rc.left() + at.value];
                    return true;
                case MICUiPosTOP:
                    [cell setTop:rc.top() + at.value];
                    return true;
                case MICUiPosRIGHT:
                    [cell setRight:rc.right() - at.value];
                    return true;
                case MICUiPosBOTTOM:
                    [cell setBottom:rc.bottom() - at.value];
                    return true;
                default:
                    break;
            }
            return false;
        }
        case MICUiRelativeLayoutAttachADJACENT:
        {
            MICUiRelativeCell* referCell = (MICUiRelativeCell*)[self findCell:at.attachTo];
            if(nil==referCell) {
                [NSException raise:@"MICUiRelativeLayout.getPositionOfView" format:@"no reference view for ADJACENT"];
            }
            MICRect rc = referCell.bounds;
            switch( pos ) {
                case MICUiPosLEFT:
                    if([referCell isResolvedAt:RS_RIGHT]) {
                        [cell setLeft:rc.right() + at.value];
                        return true;
                    }
                    break;
                case MICUiPosTOP:
                    if([referCell isResolvedAt:RS_BOTTOM]) {
                        [cell setTop:rc.bottom() + at.value];
                        return true;
                    }
                    break;
                case MICUiPosRIGHT:
                    if([referCell isResolvedAt:RS_LEFT]) {
                        [cell setRight:rc.left() - at.value];
                        return true;
                    }
                    break;
                case MICUiPosBOTTOM:
                    if([referCell isResolvedAt:RS_TOP]) {
                        [cell setBottom:rc.top() - at.value];
                        return true;
                    }
                    break;
                default:
                    break;
            }
            return false;
        }
        case MICUiRelativeLayoutAttachFITTO:
        {
            MICUiRelativeCell* referCell = (MICUiRelativeCell*)[self findCell:at.attachTo];
            if(nil==referCell) {
                [NSException raise:@"MICUiRelativeLayout.getPositionOfCell" format:@"no reference view for ADJACENT attachment."];
            }
            MICRect rc = referCell.bounds;
            switch( pos ) {
                case MICUiPosLEFT:
                    if([referCell isResolvedAt:RS_LEFT]) {
                        [cell setLeft:rc.left() + at.value];
                        return true;
                    }
                    break;
                case MICUiPosTOP:
                    if([referCell isResolvedAt:RS_TOP]) {
                        [cell setTop:rc.top() + at.value];
                        return true;
                    }
                    break;
                case MICUiPosRIGHT:
                    if([referCell isResolvedAt:RS_RIGHT]) {
                        [cell setRight:rc.right() - at.value];
                        return true;
                    }
                    break;
                case MICUiPosBOTTOM:
                    if([referCell isResolvedAt:RS_BOTTOM]) {
                        [cell setBottom:rc.bottom() - at.value];
                        return true;
                    }
                    break;
                default:
                    break;
            }
            break;
        }
        case MICUiRelativeLayoutAttachCENTEROF:
        {
            int res = (pos==MICUiPosLEFT||pos==MICUiPosRIGHT)?RS_WIDTH:RS_HEIGHT;
            if(![cell isResolvedAt:res]) {
                return false;
            }
            
            MICRect rc;
            if(at.attachTo==nil) {
                // Parent相対
                rc = [self getContentRect];
            } else {
                MICUiRelativeCell* referCell = (MICUiRelativeCell*)[self findCell:at.attachTo];
                if(nil==referCell) {
                    [NSException raise:@"MICUiRelativeLayout.getPositionOfCell" format:@"no reference view for CENTEROF attachment."];
                }
                if(![referCell isResolvedAt:res]) {
                    return false;
                }
                rc = referCell.bounds;
            }
            
            MICRect rcCell = cell.bounds;
            int res2;
            if(res==RS_WIDTH) {
                CGFloat d = (rc.width() - rcCell.width())/2;
                rcCell.origin.x = rc.left()+d;
                res2 = RS_LEFT|RS_RIGHT;
            } else {
                CGFloat d = (rc.height() - rcCell.height())/2;
                rcCell.origin.y = rc.top()+d;
                res2 = RS_TOP|RS_BOTTOM;
            }
            cell.bounds = rcCell;
            [cell resolved:res2];
            return true;
        }
        case MICUiRelativeLayoutAttachFREE:
        default:
            break;
    }
    return false;
}

/**
 * ビューのサイズを計算する
 */
- (bool) getSizeOfCell:(MICUiRelativeCell*)cell inDirection:(MICUiOrientation)dir {
    MICUiRelativeLayoutScalingInfo* sc = [cell scalingInfoAt:dir];
    switch( sc.scaling ) {
        case MICUiRelativeLayoutScalingFIXED:
            if(dir==MICUiHorizontal) {
                [cell setWidth:sc.value];
            } else {
                [cell setHeight:sc.value];
            }
            return true;
        case MICUiRelativeLayoutScalingNOSIZE:
            if(dir==MICUiHorizontal) {
                [cell setWidth:cell.viewSize.width];
            } else {
                [cell setHeight:cell.viewSize.height];
            }
            return true;
        case MICUiRelativeLayoutScalingRELATIVE:
        {
            int res = (dir == MICUiHorizontal)?RS_WIDTH:RS_HEIGHT;
            CGSize referSize;
            if( nil == sc.referTo ) {
                referSize = _contentSize;
            } else {
                MICUiRelativeCell* referCell = (MICUiRelativeCell*)[self findCell:sc.referTo];
                if(nil==referCell) {
                    [NSException raise:@"MICUiRelativeLayout.getSizeOfCell" format:@"no reference view for RELATIVE scaling."];
                }
                if(![referCell isResolvedAt:res]) {
                    return false;
                }
                referSize = referCell.bounds.size;
            }
            
            if( dir == MICUiHorizontal ){
                [cell setWidth:referSize.width*sc.value];
            } else {
                [cell setHeight:referSize.height*sc.value];
            }
            return true;
        }
        case MICUiRelativeLayoutScalingFREE:
        default:
            break;
    }
    return false;
}

/**
 * セル１個分の配置を計算する。
 */
- (bool) calcLayoutSub:(MICUiRelativeCell*)cell {
    if(![cell isResolvedAt:RS_LEFT]) {
        [self getPositionOfCell:cell forPosition:MICUiPosLEFT];
    }
    if(![cell isResolvedAt:RS_RIGHT]) {
        [self getPositionOfCell:cell forPosition:MICUiPosRIGHT];
    }
    if(![cell isResolvedAt:RS_TOP]) {
        [self getPositionOfCell:cell forPosition:MICUiPosTOP];
    }
    if(![cell isResolvedAt:RS_BOTTOM]) {
        [self getPositionOfCell:cell forPosition:MICUiPosBOTTOM];
    }
    if(![cell isResolvedAt:RS_WIDTH]) {
        [self getSizeOfCell:cell inDirection:MICUiHorizontal];
    }
    if(![cell isResolvedAt:RS_HEIGHT]) {
        [self getSizeOfCell:cell inDirection:MICUiVertical];
    }
    return cell.isResolved;
}

/**
 * (PROTECTED, ABSTRACT) セル配置の再計算
 */
- (void) calcLayout {
    // 解決済みフラグをすべてクリアする。
    for(MICUiRelativeCell* cell in _children) {
        [cell unresolved];
    }
    
    int remain, chkbefore, chkafter=0;
    remain = (int)_children.count;
    do {
        remain = (int)_children.count;
        chkbefore = chkafter;
        chkafter = 0;
        for(MICUiRelativeCell* cell in _children) {
            if(cell.isResolved) {
                remain--;
            } else {
                if([self calcLayoutSub:cell]) {
                    remain--;
                }
            }
            chkafter+=cell.resolveFlags;
        }
        
        if(chkafter==chkbefore) {
            // 無理
            [NSException raise:@"MICUiRelativeLayout.calcLayout" format:@"impossible to layout."];
        }
    } while(remain>0);
    _needsRecalcLayout = false;
}

/**
 * (PROTECTED, ABSTRACT) セルの位置・サイズの計算値を取得する
 */
- (CGRect) getCellRect:(MICUiLayoutCell*)cell {
    if(![cell isKindOfClass:MICUiRelativeCell.class]) {
        return CGRectZero;
    }
    return ((MICUiRelativeCell*)cell).bounds;
}

/**
 * (PROTECTED, ABSTRACT) 指定された座標位置のセルを取得する。
 */
- (MICUiLayoutCell*) hitTestAtX:(CGFloat)x andY:(CGFloat)y {
//    NSLog(@"hitTest(%f,%f)", x, y);
    MICPoint pos(x,y);
    for(MICUiRelativeCell* cell in _children) {
        if(MICRect::containsPoint(cell.bounds, pos)) {
//            NSLog(@"...hit:%@", cell.description);
            return cell;
        }
    }
//    NSLog(@"...not hit.");
    return nil;
}

//------------------------------------------------------------------------------------------
#pragma mark - D&Dサポート

/**
 * (PROTECTED, ABSTRACT) ドラッグ情報クラスのインスタンスを作成する。
 */
- (MICUiCellDraggingInfo*) createCellDraggingInfo:(MICUiLayoutCell*) cell  event:(id<MICUiDragEventArg>) eventArg {
    MICUiRelativeDraggingInfo* dinfo;
    int index = -1;
    if(nil!=cell) {
        // 自分自身がドラッグソース
        index = [self indexOfCell:cell];
    } else {
        // 外部からセルが持ち込まれる
        MICUiRelativeLayoutInfo* info =[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                                left:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                                               right:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                                                vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                                 top:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                                              bottom:[MICUiRelativeLayoutAttachInfo newAttachParent:0]];
        cell = [[MICUiRelativeCell alloc] initWithView:eventArg.draggingView
                                            layoutInfo:info];
        
        [cell beginDrag];   // ドラッグ中の描画を禁止するため
    }
    
    
    dinfo = [[MICUiRelativeDraggingInfo alloc] initWithCell:cell
                                           originalIndex:index
                                                children:_children];
    
    return dinfo;
}

/**
 * (PROTECTED, ABSTRACT) ドラッグ前の状態に戻す
 */
- (BOOL) resetDrag:(id<MICUiDragEventArg>) eventArg {
    return false;
}

/**
 * (PROTECTED, ABSTRACT) ドラッグ操作の実行
 */
- (BOOL) doDrag:(id<MICUiDragEventArg>) eventArg {
    return false;
}

- (void)endDrag:(id<MICUiDragEventArg>)eventArg {

    if(nil==_draggingInfo){
        return;
    }
    
    if( eventArg.dragDestination == self ) {
        // 自分にドロップされた
        MICRect rc = [eventArg getViewFrameOn:self];
        MICUiRelativeCell* cell = (MICUiRelativeCell*)_draggingInfo.draggingCell;

        [cell.layoutInfo.horz setScalingNoSize];
        [cell.layoutInfo.left setAttachParent:rc.left() - _marginLeft];
        [cell.layoutInfo.right setAttachFree];
        
        [cell.layoutInfo.vert setScalingNoSize];
        [cell.layoutInfo.top setAttachParent:rc.top() - _marginTop];
        [cell.layoutInfo.bottom setAttachFree];
        _needsRecalcLayout = true;
    }
    [super endDrag:eventArg];
}

/**
 * (PROTECTED) セルが画面内に入るようスクロールする。
 */
- (void) ensureCellVisible:(MICUiLayoutCell*)cell {
    if(![cell isKindOfClass:MICUiRelativeCell.class]) {
        return;
    }
    if(nil!=_layoutDelegate) {
        CGRect rc = [self getCellRect:cell];
        [_layoutDelegate ensureRectVisible:self rect:rc];
    }
}

@end
