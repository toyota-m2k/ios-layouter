//
//  WPLGrid.m
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLGrid.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"

#pragma mark - Inner Class

/**
 * WPLCell.extension にセットされるGridの管理情報クラス
 */
@interface WPLGridExtension : NSObject
    @property (nonatomic, readonly) NSInteger row;
    @property (nonatomic, readonly) NSInteger column;
    @property (nonatomic, readonly) NSInteger rowSpan;
    @property (nonatomic, readonly) NSInteger colSpan;
    @property (nonatomic) CGSize size;
@end

@implementation WPLGridExtension
- (instancetype) initRow:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger) rowSpan colSpan:(NSInteger)colSpan {
    self = [super init];
    if(nil!=self) {
        _row = row;
        _column = column;
        _rowSpan = rowSpan;
        _colSpan = colSpan;
        _size = MICSize();
    }
    return self;
}

+ (instancetype) newWithRow:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger) rowSpan colSpan:(NSInteger)colSpan {
    return [[self alloc] initRow:row column:column rowSpan:rowSpan colSpan:colSpan];
}

- (NSInteger) posForCol:(bool)forCol {
    return (forCol) ? self.column : self.row;
}

- (NSInteger) spanForCol:(bool)forCol {
    return (forCol) ? self.colSpan : self.rowSpan;
}

- (CGFloat) sSizeForCol:(bool) forCol {
    return (forCol) ? self.size.width : self.size.height;
}

// fun xSize(forCol:Boolean) : Float {
//     return if(forCol) size.height else size.width
// }
@end

#pragma mark - Utility Functions

static inline WPLGridExtension* EXT(id<IWPLCell> cell)   { return (WPLGridExtension*)cell.extension; }

static inline CGFloat GET_FLOAT(NSArray<NSNumber*>* ary, NSInteger index) {
    return [ary[index] floatValue];
}

static inline void SET_FLOAT(NSMutableArray<NSNumber*>* ary, NSInteger index, CGFloat v) {
    ary[index] = [NSNumber numberWithFloat:v];
}

static CGFloat sumRange(NSArray<NSNumber*>* ary, NSInteger from=0, NSInteger count=-1) {
    if(count<0) {
        count = ary.count;
    }
    CGFloat sum = 0;
    for(NSInteger i=0 ; i<count; i++) {
        sum += [ary[from+i] floatValue];
    }
    return sum;
}

static void clearRange(NSMutableArray<NSNumber*>* ary, NSInteger from=0, NSInteger count=-1) {
    if(count<0) {
        count = ary.count;
    }
    for(NSInteger i =0 ; i<count ; i++) {
        ary[from+i] = @(0);
    }
}

static NSMutableArray<NSNumber*>* zeroArray( NSInteger count) {
    let ary = [NSMutableArray arrayWithCapacity:count];
    for(NSInteger i=0 ; i<count ; i++) {
        [ary addObject:@(0)];
    }
    return ary;
}

#pragma mark - WPLGrid クラス

/**
 * Row/Column でレイアウト可能なコンテナセルクラス
 */
@implementation WPLGrid {
    // Row/Column definitions
    NSArray<NSNumber*>* _rowDefs;
    NSArray<NSNumber*>* _colDefs;
    
    // カラムの幅を計算するための配列
    NSMutableArray<NSNumber*>* _rowHeights;
    NSMutableArray<NSNumber*>* _columnWidths;
    
    CGSize _cachedSize;
    
    CGSize _cellSpacing;
}

static NSArray<NSNumber*>* s_single_def_auto = @[@(0)];
static NSArray<NSNumber*>* s_single_def_stretch = @[@(-1)];

/**
 * WPLCell.initWithView のオーバーライド
 */
- (instancetype) initWithView:(UIView *)view
                         name:(NSString *)name
                       margin:(UIEdgeInsets)margin
              requestViewSize:(CGSize)requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    return [self initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate rowDefs:nil colDefs:nil cellSpacing:MICSize()];
}

/**
 * Gridの正統なコンストラクタ
 */
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                      rowDefs:(NSArray<NSNumber*>*) rowDefs
                      colDefs:(NSArray<NSNumber*>*) colDefs
                  cellSpacing:(CGSize)cellSpacing {
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
    if(nil!=self) {
        _cachedSize = MICSize();
        _cellSpacing = cellSpacing;
        
        // row/column definitions が省略されているときは、１x１グリッドとして定義を自動生成
        // このとき、requestViewSizeが固定サイズなら、それに合わせて中身を伸縮（stretch)
        //         requestViewSize == 0 （auto) なら、中身のサイズを変えずに、Gridの方を伸縮する。
        // この動作を変更したければ、１x１でも、明示的に、row/column definitions を指定すること。
        _rowDefs = (rowDefs!=nil&&rowDefs.count>0) ? rowDefs : (requestViewSize.height>0 ? s_single_def_stretch : s_single_def_auto);
        _colDefs = (colDefs!=nil&&colDefs.count>0) ? colDefs : (requestViewSize.width>0  ? s_single_def_stretch : s_single_def_auto);
        
        _columnWidths = zeroArray(_colDefs.count);
        _rowHeights = zeroArray(_rowDefs.count);
    }
    return self;
}

/**
 * インスタンス生成ヘルパー
 * Grid用UIViewを自動生成して、superviewにaddSubviewする。
 */
+ (instancetype) gridWithName:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                      rowDefs:(NSArray<NSNumber*>*) rowDefs
                      colDefs:(NSArray<NSNumber*>*) colDefs
                  cellSpacing:(CGSize)cellSpacing
                    superview:(UIView*)superview{
    let view = [UIView new];
    if(nil!=superview) {
        [superview addSubview:view];
    }
    return [[WPLGrid alloc] initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment
                              vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate rowDefs:rowDefs colDefs:colDefs cellSpacing:cellSpacing];
}

/**
 * C++用インスタンス生成ヘルパー
 * Grid用UIViewを自動生成して、superviewにaddSubviewする。
 * (Root Container用）
 */
+ (instancetype) gridWithName:(NSString*) name
                       params:(const WPLGridParams&) params
                    superview:(UIView*)superview
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    return [self gridWithName:name margin:params._margin requestViewSize:params._requestViewSize hAlignment:params._align.horz vAlignment:params._align.vert visibility:params._visibility containerDelegate:containerDelegate rowDefs:params._dimension.rowDefs colDefs:params._dimension.colDefs cellSpacing:params._cellSpacing superview:superview];
}

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) gridWithName:(NSString*) name
                       params:(const WPLGridParams&) params {
    return [self gridWithName:name params:params superview:nil containerDelegate:nil];
}

/**
 * requestViewSize プロパティのセッターをオーバーライド
 */
- (void)setRequestViewSize:(CGSize)requestViewSize {
    if(MICSize(requestViewSize)!=self.requestViewSize) {
        // 自動生成された row/column definitions があれば、initWithView内のコメントに合致するように更新する
        if(self.rows==1 && (_rowDefs==s_single_def_stretch||_rowDefs==s_single_def_auto)) {
            _rowDefs = requestViewSize.height>0 ? s_single_def_stretch : s_single_def_auto;
        }
        if(self.columns==1 && (_colDefs==s_single_def_stretch||_colDefs==s_single_def_auto)) {
            _colDefs = requestViewSize.width>0  ? s_single_def_stretch : s_single_def_auto;
        }

        [super setRequestViewSize:requestViewSize];
    }
}

// 行数
- (NSInteger) rows {
    return _rowDefs.count;
}
// カラム数
- (NSInteger) columns {
    return _colDefs.count;
}

- (CGSize) cellSpacing {
    return _cellSpacing;
}

- (void) setCellSpacing:(CGSize)cellSpacing {
    if(MICSize(_cellSpacing)!=cellSpacing) {
        _cellSpacing = cellSpacing;
        self.needsLayout = true;
    }
}

- (void) addCell:(id<IWPLCell>)cell {
    [self addCell:cell row:0 column:0 rowSpan:1 colSpan:1];
}
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column {
    [self addCell:cell row:row column:column rowSpan:1 colSpan:1];
}

- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan {
    if(rowSpan<1) {
        rowSpan = 1;
    }
    if(colSpan<1) {
        colSpan = 1;
    }
    if (row+rowSpan-1 >= self.rows || column+colSpan-1 >= self.columns) {
        [NSException raise:NSRangeException format:@"WPLGrid.addCell: out of range (%ld,%ld).", (long)self.rows, (long)self.columns];
    }
    
    cell.extension = [WPLGridExtension newWithRow:row column:column rowSpan:rowSpan colSpan:colSpan];
    [super addCell:cell];
}

- (void) addCell:(id<IWPLCell>)cell params:(const WPLGridAddCellParams&) params {
    [self addCell:cell row:params._row column:params._column rowSpan:params._rowSpan colSpan:params._colSpan];
}


//- (CGFloat) sumRange:(NSArray<NSNumber*>*) ary from:(NSInteger)from count:(NSInteger)count {
//    if(count<0) {
//        count = ary.count;
//    }
//    CGFloat sum = 0f;
//    for(NSInteger i=0 ; i<count; i++) {
//        sum += [ary[from+i] floatValue];
//    }
//    return sum;
//}
//
//- (void) clearRange:(NSMutableArray<NSNumber*>*)ary from:(NSInteger)from count:(NSInteger)count {
//    if(count<0) {
//        count = ary.count;
//    }
//    for(NSInteger i =0 ; i<count ; i++) {
//        ary[from+i] = @(0f);
//    }
//}
//
//- (void) fillZero:(NSMutableArray<NSNumber*>*)ary count:(NSInteger)count {
//    for(NSInteger i=0 ; i<count ; i++) {
//        [ary addObject:@(0f)];
//    }
//}

/**
 * セルマージンを含むセルサイズを計算する
 * 各セルに対して、calcMinSizeFor... を呼び出してセルが管理しているサイズを取得し、それに対してセルマージンを付加して返す。
 * セルマージンは、各セルの右下についているものとし、右端、下端のセルは、セルマージンがゼロになるよう除外処理を入れる
 */
- (void) calcGellSizeWithCellSpacing:(id<IWPLCell>)cell {
    MICSize size;
    let ex = EXT(cell);
    if(cell.visibility!=WPLVisibilityCOLLAPSED) {
        size = [cell calcMinSizeForRegulatingWidth:(ex.colSpan>1) ? 0 : GET_FLOAT(_colDefs, ex.column)
                                    andRegulatingHeight:(ex.rowSpan>1) ? 0 : GET_FLOAT(_rowDefs, ex.row) ] ;
        if(ex.column+ex.colSpan < self.columns) {
            size.width += _cellSpacing.width;
        }
        if(ex.row+ex.rowSpan < self.rows) {
            size.height += _cellSpacing.height;
        }
    }
    ex.size = size;
}

/**
 * cell.extension に保持しているセルマージンを含むセルサイズから、セルマージンを除外した正味のセルサイズを取得する。
 */
- (CGSize) trimCellSpacing:(id<IWPLCell>)cell width:(CGFloat)width height:(CGFloat)height {
    MICSize size;
    if(cell.visibility!=WPLVisibilityCOLLAPSED) {
        let ex = EXT(cell);
        size.set(width,height);
        if(ex.column+ex.colSpan < self.columns) {
            size.width -= _cellSpacing.width;
        }
        if(ex.row+ex.rowSpan < self.rows) {
            size.height -= _cellSpacing.height;
        }
    }
    return size;
}

/**
 * すべてのセルのminSize を計算して、GridExtensionにセットする
 * グリッドセルのサイズが固定の場合は無駄になるかもしれないが、Row/Columnのどちらかで必要になるケースもあるので、
 * とにかく全部計算しておく。
 */
- (void) pass1_initParams {
    _cachedSize.width = 0;
    _cachedSize.height = 0;
    for(id<IWPLCell> c in self.cells) {
        [self calcGellSizeWithCellSpacing:c];
    }
}

/**
 * Row/Columnの必要最小限の幅/高さを計算する
 * Span>1 のセルは、ここでは除外しておく --> pass4
 */
- (bool) pass2_getMinSizeForCol:(bool)forCol sizes:(NSMutableArray<NSNumber*>*)sizes {
    let defs = (forCol) ? _colDefs : _rowDefs;
    bool span = false;
    for(id<IWPLCell> c in self.cells) {
        if(c.visibility==WPLVisibilityCOLLAPSED) {
            continue;
        }
        let ex = EXT(c);
        NSInteger pos = [ex posForCol:forCol];
        
        CGFloat fval = GET_FLOAT(defs, pos);
        if (fval > 0) {
            // グリッドカラムの高さ/幅が固定値で指定されている
            SET_FLOAT(sizes, pos, fval);
        } else if ([ex spanForCol:forCol] == 1) {  // span>1 のものは除外
            SET_FLOAT(sizes, pos, MAX(GET_FLOAT(sizes, pos), MAX(fval, [ex sSizeForCol:forCol])));
        } else {
            span = true;
        }
    }
    return span;
}

/**
* STRETCH指定のセル幅を計算する
*
* fixWidth/Height が有効な場合は、stretchedでないセルのサイズ（pass2で計算）を除いた残りの領域から比例配分する
* それ以外の場合は、比例配分した結果がpass2で計算された幅すべて収まる最小サイズになるよう調整する
*/
- (void) pass3_calcStretchedCellForCol:(bool)forCol sizes:(NSMutableArray<NSNumber*>*)sizes fix:(CGFloat)fix {
    let defs = (forCol) ? _colDefs : _rowDefs;
    
    CGFloat sum = 0;
    CGFloat base = 0;
    CGFloat occupied = 0;
    for(NSInteger i = 0 ; i<defs.count ; i++) {
        CGFloat fval = GET_FLOAT(defs, i);
        if(fval<0) {
            sum += ABS(fval);
            base = MAX(base, GET_FLOAT(sizes, i) / abs(fval));
        } else {
            occupied += GET_FLOAT(sizes, i);
        }
    }
    if(sum==0) {
        return;
    }
    
    if(fix>0) {
        // グリッドの幅または高さが固定されている場合
        let remained = fix - occupied;
        if(remained>0) {
            for (NSInteger i = 0 ; i< defs.count ; i++) {
                CGFloat fval = GET_FLOAT(defs,i);
                if ( fval < 0) {
                    SET_FLOAT(sizes, i, ABS(fval) *remained/sum);
                }
            }
        }
    } else {
        // グリッドの幅・高さが固定されていない場合、すべてのSTRETCHEDセルが収まり、且つ、比率が指定通りになるサイズに伸縮する
        for (NSInteger i=0 ; i<defs.count ; i++) {
            CGFloat fval = GET_FLOAT(defs, i);
            if (fval < 0) {
                SET_FLOAT(sizes, i, base * ABS(fval));
            }
        }
    }
}

/**
* pass3までに決まったサイズをもとに、Span指定のセルのサイズを計算する。
* このとき、Span後のサイズより、セルの最小サイズが大きい場合で、fixWidth/Heightでない場合は、セルを拡張するが、
* この場合は、指定比率になるよう、もう一度、pass3 を実行する。
*/
- (void) pass4_calcSpannedCellsForCol:(bool)forCol sizes:(NSMutableArray<NSNumber*>*) sizes fix:(CGFloat)fix {
    bool expansion = false;
    for(id<IWPLCell> c in self.cells) {
        if(c.visibility == WPLVisibilityCOLLAPSED) {
            continue;
        }
        let ex = EXT(c);
        NSInteger span = [ex spanForCol:forCol];
        if(span>1) {
            NSInteger pos = [ex posForCol:forCol];
            CGFloat ss = sumRange(sizes, pos, span);
            CGFloat sa = [ex sSizeForCol:forCol];
            if (ss > 0 && ss < sa) {
                if (fix <= 0) {
                    expansion = true;
                    for (NSInteger i = 0 ; i<span; i++) {
                        SET_FLOAT(sizes, pos+i, GET_FLOAT(sizes,i) * sa/ss);
                    }
                }
            }
        }
    }
    if(expansion) {
        [self pass3_calcStretchedCellForCol:forCol sizes:sizes fix:fix];
    }
}

/**
 * セルを配置する
 * widths/heights に入っている各column/rowの幅・高さの計算結果を、セルに反映する
 */
- (void) pass5_finalizeInWidths:(NSArray<NSNumber*>*)widths andHeights:(NSArray<NSNumber*>*)heights {
    for(id<IWPLCell> c in self.cells) {
        let ex = EXT(c);
        MICSize size([self trimCellSpacing:c width:sumRange(widths, ex.column, ex.colSpan) height:sumRange(heights, ex.row, ex.rowSpan)]);
        MICPoint point(sumRange(widths, 0, ex.column), sumRange(heights, 0, ex.row));
        [c layoutResolvedAt:point inSize:size];
    }
}

/**
 * カラムのサイズ計算（セルの配置は行わない）
 * @return Grid全体の幅
 */
- (CGFloat) calcColumnWidth:(CGFloat) fix {
    clearRange(_columnWidths);
    bool spanCol = [self pass2_getMinSizeForCol:true sizes:_columnWidths];
    [self pass3_calcStretchedCellForCol:true sizes:_columnWidths fix:fix];
    if (spanCol) {
        [self pass4_calcSpannedCellsForCol:true sizes:_columnWidths fix:fix];
    }
    return (fix > 0) ? fix : sumRange(_columnWidths);
}

/**
 * 行のサイズ計算（セルの配置は行わない）
 * Pass-2 ～ 4
 * @return Grid全体の高さ
 */
- (CGFloat) calcRowHeight:(CGFloat) fix {
    clearRange(_rowHeights);
    bool spanRow = [self pass2_getMinSizeForCol:false sizes:_rowHeights];
    [self pass3_calcStretchedCellForCol:false sizes:_rowHeights fix:fix];
    if (spanRow) {
        [self pass4_calcSpannedCellsForCol:false sizes:_rowHeights fix:fix];
    }
    return (fix > 0) ? fix : sumRange(_rowHeights);
}

/**
 * キャッシュサイズが確定していない場合（cachedSize.width/height==0f）には、サイズを計算する(Pass2 ～ Pass4)。
 * 計算結果に基づいて、セルを配置する(Pass5)。
 */
- (CGSize) innerLayout:(CGSize) fixSize {
    if(_cachedSize.width==0) {
        _cachedSize.width = [self calcColumnWidth:fixSize.width];
    }
    if(_cachedSize.height==0) {
        _cachedSize.height = [self calcRowHeight:fixSize.height];
    }
    [self pass5_finalizeInWidths:_columnWidths andHeights:_rowHeights];
    self.needsLayoutChildren = false;
    return _cachedSize;
}

/**
 * レイアウトを開始（ルートコンテナの場合のみ呼び出される）
 */
- (CGSize) layout {
    if(self.needsLayoutChildren) {
        [self pass1_initParams];
        [self innerLayout:self.requestViewSize];
        
        if(MICSize(_cachedSize)!=self.view.frame.size) {
            self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
        }
    }
    self.needsLayout = false;
    return MICSize(_cachedSize) + self.margin;
}

/**
 * セルサイズを計算する
 * 実際には、requestViewSizeベースでlayoutを実行して、そのサイズを返す
 */
- (CGSize) calcMinSizeForRegulatingWidth:(CGFloat) regulatingWidth andRegulatingHeight:(CGFloat) regulatingHeight {
    if(self.needsLayoutChildren) {
        [self pass1_initParams];
        MICSize fixSize( (self.requestViewSize.width>0) ? self.requestViewSize.width : regulatingWidth,
                        (self.requestViewSize.height>0) ? self.requestViewSize.height : regulatingHeight );
        [self innerLayout:fixSize];
    }
    return MICSize(_cachedSize)+self.margin;
}

/**
 * セルの位置・サイズ確定
 */
- (void) layoutResolvedAt:(CGPoint)point inSize:(CGSize)size {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }

    NSAssert(!self.needsLayoutChildren, @"layout must be calculated.");
    // STRETCH の場合に、与えられたサイズを使って配置を再計算する
    MICSize viewSize(MICSize(size) - self.margin);
    if(viewSize.width!=_cachedSize.width && self.hAlignment == WPLCellAlignmentSTRETCH && self.requestViewSize.width == 0) {
        _cachedSize.width = 0;
    }
    if(viewSize.height!=_cachedSize.height && self.vAlignment == WPLCellAlignmentSTRETCH && self.requestViewSize.height==0) {
        _cachedSize.height = 0;
    }
    if(_cachedSize.width==0||_cachedSize.height==0) {
        [self innerLayout:viewSize];
    }
    if (MICSize(_cachedSize) != self.view.frame.size) {
        // [super layoutResolvedAt:] は、view のサイズから配置計算するので、その前に、viewのサイズを設定しておく
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    [super layoutResolvedAt:point inSize:size];
}
@end
