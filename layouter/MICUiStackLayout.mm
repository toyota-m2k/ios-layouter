//
//  MICStackLayout.m
//
//  ビューを縦または横方向に並べて配置するスタック型レイアウタークラス
//  （WindowsのStackPanel / AndroidのLinearLayoutのイメージ）
//
//  Created by @toyota-m2k on 2014/10/23.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiStackLayout.h"
#import "MICUiRectUtil.h"
#import "MICSpan.h"

//---------------------------------------------------------------------------------
#pragma mark - セル情報クラス

/**
 * セル情報クラス
 */
@interface MICUiStackCell : MICUiLayoutCell {
}
@property (nonatomic) CGRect bounds;

@end

@implementation MICUiStackCell

/**
 * セル情報で初期化
 */
- (MICUiStackCell*) initWithView:(UIView*)view {
    self = [super initWithView:view];
    if(nil!=self) {
        _bounds = CGRectZero;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"StackCell:%@", self.view.description];
}
@end

//---------------------------------------------------------------------------------
#pragma mark - D&D情報クラス

/**
 * D&D情報クラス
 */
@interface MICUiStackDraggingInfo : MICUiCellDraggingInfo
@end

@implementation MICUiStackDraggingInfo
/**
 * D&D情報を初期化
 */
- (id) initWithCell:(MICUiStackCell*)cell originalIndex:(int)index children:(NSMutableArray *)children {
    self = [super initWithCell:cell originalIndex:index children:children];
    if(nil!=self) {
    }
    return self;
}
@end

#pragma mark - スタックレイアウタークラス

/**
 * スタックレイアウタークラス
 */
@implementation MICUiStackLayout {
    CGSize _contentSize;                                ///< 全コンテントサイズ（マージンを含む）
}

/**
 * レイアウターの初期化
 */
- (id) init {
    return [self initWithOrientation:MICUiVertical alignment:MICUiAlignExLEFT];
}

/**
 * 方向とアラインメントを与えて初期化
 */
- (id) initWithOrientation:(MICUiOrientation)orientation alignment:(MICUiAlignEx) align {
    self = [super init];
    if(nil!=self) {
        _cellSpacing = 0;
        _cellAlignment = align;
        _orientation = orientation;
        _fixedSideSize = -1;
        _fitGrowingSideSize = -1;
        _contentSize = CGSizeZero;
    }
    return self;
}


#pragma mark - スタックレイアウター：プロパティ

#define CHK_SET(vo,vn) {if((vo)!=(vn)){(vo)=(vn), _needsRecalcLayout=_contentSizeChanged=true;}}

/**
 * セル間隔
 */
- (void)setCellSpacing:(CGFloat)spacing {
    if(spacing<0) {
        spacing = 0;
    }
    CHK_SET(_cellSpacing, spacing);
}

- (void)setCellAlignment:(MICUiAlignEx) align {
    CHK_SET(_cellAlignment,align);
}

- (void)setOrientation:(MICUiOrientation) orientation {
    CHK_SET(_orientation, orientation);
}

- (void)setFixedSideSize:(CGFloat)fixedSideSize {
    CHK_SET(_fixedSideSize,fixedSideSize);
}

- (void)setFitGrowingSideSize:(CGFloat)fitGrowingSideSize {
    CHK_SET(_fitGrowingSideSize,fitGrowingSideSize);
}

/**
 * ドラッグ可能な方向
 */
- (int) draggableOrientation {
    return _orientation;
}

#pragma mark - セル管理
/**
 * セル管理オブジェクトを作成する。
 */
- (MICUiLayoutCell *)createCell:(UIView *)view {
    return [[MICUiStackCell alloc] initWithView:view];
}

//--------------------------------------------------------------------------------------------
#pragma mark - レンダリング

#define XY_G(x,y) ((_orientation==MICUiVertical)?(y):(x))
#define XY_F(x,y) ((_orientation==MICUiVertical)?(x):(y))
#define SIZE_G(size) XY_G((size).width, (size).height)
#define SIZE_F(size) XY_F((size).width, (size).height)
#define POS_G(pos) XY_G((pos).x, (pos).y)
#define POS_F(pos) XY_F((pos).x, (pos).y)

#define GF_X(g,f) ((_orientation==MICUiVertical)?(f):(g))
#define GF_Y(g,f) ((_orientation==MICUiVertical)?(g):(f))

#define CELL_GP(cell) (XY_G((cell).bounds.origin.x,(cell).bounds.origin.y))
#define CELL_FP(cell) (XY_F((cell).bounds.origin.x,(cell).bounds.origin.y))
#define CELL_GW(cell) (XY_G((cell).bounds.size.width,(cell).bounds.size.height))
#define CELL_FW(cell) (XY_F((cell).bounds.size.width,(cell).bounds.size.height))

/**
 * レイアウトの再計算
 */
- (void) calcLayout {
    if(!_needsRecalcLayout) {
        return;
    }
    if(!_children.count) {
        return;
    }
    CGFloat gsize=0, fsize = _fixedSideSize;
    if(fsize<0) {
        // 固定方向サイズが指定されていないときは、最大セルのサイズを取り出す。
        fsize = 0;
        for (MICUiStackCell* cell in _children) {
            if(nil!=cell.view) {
                CGFloat s = SIZE_F(cell.view.frame.size);
                if( s > fsize ) {
                    fsize = s;
                }
            }
        }
    }
    CGFloat gratio = 1, fitto = _fitGrowingSideSize-_cellSpacing*(_children.count-1);
    if(fitto>0) {
        CGFloat gg = 0;
        for (MICUiStackCell* cell in _children) {
            if(nil!=cell.view) {
                gg += SIZE_G(cell.view.frame.size);
            } else {
                gg += SIZE_G(cell.bounds.size);
            }
        }
        if(gg>0) {
            gratio = fitto / gg;
        }
    }
    
    CGFloat fp, gw, fw;
    CGFloat gt=XY_G(_marginLeft, _marginTop), ft=XY_F(_marginLeft, _marginTop);             // topマージン
    CGFloat gb=XY_G(_marginRight, _marginBottom), fb = XY_F(_marginRight, _marginBottom);   // bottomマージン
    for (MICUiStackCell* cell in _children) {
        // レイアウト用基準セルサイズ
        CGSize cellSize;
        if(nil==cell.view) {
            // Viewがnullならスペーサー
            cellSize = cell.bounds.size;
        } else if(nil!=_getCellSizeDelegate) {
            // デリゲートが指定されていれば、そこからサイズを取得
            cellSize = [_getCellSizeDelegate getCellSizeForLayout:cell.view];
        } else {
            // 通常は、現在のビューサイズ
            cellSize = cell.view.frame.size;
        }

        gw = SIZE_G(cellSize)*gratio;
        fw = SIZE_F(cellSize);
        fp = ft;
        if(_cellAlignment==MICUiAlignExFILL || fw>=fsize) {
            cellSize.width = GF_X(gw,fsize);
            cellSize.height = GF_Y(gw,fsize);
        } else if( fw < fsize) {
            switch(_cellAlignment) {
                case MICUiAlignExTOP:
                default:
                    break;
                case MICUiAlignExCENTER:
                    fp += (fsize-fw)/2;
                    break;
                case MICUiAlignExBOTTOM:
                    fp += (fsize-fw);
                    break;
            }
        }
    
        cell.bounds = CGRectMake(GF_X(gt,fp),GF_Y(gt,fp),cellSize.width, cellSize.height);
        if(!cell.view.hidden) {
            gsize = gt + gw;
            gt += (gw + _cellSpacing);
        }
    }
    gsize += gb;
    fsize += ft + fb;
    MICSize newSize(GF_X(gsize, fsize),GF_Y(gsize, fsize));
    if( newSize != _contentSize) {
        _contentSize = newSize;
        _contentSizeChanged = true;
    }
    _needsRecalcLayout = false;
    
}

- (CGRect)getCellRect:(MICUiLayoutCell *)cell {
    return ((MICUiStackCell*)cell).bounds;
}

/**
 * レイアウターの表示サイズを取得する。
 * 必要に応じてセルの配置を再計算するが、表示は更新されない。
 * @return レイアウター全体のサイズ（スクロール領域の計算に使用することを想定）
 */
- (CGSize) getSize {
    if(_needsRecalcLayout) {
        [self calcLayout];
    }
    return _contentSize;
}

/**
 * レイアウターのマージンを除く、正味のコンテント領域の領域を取得する。
 *
 * @return  コンテナビュー座標系（bounds内）での矩形領域（ヒットテストなどに利用されることを想定）。
 */
- (CGRect) getContentRect {
    MICRect rc = MICRect(CGPointZero, [self getSize]);
    MICEdgeInsets margin(_marginLeft,_marginTop,_marginRight,_marginBottom);
    return rc - margin;
}

///**
// * インデックスの範囲で指定されたセルの領域を返す。
// */
//- (CGRect) cellRectRangeFrom:(int)start to:(int)end {
//    int count =(int) _children.count;
//    if(count==0) {
//        return CGRectZero;
//    }
//    MICSpanI spanAll(0,count-1);
//    MICSpanI spanReq(start, end);
//    spanReq.limitBy(spanAll);
//        
//    
//    MICUiStackCell* scell = _children[spanReq.min()];
//    MICUiStackCell* ecell = _children[spanReq.max()];
//    return MICRect::unionRect(scell.bounds, ecell.bounds);
//}

- (void)ensureCellVisible:(MICUiLayoutCell *)cell {
    [self ensureCellVisible:cell expand:false toDownward:false maxSize:0];
}

- (void)ensureCellVisible:(MICUiLayoutCell *)cell expand:(bool)expand toDownward:(bool)downward maxSize:(CGFloat)max{

    MICRect rect = ((MICUiStackCell*)cell).bounds;
    if(expand) {
        //MICSpanI span(0,(int)_children.count-1);
        int i = [self indexOfCell:cell];
//        int j = span.limit(i + ((downward)?1:-1));
        int j = MICSpanInt::limit(0, (int)_children.count-1, i + ((downward)?1:-1));
        if( i!=j) {
            MICRect r = ((MICUiStackCell*)_children[j]).bounds;
            if(_orientation==MICUiHorizontal) {
                r.transpose();
            }
            if( r.height()>max) {
                if(downward) {
                    r.deflate(0,0,0,r.height()*0.4);
                } else {
                    r.deflate(0,r.height()*0.4,0,0);
                }
            }
            rect.unionRect(r);
        }
    }
    if(nil==_draggingInfo || !CGRectEqualToRect(rect,_draggingInfo.prevVisibleRect)) {
        [_layoutDelegate ensureRectVisible:self rect:rect];
        _draggingInfo.prevVisibleRect = rect;
    }
}

//--------------------------------------------------------------------------------------------
#pragma mark - ドラッグ＆ドロップ

/**
 * セルに対するヒットテスト
 */
- (MICUiLayoutCell*) hitTestAtX:(CGFloat)x andY:(CGFloat)y {
    CGFloat fp = XY_F(x,y);
    CGFloat ftop = XY_F(_marginLeft, _marginTop);
    CGFloat fbtm = XY_F(_contentSize.width-_marginRight, _contentSize.height-_marginBottom);
    if(fp<ftop || fbtm<fp ) {
        return nil;
    }
    
    CGFloat gp = XY_G(x,y);
    CGFloat gtop = XY_G(_marginLeft, _marginTop);
    CGFloat gbtm = XY_G(_contentSize.width-_marginRight, _contentSize.height-_marginBottom);
    if(gp<gtop || gbtm<gp ) {
        return nil;
    }
    for(MICUiStackCell* cell in _children) {
        if(!cell.view.hidden) {
            if(gp < CELL_GP(cell)+CELL_GW(cell)) {
                return cell;
            }
        }
    }
    return nil;
}

/**
 * セルの順序を変更する。
 */
- (void) moveCellFrom:(int)srcIndex to:(int)dstIndex {
//    NSLog(@"move from %d to %d", srcIndex, dstIndex);
    id cell = _children[srcIndex];
    [_children removeObjectAtIndex:srcIndex];
    if(dstIndex==_children.count+1) {
        [_children addObject:cell];
    } else {
        [_children insertObject:cell atIndex:dstIndex];
    }
    _needsRecalcLayout = true;
}

/**
 * (PROTECTED, ABSTRACT) ドラッグ操作の実行
 */
- (BOOL) doDrag:(id<MICUiDragEventArg>) eventArg {
    // タッチ座標からセルの移動位置を計算
    MICPoint touchPos = [eventArg touchPosOn:self];
    if(_orientation==MICUiHorizontal) {
        touchPos.transpose();
    }
    int index = 0;
    for(MICUiStackCell* cell in _children) {
        MICRect rc = cell.bounds;
        if(_orientation==MICUiHorizontal) {
            rc.transpose();
        }
//        NSLog(@"    Stack:i=%d rc.y=(%f-%f) center=%f", index, rc.top(), rc.bottom(), rc.center().y);
        if(touchPos.y < rc.center().y) {
            break;
        }
        index++;
    }
    if(index>_draggingInfo.currentIndex) {
        index--;
    }
//    NSLog(@"Stack:i=%d / cur=%d", index, _draggingInfo.currentIndex);
    NSAssert(index<_children.count,@"index must be less than count of cells.");
    
    if(index==_draggingInfo.currentIndex) {
        return false;
    }
    
    [self moveCellFrom:_draggingInfo.currentIndex to:index];
    _draggingInfo.currentIndex = index;
    
    return true;
}


/**
 * (PROTECTED, ABSTRACT) ドラッグ前の状態に戻す
 */
- (BOOL) resetDrag:(id<MICUiDragEventArg>) eventArg {
    if(_draggingInfo.currentIndex!=_draggingInfo.orgIndex) {
        [self moveCellFrom:_draggingInfo.currentIndex to:_draggingInfo.orgIndex];
        return true;
    }
    return false;
    
}

/**
 * ドラッグ情報クラスのインスタンスを作成する。
 */
- (MICUiCellDraggingInfo*) createCellDraggingInfo:(MICUiLayoutCell*) cell  event:(id<MICUiDragEventArg>) eventArg {
    MICUiStackDraggingInfo* dinfo;
    int index = -1;
    if(nil!=cell) {
        // 自分自身がドラッグソース
        index = [self indexOfCell:cell];
    } else {
        // 外部からセルが持ち込まれる
        cell = [[MICUiStackCell alloc] initWithView:eventArg.draggingView];
        [cell beginDrag];   // ドラッグ中の描画を禁止するため
    }
    

    dinfo = [[MICUiStackDraggingInfo alloc] initWithCell:cell
                                           originalIndex:index
                                                children:_children];

    return dinfo;
}

- (void) addSpacer:(CGFloat)size {
    MICUiStackCell* cell = [[MICUiStackCell alloc] init];
    cell.bounds = MICRect(size,size);
    [self insertCell:cell atIndex:-1];
}

@end
