//
//  MICUiGridLayout.m
//
//  ビューを格子状（タイル状）に並べるGrid型レイアウター
//  （Metroのスタート画面からインスパイヤ）
//
//  Created by @toyota-m2k on 2014/10/15.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiGridLayout.h"
#import "MICMatrix.h"
#import "MICUiRectUtil.h"
#import "MICStringUtil.h"

//--------------------------------------------------------------------------------------
#pragma mark - グリッドのセル情報クラス

/**
 * グリッドレイアウト内のセル情報クラス
 */
@interface MICUiGridCell () {
}
/**
 * コピーコンストラクタ
 */
- (id) initWithCell:(MICUiGridCell*)cell;
@end

@implementation MICUiGridCell {
    NSArray* _foldingCells;
}

- (NSArray*) foldingCells {
    return _foldingCells;
}

- (void) setFoldingCells:(NSArray*)cells {
    _foldingCells = cells;
}

/**
 * 空のセルを作成
 */
- (id) init {
    return [self initWithView:nil unitX:1 unitY:1 cellStyle:MICUiGlStyleNORMAL];
}

/**
 * セル情報を与えて初期化
 */
- (id) initWithView:(UIView*)v unitX:(int)w unitY:(int)h cellStyle:(MICUiGridCellStyle)style {
    self = [super initWithView:v];
    if(nil!=self) {
        _width = w;
        _height = h;
        _x = 0;
        _y = 0;
        _cellStyle = style;
    }
    return self;
}

/**
 * 複製してセルを初期化
 */
- (id) initWithCell:(MICUiGridCell*)cell {
    self = [super initWithView:cell.view];
    if(nil!=self) {
        _width = cell.width;
        _height = cell.height;
        _x = cell.x;
        _y = cell.y;
        _cellStyle = cell.cellStyle;
    }
    return self;
}

/**
 * セルのドラッグは可能か？（通常スタイルなら可）
 */
- (BOOL) draggable {
    return _cellStyle == MICUiGlStyleNORMAL;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"GridCell:%@", self.view.description];
}
@end

//--------------------------------------------------------------------------------------
#pragma mark - D&D情報クラス（内部クラス）

/**
 * D&D情報
 */
@interface MICUiGridDraggingInfo : MICUiCellDraggingInfo {
}
@property (nonatomic) MICMatrix* cellMatrix;                        ///< ドラッグされているセルを除いた状態での配置情報
@property (nonatomic) NSMutableArray* children;                     ///< ドラッグされているセルを除いた状態のセル情報（複製）＋末端にダミーのセル

@end


@implementation MICUiGridDraggingInfo {
}

/**
 * 通常のオブジェクト生成
 */
- (MICUiGridDraggingInfo *)initWithOwner:(MICUiGridLayout*)owner
                                    cell:(MICUiGridCell *)cell
                           originalIndex:(int)index
                                children:(NSMutableArray*) children
                                  matrix:(MICMatrix*) matrix {
    self = [super initWithCell:cell originalIndex:index children:children];
    if(nil!=self){
        // ドラッグされるセルを除いて、セル配列を複製する。（配置計算時にフィールドを書き換えるので、要素のセル情報も複製する）
        _children = [[NSMutableArray alloc] initWithCapacity:children.count];
        for(id c in children) {
            if(c!=cell) {
                [_children addObject:[[MICUiGridCell alloc] initWithCell:c]];
            }
        }
        
        // セル配列の末尾にダミーのセルを入れておく
        [_children addObject:[[MICUiGridCell alloc] initWithView:nil unitX:owner.megaUnitX unitY:owner.megaUnitY cellStyle:MICUiGlStyleNORMAL]];
        
        // 配置情報マトリックスの入れ物を作っておく。
        _cellMatrix = [[MICMatrix alloc] initWithDimmensionX:matrix.cx andY:matrix.cy];
    }
    return self;
}

/**
 * 外部から持ち込まれたセル用のオブジェクトを生成
 */
- (MICUiGridDraggingInfo *)initForIncomingCell:(MICUiGridLayout*)owner
                                         event:(id<MICUiDragEventArg>)eventArg
                                      children:(NSMutableArray*) children
                                        matrix:(MICMatrix*) matrix {
    self = [super initWithCell:nil originalIndex:-1 children:children];
    if(nil!=self){
        int unitx=owner.megaUnitX, unity=owner.megaUnitY;
        id foreignCell = eventArg.draggingCell;
        if(nil!=foreignCell && [foreignCell isKindOfClass:MICUiGridCell.class]) {
            unitx = ((MICUiGridCell*)foreignCell).width;
            unity = ((MICUiGridCell*)foreignCell).height;
        }
        // 念のためUnitサイズを制限（UI設計時にユニットサイズを揃えておくこと）
        if(owner.fixedOrientation==MICUiHorizontal) {
            if(unitx>owner.fixedSideCount) {
                unitx = owner.fixedSideCount;
            }
        } else {
            if(unity>owner.fixedSideCount) {
                unity = owner.fixedSideCount;
            }
        }

        // ドラッグ中のセル情報を作成しておく。
        _draggingCell = [[MICUiGridCell alloc] initWithView:eventArg.draggingView unitX:unitx unitY:unity cellStyle:MICUiGlStyleNORMAL];
        [_draggingCell beginDrag];      // ドラッグ中の描画を禁止するため

        // セル配列と要素のセルを複製する。
//        _masterChildren = children;
        _children = [[NSMutableArray alloc] initWithCapacity:children.count+1];
        for(id c in children) {
            [_children addObject:[[MICUiGridCell alloc] initWithCell:c]];
        }

        // コピーされたセル配列の末尾にダミーのセルを入れておく
        [_children addObject:[[MICUiGridCell alloc] initWithView:nil unitX:owner.megaUnitX unitY:owner.megaUnitY cellStyle:MICUiGlStyleNORMAL]];

        // 配置情報マトリックスの入れ物を作っておく。
        _cellMatrix = [[MICMatrix alloc] initWithDimmensionX:matrix.cx andY:matrix.cy];
    }
    return self;
}

@end

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウター　クラス本丸

@implementation MICUiGridLayout {
    BOOL _heteroSized;                                      ///< ２セルユニットサイズ以上のセルが含まれていればtrue
    int _maxGrowingSideCount;                               ///< 伸張方向の最大セルユニット数（一列に並べたときのユニット数）
    MICMatrix* _cellMatrix;                                 ///< _heteroSized == true のとき、セルのマッピング状態を保持する。
}

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウター getter/setter

#define CHK_SET(vo,vn) {if((vo)!=(vn)){(vo)=(vn), _needsRecalcLayout=_contentSizeChanged=true;}}

/**
 * セルのユニットサイズ
 */
- (void)setCellSize:(CGSize)cellSize {
    if(!CGSizeEqualToSize(_cellSize, cellSize)) {
        _cellSize = cellSize;
        _needsRecalcLayout = true;
        _contentSizeChanged = true;
    }
}

/**
 * セルとセルの間隔(setter)
 */
- (void)setCellSpacingHorz:(CGFloat)cellSpacingHorz {
    CHK_SET(_cellSpacingHorz, cellSpacingHorz);
}

- (void)setCellSpacingVert:(CGFloat)cellSpacingVert {
    CHK_SET(_cellSpacingVert, cellSpacingVert);
}

/**
 * レイアウターの伸張方向(setter)
 */
- (void)setGrowingOrientation:(MICUiOrientation)growingOrientation {
    CHK_SET(_growingOrientation, growingOrientation);
}

/**
 * レイアウターの固定幅方向(getter/setter)
 */
- (void)setFixedOrientation:(MICUiOrientation)fixedOrientation {
    [self setGrowingOrientation:(fixedOrientation == MICUiHorizontal)?MICUiVertical : MICUiHorizontal];
}

/**
 * 固定幅方向（growingOrientationの逆側）
 */
- (MICUiOrientation)fixedOrientation {
    return (_growingOrientation == MICUiHorizontal)?MICUiVertical : MICUiHorizontal;
}

/**
 * 固定幅方向のセル数
 */
- (void)setFixedSideCount:(int)fixedSideCount {
    CHK_SET(_fixedSideCount, fixedSideCount);
}

/**
 * ドラッグ可能な方向
 */
- (int) draggableOrientation {
    if(_fixedSideCount==1) {
        return _growingOrientation;
    } else {
        return MICUiOrientationBOTH;
    }
}

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウター 初期化

/**
 * デフォルト値で初期化
 */
- (id) init {
    return [self initWithCellSize:CGSizeMake(50.0f, 50.0f) growingOrientation:MICUiVertical fixedCount:2];
}

/**
 * 初期化
 * @param   cellSize セル１個あたりのサイズ
 * @param   growingOrientation 伸長方向
 * @param   fixedCount  固定幅方向のセル数
 */
- (id) initWithCellSize:(CGSize)cellSize
   growingOrientation:(MICUiOrientation)growingOrientation
         fixedCount:(int)count {
    self = [super init];
    if(nil!=self) {
        _cellSpacingHorz =
        _cellSpacingVert = 0;
        _cellSize = cellSize;
        _growingOrientation = growingOrientation;
        _heteroSized = false;
        _fixedSideCount = count;
        _growingSideCount = _maxGrowingSideCount = 0;
        _cellMatrix = [[MICMatrix alloc] init];
        _megaUnitX = _megaUnitY = 1;
    }
    return self;
}

//---------------------------------------------------------------------------------------------------
#pragma mark - オーバーライドが必要なメソッド

/**
 * セル情報インスタンスを生成する。
 */
- (MICUiLayoutCell*)createCell:(UIView*)view {
    return [[MICUiGridCell alloc] initWithView:view unitX:_megaUnitX unitY:_megaUnitX cellStyle:MICUiGlStyleNORMAL];
}

/**
 * ドラッグ情報クラスのインスタンスを作成する。
 */
- (MICUiCellDraggingInfo*) createCellDraggingInfo:(MICUiLayoutCell*) cell  event:(id<MICUiDragEventArg>) eventArg {
    [self unfoldAllGroups]; // indexOfCellする前にunfoldしておく（インデックスがずれないように）
    
    MICUiGridDraggingInfo* dinfo;
    if(nil!=cell) {
        // 自分自身がドラッグソース
        dinfo = [[MICUiGridDraggingInfo alloc] initWithOwner:self
                                                        cell:(MICUiGridCell*)cell
                                               originalIndex:[self indexOfCell:cell]
                                                    children:_children
                                                      matrix:_cellMatrix];
    } else {
        // 外部からセルが持ち込まれる
        dinfo = [[MICUiGridDraggingInfo alloc] initForIncomingCell:self
                                                             event:eventArg
                                                          children:_children
                                                            matrix:_cellMatrix];
    }
    [self calcLayoutOn:dinfo.children matrix:dinfo.cellMatrix];
    return dinfo;
}

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウター セル操作

/**
 * レイアウターにセル（ビュー）を追加する
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加するビュー
 * @param x セルの横方向ユニット数
 * @param y セルの縦方向ユニット数
 * @param style セルスタイル
 */
- (void) addChild:(UIView*)view
            unitX:(int)x
            unitY:(int)y
        cellStyle:(MICUiGridCellStyle) style {
    [self insertChild:view unitX:x unitY:y cellStyle:style before:nil];
}

/**
 * レイアウターに通常スタイルのセル（ビュー）を追加する
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加するビュー
 * @param x セルの横方向ユニット数
 * @param y セルの縦方向ユニット数
 */
- (void) addChild:(UIView*)view
            unitX:(int)x
            unitY:(int)y {
    [self insertChild:view unitX:x unitY:y cellStyle:MICUiGlStyleNORMAL before:nil];
}

/**
 * レイアウターの指定位置にセルを挿入する。
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加（挿入）するビュー
 * @param x セルの横方向ユニット数
 * @param y セルの縦方向ユニット数
 * @param style セルスタイル
 * @param siblingView 挿入位置のビュー（このビューの位置＝このビューの１つ前に挿入する）: nil なら末尾（＝＝addChild)
 */
- (void) insertChild:(UIView *)view
               unitX:(int)x
               unitY:(int)y
           cellStyle:(MICUiGridCellStyle) style
              before:(UIView *)siblingView {

    int fc = x,gc = y;
    if (_growingOrientation==MICUiHorizontal) {
        gc = y;
        fc = x;
    }
    if( fc > _fixedSideCount) {
        [NSException raise:@"MICUiGridLayout" format:@"requested size of child is larger than grid's width."];
    }
    
    MICUiGridCell* cell = [[MICUiGridCell alloc] initWithView:view unitX:x unitY:y cellStyle:style];

    int idx = (nil!=siblingView) ? [self indexOfChild:siblingView] : -1;
    [super insertCell:cell atIndex:idx];
    
    _maxGrowingSideCount += gc;
    if( x != 1 || y != 1 || style == MICUiGlStyleSEPARATOR) {
        _heteroSized = true;
    }
}

/**
 * レイアウターの指定位置に通常スタイルのセルを挿入する。
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加（挿入）するビュー
 * @param x セルの横方向ユニット数
 * @param y セルの縦方向ユニット数
 * @param siblingView 挿入位置のビュー（このビューの位置＝このビューの１つ前に挿入する）: nil なら末尾（＝＝addChild)
 */
- (void) insertChild:(UIView *)view
               unitX:(int)x
               unitY:(int)y
              before:(UIView *)siblingView {
    [self insertChild:view unitX:x unitY:y cellStyle:MICUiGlStyleNORMAL before:siblingView];
}

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウター レンダリング

// 横・縦向きの切り替えを簡便化するマクロ
/** 伸長方向のセルサイズ（unit数）を取得 */
#define GW(cell) ((_growingOrientation==MICUiVertical)?(cell).height:(cell).width)
/** 固定方向のセルサイズ（unit数）を取得 */
#define FW(cell) (((cell).cellStyle==MICUiGlStyleSEPARATOR) ? _fixedSideCount : ((_growingOrientation==MICUiVertical)?(cell).width:(cell).height) )

/** 伸長方向のセル位置を取得 */
#define GP(cell) ((_growingOrientation==MICUiVertical)?(cell).y:(cell).x)
/** 固定方向のセル位置を取得 */
#define FP(cell) ((_growingOrientation==MICUiVertical)?(cell).x:(cell).y)
/** セル位置情報を書き込む */
#define SETP(cell,g,f) { if(_growingOrientation==MICUiVertical) {(cell).x=f,(cell).y=g;} else {(cell).x=g,(cell).y=f;}}


// セルマッピングマトリックスの操作
/** セル座標にマッピング情報を書き込む */
#define MATRIX_PUT(matrix,x,y,v) [matrix setAtX:(x) andY:(y) value:(v)]
/** セル座標からマッピング情報を取得 */
#define MATRIX_GET(matrix,x,y) [matrix getAtX:(x) andY:(y)]

/**
 * セルマッピングマトリックスの指定位置にセルが設定可能かどうか検査する。
 *
 * @param matrix セルマッピングマトリックス
 * @param g 検査する位置（伸長方向のセル座標）
 * @param f 検査する位置（固定方向のセル座標）
 * @param gw 設定したいセルの幅（伸長方向）
 * @param fw 設定したいセルの幅（固定方向）
 * @return true:設定可能　/ false: 他のセルとコンフリクトするか範囲外になるので設定不可能
 */
static bool check_matrix(MICMatrix* matrix, int g, int f, int gw, int fw, int fmax) {
    if(f+fw>fmax) {
        return false;
    }
    for(int i=0;i<gw;i++) {
        for(int j=0;j<fw ;j++){
            if(nil!=MATRIX_GET(matrix,g+i,f+j)) {
                return false;
            }
        }
    }
    return true;
}

/**
 * セルマッピングマトリックスの指定位置にセル情報を書き込む（予約済みにする）
 *
 * @param matrix セルマッピングマトリックス
 * @param g 検査する位置（伸長方向のセル座標）
 * @param f 検査する位置（固定方向のセル座標）
 * @param gw 設定したいセルの幅（伸長方向）
 * @param fw 設定したいセルの幅（固定方向）
 */
static void fill_matrix(MICMatrix* matrix, int g, int f, int gw, int fw, id v) {
    for(int i=0;i<gw;i++) {
        for(int j=0;j<fw;j++){
            MATRIX_PUT(matrix,g+i,f+j, v);
        }
    }
}

/**
 * セルを配置可能な位置を探す。
 *
 * @param matrix セルマッピングマトリックス
 * @param g 検査開始位置（伸長方向のセル座標）
 * @param f 検査開始位置（固定方向のセル座標）
 * @param gw 設定したいセルの幅（伸長方向）
 * @param fw 設定したいセルの幅（固定方向）
 * @param fmax 固定幅方向の最大セル数
 * @param gr 見つかった位置を返すバッファ（伸長方向）
 * @param fr 見つかった位置を返すバッファ（固定方向）
 */
static void find_next_pos(MICMatrix* matrix, int g, int f, int gw, int fw, int fmax, int* gr, int* fr) {
    while(!check_matrix(matrix, g, f, gw, fw, fmax)) {
        f++;
        if( f>=fmax) {
            f = 0;
            g++;
        }
    }
    *gr = g;
    *fr = f;
}

/**
 * セルの配置を計算する。
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 */
- (void) calcLayout {
    if(_needsRecalcLayout) {
        [_cellMatrix reinitWithDimmensionX:_maxGrowingSideCount andY:_fixedSideCount];
        int gcount = [self calcLayoutOn:_children matrix:_cellMatrix];
        if(gcount!=_growingSideCount) {
            _growingSideCount = gcount;
            _contentSizeChanged = true;
        }
        _needsRecalcLayout = false;
    }
}

/**
 * セルの配置を計算し、引数に渡されたmatrixとchildren内のセル情報を更新する。
 */
- (int) calcLayoutOn:(NSMutableArray*) children matrix:(MICMatrix*)matrix {
    int gcount = 0;
    if(_heteroSized) {
        int f=0, g=0;
        for(MICUiGridCell* cell in children) {
            int fw = FW(cell);
            int gw = GW(cell);
            if(cell.cellStyle==MICUiGlStyleSEPARATOR) {
                fw=_fixedSideCount;
            } else if(fw>_fixedSideCount){
                [NSException raise:@"MICUiGridLayout" format:@"requested size of cell is larger than grid's width."];
            }
            
            find_next_pos(matrix,g,f,gw,fw,_fixedSideCount,&g,&f);
            fill_matrix(matrix,g,f,gw,fw,cell);
            SETP(cell,g,f);
            
            if(gcount<g+gw) {
                gcount = g+gw;
            }
        }
    } else {    // homo sized
        gcount = 0;
        int f=0, g=0;
        for(MICUiGridCell* cell in children) {
            if(f>=_fixedSideCount){
                f=0;
                g++;
            }
            SETP(cell,g,f);
            f++;
        }
        gcount = g+1;
    }
    return gcount;
}

/**
 * セル位置（セルの左上）の座標を返す。
 */
- (CGPoint) getCellPosition:(MICUiGridCell*)lcell {
    MICUiGridCell* cell = (MICUiGridCell*)lcell;
    return CGPointMake(_marginLeft + (_cellSize.width+_cellSpacingHorz)*cell.x, _marginTop + (_cellSize.height+_cellSpacingVert)*cell.y);
}

/**
 * セルの一回り（megaUnit分）大きい矩形を取得する。
 */
- (CGRect) getCellExpandRect:(MICUiGridCell*)cell {
    int cellWidth = cell.width;
    int cellHeight = cell.height;
    int x = cell.x;
    int y = cell.y;
    

    x-=_megaUnitX;
    cellWidth+=(_megaUnitX*2);
    y-=_megaUnitY;
    cellHeight+=(_megaUnitY*2);
    return CGRectMake(_marginLeft + (_cellSize.width+_cellSpacingHorz)*x,
                      _marginTop + (_cellSize.height+_cellSpacingVert)*y,
                      (_cellSize.width+_cellSpacingHorz)*cellWidth-_cellSpacingHorz,
                      (_cellSize.height+_cellSpacingVert)*cellHeight-_cellSpacingVert);
}

/**
 * セルの矩形領域を返す。
 */
- (CGRect) getCellRect:(MICUiGridCell*)cell {
    int cellWidth = cell.width;
    int cellHeight = cell.height;
    if( cell.cellStyle == MICUiGlStyleSEPARATOR) {
        if(_growingOrientation==MICUiVertical) {
            cellWidth = _fixedSideCount;
        } else {
            cellHeight = _fixedSideCount;
        }
    }
    return CGRectMake(_marginLeft + (_cellSize.width+_cellSpacingHorz)*cell.x,
                      _marginTop + (_cellSize.height+_cellSpacingVert)*cell.y,
                      (_cellSize.width+_cellSpacingHorz)*cellWidth-_cellSpacingHorz,
                      (_cellSize.height+_cellSpacingVert)*cellHeight-_cellSpacingVert);
}

/**
 * ビュー座標から、セル位置ユニット座標を取得
 */
- (void) cellPosX:(CGFloat)x andY:(CGFloat)y isUnitX:(int*)cx andY:(int*)cy {
    *cx = (int)((x-(_marginLeft-_cellSpacingHorz/2))/(_cellSize.width+_cellSpacingHorz));
    *cy = (int)((y-(_marginTop-_cellSpacingVert/2))/(_cellSize.height+_cellSpacingVert));
}

/**
 * ビュー座標から、セル位置ユニット座標をg/f系値で取得
 */
- (void) cellGFPosX:(CGFloat)x andY:(CGFloat)y isUnitG:(int*)g andF:(int*)f {
    [self cellGFPosX:x andY:y isUnitG:g andF:f needClip:false];
}

/**
 * ビュー座標から、セル位置ユニット座標をg/f系値で取得（有効範囲クリップ機能付き）
 */
- (void) cellGFPosX:(CGFloat)x andY:(CGFloat)y isUnitG:(int*)g andF:(int*)f needClip:(BOOL)clip {
    int cx = (int)((x-(_marginLeft-_cellSpacingHorz/2))/(_cellSize.width+_cellSpacingHorz));
    int cy = (int)((y-(_marginTop-_cellSpacingVert/2))/(_cellSize.height+_cellSpacingVert));
    if(_growingOrientation==MICUiVertical) {
        *g=cy; *f=cx;
    } else {
        *g=cx; *f=cy;
    }
    if(clip) {
        if( *g<0 ) {
            *g = 0;
        } else if (*g>=_maxGrowingSideCount) {
            *g = _maxGrowingSideCount-1;
        }
        if( *f<0) {
            *f = 0;
        } else if( *f>=_fixedSideCount) {
            *f = _fixedSideCount-1;
        }
    }
}


/**
 * セルのヒットテスト
 */
- (MICUiLayoutCell*) hitTestAtX:(CGFloat)x andY:(CGFloat)y {
    int g, f;
    [self cellGFPosX:x andY:y isUnitG:&g andF:&f];
    
    if(_heteroSized) {
        return ([_cellMatrix checkRangeX:g andY:f])?(MICUiGridCell*)MATRIX_GET(_cellMatrix,g,f):nil;
    } else {
        int idx = g*_fixedSideCount + f;
        return (0<=idx && idx<_children.count) ? _children[idx] : nil;
    }
}

/**
 * レイアウター全体のサイズ（マージンも含む）を取得
 */
- (CGSize) getSize {
    if(_needsRecalcLayout) {
        [self calcLayout];
    }
    int w = _fixedSideCount, h=_growingSideCount;
    if( _growingOrientation == MICUiHorizontal) {
        w = _growingSideCount; h = _fixedSideCount;
    }
    return CGSizeMake(_marginLeft + _cellSize.width*w +_cellSpacingHorz*(w>0?w-1:0) + _marginRight,
                      _marginTop + _cellSize.height*h +_cellSpacingVert*(h>0?h-1:0) + _marginBottom);
}

/**
 * レイアウターのマージンを除く、正味のコンテント領域の領域を取得する。
 *
 * @return  コンテナビュー座標系（bounds内）での矩形領域（ヒットテストなどに利用されることを想定）。
 */
- (CGRect) getContentRect {
    if(_needsRecalcLayout) {
        [self calcLayout];
    }
    MICRect rc(CGPointZero, [self getSize]);
    MICEdgeInsets margin(_marginLeft,_marginTop,_marginRight,_marginBottom);
    return rc - margin;
}

/**
 * レイアウター上のセル（ビュー）を指定位置に移動する。
 * このメソッドは表示を更新しない。
 *
 * @param from      移動元のインデックス
 * @param to        移動後のインデックス
 */
- (BOOL) moveChild:(NSInteger)from
                to:(NSInteger)to {
    if(from!=to) {
        id cell = _children[from];
        [_children removeObjectAtIndex:from];
        [_children insertObject:cell atIndex:to];
        _needsRecalcLayout = true;
        return true;
    } else {
        return false;
    }
}

/**
 * セルが画面内に入るようスクロールする。
 */
- (void) ensureCellVisible:(MICUiLayoutCell*)cell {
    [self ensureCellVisible:cell justSize:false];
}

/**
 * セルが画面内に入るようスクロールする。
 * @param   exact       true:セルが入る最小サイズ / false:セル周辺（megaUnit分大きいサイズ）
 */
- (void) ensureCellVisible:(MICUiLayoutCell*)cell justSize:(BOOL)exact {
    if(![cell isKindOfClass:MICUiGridCell.class]) {
        return;
    }
    if(nil!=_layoutDelegate) {
        CGRect rc = (exact) ? [self getCellRect:(MICUiGridCell*)cell] : [self getCellExpandRect:(MICUiGridCell*)cell];
        [_layoutDelegate ensureRectVisible:self rect:rc];
    }
    
}

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウター ドラッグ＆ドロップ

/**
 * ドラッグ前の状態に戻す
 */
- (BOOL) resetDrag:(id<MICUiDragEventArg>) eventArg {
    MICUiGridDraggingInfo* dinfo = (MICUiGridDraggingInfo*)_draggingInfo;
    MICUiGridCell* cell = (MICUiGridCell*)dinfo.draggingCell;

    int srcIndex = [self indexOfCell:cell];
    if(srcIndex>=0 && srcIndex != dinfo.orgIndex) {
        if([self moveChild:srcIndex to:dinfo.orgIndex]) {
            [self calcLayout];
            [self updateLayout:true onCompleted:^(BOOL finished) {
                [self ensureCellVisible:cell justSize:true];
            }];
        }
    }
    return false;
}

/**
 * セル配列内のセルのインデックスを返す
 * @return インデックス（見つからなければ−１）
 */
static int indexOfCell(NSArray* ary, id cell) {
    NSInteger idx = [ary indexOfObject:cell];
    return ( idx == NSNotFound) ? -1 : (int)idx;
}

/**
 * 与えられた矩形領域と、最も重なり面積の大きい箇所のセル配列内でのインデックスを取得
 */
- (int) hitTestWithRect:(CGRect) rect on:(MICMatrix*)matrix from:(NSMutableArray*)children {
    
    int gs, fs, ge, fe;
    
    [self cellGFPosX:rect.origin.x andY:rect.origin.y isUnitG:&gs andF:&fs];
    [self cellGFPosX:rect.origin.x+rect.size.width andY:rect.origin.y+rect.size.height isUnitG:&ge andF:&fe];

    if(gs<0) {
        gs = 0;
    } else if( gs>=_growingSideCount) {
        gs = _growingSideCount-1;
    }
    if(ge<0) {
        ge = 0;
    } else if( ge>=_growingSideCount) {
        ge = _growingSideCount-1;
    }
    if(gs>ge) {
        int x = ge;
        ge = gs;
        gs = x;
    }

    if(fs<0) {
        fs = 0;
    } else if( fs>=_fixedSideCount) {
        fs = _fixedSideCount-1;
    }
    if(fe<0) {
        fe = 0;
    } else if( fe>=_fixedSideCount) {
        fe = _fixedSideCount-1;
    }
    if(fs>fe) {
        int x = fe;
        fe = fs;
        fs = x;
    }
    
    
    CGFloat max = 0;
    MICUiGridCell* cell = nil;
    NSMutableSet* cellSet = [[NSMutableSet alloc] initWithCapacity:(ge-gs+1)*(fe-fs+1)];
//    NSLog(@"HitTest: (%d,%d)-(%d,%d)", fs+1, gs+1, fe+1, ge+1);
    
    if(_heteroSized) {
        for(int g=gs;g<=ge;g++) {
            for(int f=fs;f<=fe;f++) {
                if([matrix checkRangeX:g andY:f]) {
                    MICUiGridCell* c = MATRIX_GET(matrix, g, f);
                    if(nil!=c) {
                        if(![cellSet containsObject:c]) {
                            [cellSet addObject:c];
                            //[self dumpCell:cell prefix:@"intersection:"];
                            CGRect rc = CGRectIntersection([self getCellRect:c], rect);
                            CGFloat s = rc.size.height*rc.size.width;
//                            [self dumpCell:c prefix:@"hitTest" s:s];
                            if(s>max) {
                                max = s;
                                cell = c;
                            }

                        }
                    }
                }
            }
        }
    } else {
        for(int g=gs ; g<=ge; g++ ) {
            for(int f=fs ; f<=fe ; f++) {
                int idx = g*_fixedSideCount + f;
                if (0<=idx && idx<children.count) {
                    MICUiGridCell* c = children[idx];
                    [cellSet addObject:c];
                    //[self dumpCell:cell prefix:@"intersection:"];
                    CGRect rc = CGRectIntersection([self getCellRect:c], rect);
                    CGFloat s = rc.size.height*rc.size.width;
//                    [self dumpCell:c prefix:@"hitTest" s:s];
                    if(s>max) {
                        max = s;
                        cell = c;
                    }
                }
            }
        }
    }
    
    
    if( nil!=cell) {
        CGRect rc = [self getCellRect:cell];
        if( max > rc.size.width*rc.size.height*0.4) {
//            NSLog(@"hitTest: match hit.");
            return indexOfCell(children, cell);
        }
        // ヒット率が小さいときは（もしあれば）中央のセルを採用
        int gc = round(((float)gs+(float)ge)/2);
        int fc = round(((float)fs+(float)fe)/2);
        cell = MATRIX_GET(matrix, gc, fc);
        if(nil!=cell) {
//            NSLog(@"hitTest: center cell.");
            return indexOfCell(children, cell);
        }
    }

    // ここに入ってくるのは、空白セル上にドラッグされたとき。
    // 左側にセルがあれば、その位置を、なければ、右側のセル位置を返す。
    for(int f=fe ; f<_fixedSideCount ; f++) {
        cell = MATRIX_GET(matrix, gs, f);
        if( cell != nil) {
//            NSLog(@"hitTest: left cell.");
            return indexOfCell(children, cell);
        }
    }
    for(int f=fs-1 ; f>=0 ; f-- ) {
        cell = MATRIX_GET(matrix, gs, f);
        if( cell != nil) {
//            NSLog(@"hitTest: right cell.");
            return indexOfCell(children, cell)+1;
        }
    }
    //NSLog(@"HitTest: not found.");
    return -1;
}

/**
 * ドラッグ操作の中の人
 */
- (BOOL) doDrag:(id<MICUiDragEventArg>) eventArg {
    MICUiGridDraggingInfo* dinfo = (MICUiGridDraggingInfo*)_draggingInfo;
    if(dinfo.children.count != _children.count) {
        [NSException raise:@"dragTo" format:@"logic error."];
    }
    
    MICUiGridCell* cell = (MICUiGridCell*)dinfo.draggingCell;
    //
    //    // 移動後（アニメーション完了後）のセルViewの矩形領域を計算する。
    //    CGRect movingRect = [eventArg getViewFrameOn:self];
    //    CGPoint movingCenter =[eventArg getViewCenterOn:self];
    //    CGPoint touchPos = [eventArg touchPosOn:self];
    //    movingRect.origin.x += (touchPos.x - movingCenter.x);
    //    movingRect.origin.y += (touchPos.y - movingCenter.y);
    //
    //    // セルViewをアニメーション内で移動
    //    [UIView animateWithDuration:0.1
    //                          delay:0
    //                        options:UIViewAnimationOptionCurveLinear
    //                     animations:^{
    //                         cell.view.center = eventArg.touchPosOnOverlay;
    //                     } completion:nil];
    
    CGRect movingRect = [eventArg getViewFrameOn:self];
    int idx = [self hitTestWithRect:movingRect on:dinfo.cellMatrix from:dinfo.children];
    if(idx<0) {
        //NSLog(@"dragTo: cell not found.");
        return false;
    }
    if(idx==dinfo.currentIndex){
        //NSLog(@"dragTo: same position.");
//        if(nil!=_layoutDelegate) {
//            MICUiGridCell* anchor = (MICUiGridCell*)[self findCell:[dinfo.children[idx] view]];
//            //            [self dumpCell:anchor prefix:@"anchor cell"];
//            CGRect rc1 = [self getCellExpandRect:anchor];
//            CGRect rc2 = [self getCellExpandRect:cell];
//            CGRect rc = CGRectUnion(rc1, rc2);
//            if(!CGRectEqualToRect(rc, _draggingInfo.prevVisibleRect)) {
//                _draggingInfo.prevVisibleRect = rc;
//                [_layoutDelegate ensureRectVisible:self rect:rc];
//            }
//        }
        return false;
    }
    
    [_children removeObjectAtIndex:dinfo.currentIndex];
    [_children insertObject:cell atIndex:idx];
    dinfo.currentIndex = idx;
    return true;
}

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウター グループの折りたたみ

/**
 * セパレータで指定されたグループ（そのセパレータから次のセパレータまで）を折りたたむ。
 */
- (void)foldGroup:(UIView*)cellView {
    if(self.dragging) {
        return;
    }
    int idx = [self indexOfChild:cellView];
    if( idx<0 || _children.count <= idx ) {
//        NSLog(@"MICUiGridLayout#getGroupSeparator: invalid index.");
    }
    MICUiGridCell* sep = _children[idx];
    if(sep.cellStyle != MICUiGlStyleSEPARATOR) {
//        NSLog(@"MICUiGridLayout#getGroupSeparator: not separator.");
        return;
    }

    if(nil!=[sep foldingCells]) {
        NSLog(@"MICUiGridLayout#foldGroup: specified group has been already folded.");
        return;
    }
    
    int count = (int)_children.count;
    NSMutableArray* ary = [[NSMutableArray alloc] initWithCapacity:count];
    
    for(int i=idx+1 ; i<count ; i++ ) {
        MICUiGridCell* cell = _children[i];
        if( cell.cellStyle == MICUiGlStyleSEPARATOR) {
            break;
        }
        [ary addObject:cell];
    }
    
    int len = (int)ary.count;
    if( len == 0 ) {
        return;
    }

    [sep setFoldingCells:ary];

    [_children removeObjectsInRange:NSMakeRange(idx+1, len)];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         for(int i=(int)ary.count-1 ; i>=0 ; i--) {
                             ((MICUiGridCell*)ary[i]).view.alpha=0;
                         }
                     } completion:^(BOOL finished){
                         for(int i=(int)ary.count-1 ; i>=0 ; i--) {
                             ((MICUiGridCell*)ary[i]).view.hidden = true;
                         }
                     }];
    _needsRecalcLayout = true;
    [self updateLayout:true onCompleted:nil];
}

/**
 * (PRIVATE) 折りたたまれたグループを開く
 */
- (void)unfoldGroup:(MICUiGridCell*)sep index:(int)idx updateView:(BOOL)update animation:(BOOL)animation {
    NSArray* ary = [sep foldingCells];
    if(nil==ary) {
        NSLog(@"MICUiGridLayout#foldGroup: specified group has not been folded.");
        return;
    }
    
    [_children insertObjects:ary atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(idx+1, ary.count)]];
    for(int i=(int)ary.count-1 ; i>=0 ; i--) {
        ((MICUiGridCell*)ary[i]).view.hidden = false;
    }
    [sep setFoldingCells:nil];
    if( animation ) {
        [UIView animateWithDuration:0.2
                              delay:0.3
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             for(int i=(int)ary.count-1 ; i>=0 ; i--) {
                                 ((MICUiGridCell*)ary[i]).view.alpha=1;
                             }
                         }
                         completion:nil];
    } else {
        for(int i=(int)ary.count-1 ; i>=0 ; i--) {
            ((MICUiGridCell*)ary[i]).view.alpha=1;
        }
    }
    _needsRecalcLayout = true;
    
    if( update) {
        [self updateLayout:true onCompleted:nil];
    }
}

/**
 * 折りたたまれたグループを開く
 */
- (void)unfoldGroup:(UIView*)cellView {
    if(self.dragging) {
        return;
    }
    int idx = (int)[self indexOfChild:cellView];
    if(idx<0) {
        return;
    }
    MICUiGridCell* sep = _children[idx];
    [self unfoldGroup:sep index:idx updateView:true animation:true];
}

/**
 * グループは折りたたまれているか？
 */
- (BOOL)isFolded:(UIView*)cellView {
    int idx = (int)[self indexOfChild:cellView];
    if(idx<0) {
        return false;
    }
    MICUiGridCell* sep = _children[idx];
    if( sep.cellStyle != MICUiGlStyleSEPARATOR) {
        return false;
    }
    
    return [sep foldingCells]!=nil;
}

/**
 * グループの折りたたみ状態をトグルする
 */
- (void)toggleGroupFolding:(UIView *)cellView {
    if(self.dragging) {
        return;
    }
    if( [self isFolded:cellView]) {
        [self unfoldGroup:cellView];
    } else {
        [self foldGroup:cellView];
    }
}

/**
 * 折りたたまれたグループをすべて開く
 */
- (void) unfoldAllGroups {
    bool update = false;
    MICUiGridCell* cell;
    for(int i=0, ci=(int)_children.count ; i<ci ; i++ ) {
        cell = _children[i];
        if(cell.cellStyle == MICUiGlStyleSEPARATOR && [cell foldingCells]!=nil) {
            [self unfoldGroup:cell index:i updateView:false animation:true];
            update = true;
        }
    }
    if(update){
        [self updateLayout:true onCompleted:nil];
    }
}

@end


