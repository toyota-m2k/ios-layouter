//
//  WPLGrid.mm
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/03.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//


#import "WPLGrid.h"
#import "MICVar.h"
#import "WPLContainersL.h"
#import "WPLGridCellLocator.h"
#import "MICDicUtil.h"
#import <vector>

#ifdef DEBUG
@interface WPLInternalGridView : UIView
@end
@implementation WPLInternalGridView
@end
#else
#define WPLInternalGridView UIView
#endif

/**
 * Row/Columnを区別する定義
 * ... bool でもよいのだが、視認性が悪いので、あえてラベルを定義
 */
enum RowColumn {
    ROW = 0,
    COL = 1,
};

/**
 * WPLCell.extension にセットされるGridの管理情報クラス
 */
@interface WPLGridExtension : NSObject
    @property (nonatomic, readonly) NSInteger row;
    @property (nonatomic, readonly) NSInteger column;
    @property (nonatomic, readonly) NSInteger rowSpan;
    @property (nonatomic, readonly) NSInteger colSpan;
//    @property (nonatomic) CGSize size;
//    @property (nonatomic) bool rowComp;
//    @property (nonatomic) bool colComp;
    @property (nonatomic, readonly) WPLCellPosition cellPosition;
@end

/**
 * 子セルに持たせる情報
 */
@implementation WPLGridExtension

- (instancetype) initWithPosition:(const WPLCellPosition&) pos {
    self = [super init];
    if(nil!=self) {
        _row = pos.row;
        _column = pos.column;
        _rowSpan = pos.rowSpan;
        _colSpan = pos.colSpan;
    }
    return self;
}

- (WPLCellPosition)cellPosition {
    return WPLCellPosition(_row, _column, _rowSpan, _colSpan);
}

- (NSInteger) index:(RowColumn) rc {
    return rc==COL ? _column : _row;
}

- (NSInteger) span:(RowColumn) rc {
    return rc==COL ? _colSpan : _rowSpan;
}

@end

/**
 * colSpan/rowSpanを解決するために一時的に値を保持しておくためのクラス
 */
@interface WPLGridSpanRec : NSObject
@property (nonatomic,readonly) NSInteger index;
@property (nonatomic,readonly) NSInteger span;
@property (nonatomic,readonly) CGFloat size;
- (instancetype)init NS_UNAVAILABLE;
@end
@implementation WPLGridSpanRec

- (instancetype) initForIndex:(NSInteger)index span:(NSInteger)span {
    self = [super init];
    if(self!=nil) {
        _index = index;
        _span = span;
        _size = 0;
    }
    return self;
}

- (void) updateSize:(NSInteger)size {
    _size = MAX(size, _size);
}

+ (NSString*) keyForIndex:(NSInteger)index span:(NSInteger)span {
    return [NSString stringWithFormat:@"i=%ld,s=%ld", (long)index, (long)span];
}

@end

/**
 * セル情報を保持するクラス
 */
class CellInfo {
private:
    CGFloat def;
    WPLCMinMax min_max;
public:
    CGFloat size;
    bool completed;
public:
    CellInfo(CGFloat defSize, WPLMinMax min_max_) {
        def = defSize;
        min_max = min_max_;
        size = 0;
        completed = false;
    }
    CellInfo(const CellInfo& src) {
        def = src.def;
        min_max = src.min_max;
        size = src.size;
        completed = src.completed;
    }
    CGFloat defSize() const {
        return def;
    }
    const WPLCMinMax getMinMax() const {
        return min_max;
    }
    void clipSize() {
        size = min_max.clip(size);
    }
};

/**
 * セル情報の配列
 */
class CellList {
private:
    std::vector<CellInfo> _list;
    bool finished;
    CGFloat fixedSize;
public:
    void init(NSArray<id>* defs) {
        _list.assign(defs.count, CellInfo(S_AUTO, WPLCMinMax::empty()));
        finished = false;
        fixedSize = 0;
        WPLCMinMax minmax;
        for(NSInteger i=0, ci = defs.count ; i<ci ; i++) {
            CGFloat v = [WPLRangedSize toSize:defs[i] span:minmax];
            if(v!=S_AUTO||minmax.isSpecified()) {
                _list[i] = CellInfo(v,minmax);
            }
        }
    }
       
    void reset() {
        finished = false;
        fixedSize = 0;
        for(NSInteger i=_list.size()-1 ; i>=0 ; i--) {
            _list[i].completed = false;
            _list[i].size = 0;
        }
    }
    void finish() {
        finished = true;
    }
    bool isFinished() {
        return finished;
    }
    void setFixedSize(CGFloat s) {
        fixedSize = s;
    }
    CGFloat getFixedSize() {
        return fixedSize;
    }
        
    NSInteger count() const {
        return _list.size();
    }
        
    void setSize(NSInteger index, CGFloat value) {
        _list[index].size = value;
    }
    
    void updateSize(NSInteger index, CGFloat value) {
        _list[index].size = MAX(_list[index].size, value);
    }
        
    CGFloat getSize(NSInteger index) const {
        return _list[index].size;
    }
        
    CGFloat getDefSize(NSInteger index) const {
        return _list[index].defSize();
    }
        
    const WPLCMinMax getMinMax(NSInteger index) const {
        return _list[index].getMinMax();
    }
    CGFloat clipSize(NSInteger index, CGFloat size) const {
        return _list[index].getMinMax().clip(size);
    }
    void clipAll() {
        for(NSInteger i=0,ci=_list.size() ; i<ci ; i++) {
            _list[i].clipSize();
        }
    }

    CGFloat getDefSize(NSInteger index, NSInteger span, CGFloat spacing) const {
        if(span==1) {
            return getDefSize(index);
        }
        return sumDefSize(index, span, spacing);
    }

    bool isCompleted(NSInteger index) const{
        return _list[index].completed;
    }
    
    bool isCompleted(NSInteger index, NSInteger span) const {
        for(NSInteger i=0 ; i<span ; i++) {
            if(!_list[index+i].completed) {
                return false;
            }
        }
        return true;
    }
    
    bool isCompleted() const {
        return isCompleted(0,_list.size());
    }
    
    void completed(NSInteger index, bool completed) {
        _list[index].completed = completed;
    }
        
    NSInteger uncompletedCount(NSInteger index, NSInteger span) const {
        NSInteger count = 0;
        for(NSInteger i=0 ; i<span ; i++) {
            if(!_list[index+i].completed) {
                count++;
            }
        }
        return count;
    }

    NSInteger uncompletedCount() const {
        return uncompletedCount(0, count());
    }
    
    NSInteger firstUncompletedIndex(NSInteger index, NSInteger span) {
        for(NSInteger i=0 ; i<span ; i++) {
            if(!_list[index+i].completed) {
                return index+i;
            }
        }
        return -1;
    }
    
    CGFloat sizeRange(NSInteger index, NSInteger span, CGFloat spacing) {
        CGFloat value = 0;
        for(NSInteger i=0 ; i<span ; i++) {
            CGFloat v = getSize(index+i);
            if(v>0) {
                if(value!=0) {
                    value+=spacing;
                }
                value += v;
            }
        }
        return value;
    }

    CGFloat sizeRangeOnlyCompleted(NSInteger index, NSInteger span, CGFloat spacing) {
        CGFloat value = 0;
        for(NSInteger i=0 ; i<span ; i++) {
            if(isCompleted(index+i)) {
                CGFloat v = getSize(index+i);
                if(v>0) {
                    if(value!=0) {
                        value+=spacing;
                    }
                    value += v;
                }
            }
        }
        return value;
    }

    CGFloat totalSize(CGFloat spacing) {
        return sizeRange(0, count(), spacing);
    }
    
    CGFloat getFinalSize(CGFloat spacing) {
        if(fixedSize>0) {
            return fixedSize;
        }
        return totalSize(spacing);
    }
    
    CGFloat offsetAt(NSInteger index, CGFloat spacing) {
        CGFloat value = sizeRange(0, index, spacing);
        if(value>0) {
            value += spacing;
        }
        return value;
    }
   
   
    CGFloat sumDefSize(NSInteger index, NSInteger span, CGFloat spacing) const {
        CGFloat value = 0;
        bool a = false;
        for(NSInteger i=0 ; i<span ; i++) {
            CGFloat v = _list[i+index].defSize();
            if(v < 0) {
                return -1;
            } else if(v==0) {
                a = true;
            } else {
                if(value!=0) {
                    value+=spacing;
                }
                value += v;
            }
        }
        if(a) {
            return 0;
        } else {
            return value;
        }
    }
};

static NSArray<NSNumber*>* s_single_def_auto = @[@(0)];
static NSArray<NSNumber*>* s_single_def_stretch = @[@(-1)];

@implementation WPLGrid {
   
    CGSize _cachedSize;
    CGSize _cellSpacing;

    // Row/Column definitions
//    CellTable _table;

    CellList _listRow;
    CellList _listColumn;
}

#pragma mark - 初期化

/**
 * Gridの正統なコンストラクタ
 */
- (instancetype)initWithView:(UIView *)view
                        name:(NSString *)name
                      margin:(UIEdgeInsets)margin
             requestViewSize:(CGSize)requestViewSize
                  limitWidth:(WPLMinMax) limitWidth
                 limitHeight:(WPLMinMax) limitHeight
                  hAlignment:(WPLCellAlignment)hAlignment
                  vAlignment:(WPLCellAlignment)vAlignment
                  visibility:(WPLVisibility)visibility
                     rowDefs:(NSArray<id> *)rowDefs
                     colDefs:(NSArray<id> *)colDefs
                 cellSpacing:(CGSize)cellSpacing {

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
        _cachedSize = MICSize();
        _cellSpacing = cellSpacing;
        
        // row/column definitions が省略されているときは、１x１グリッドとして定義を自動生成
        // このとき、requestViewSizeが固定サイズなら、それに合わせて中身を伸縮（stretch)
        //         requestViewSize == 0 （auto) なら、中身のサイズを変えずに、Gridの方を伸縮する。
        // この動作を変更したければ、１x１でも、明示的に、row/column definitions を指定すること。
        rowDefs = (rowDefs!=nil&&rowDefs.count>0) ? rowDefs : (requestViewSize.height>0 ? s_single_def_stretch : s_single_def_auto);
        colDefs = (colDefs!=nil&&colDefs.count>0) ? colDefs : (requestViewSize.width>0  ? s_single_def_stretch : s_single_def_auto);
        _listColumn.init(colDefs);
        _listRow.init(rowDefs);
    }
    return self;
}

/**
* WPLCell.initWithView のオーバーライド
* （１x１のグリッド≒WPLFrame を作成する）
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
    NSAssert(false, @"WPLGrid.newCellWithView is not recommended.");
    return [self initWithView:view
                         name:name
                       margin:margin
              requestViewSize:requestViewSize
                   limitWidth:limitWidth
                  limitHeight:limitHeight
                   hAlignment:hAlignment
                   vAlignment:vAlignment
                   visibility:visibility
                      rowDefs:nil
                      colDefs:nil
                  cellSpacing:MICSize()];
}

/**
 * for C++
 */
- (instancetype) initWithView:(UIView *)view
                         name:(NSString *)name
                       params:(const WPLGridParams&) params {
    return [self initWithView:view
                         name:name
                       margin:params._margin
              requestViewSize:params._requestViewSize
                   limitWidth:params._limitWidth
                  limitHeight:params._limitHeight
                   hAlignment:params._align.horz
                   vAlignment:params._align.vert
                   visibility:params._visibility
                      rowDefs:params._dimension.rowDefs
                      colDefs:params._dimension.colDefs
                  cellSpacing:params._cellSpacing];
}

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) gridWithName:(NSString*) name
                       params:(const WPLGridParams&) params {
    return [self gridWithView:[WPLInternalGridView new] name:name params:params];
}

+ (instancetype) gridWithView:(UIView*) view
                         name:(NSString*) name
                       params:(const WPLGridParams&) params {
    return [[self alloc] initWithView:view name:name params:params];
}


#pragma mark - プロパティ

- (void) setCachedSize:(CGSize)cachedSize {
    _cachedSize = cachedSize;
}
- (CGSize) cachedSize {
    return _cachedSize;
}


// 行数
- (NSInteger) rows {
    return _listRow.count();
}
// カラム数
- (NSInteger) columns {
    return _listColumn.count();
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

#pragma mark - セル操作

/**
 * セルの追加
 */
- (void) addCell:(id<IWPLCell>)cell {
    [self addCell:cell row:0 column:0 rowSpan:1 colSpan:1];
}
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column {
    [self addCell:cell row:row column:column rowSpan:1 colSpan:1];
}

- (void) createExtension:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan {
    if(rowSpan<1) {
        rowSpan = 1;
    }
    if(colSpan<1) {
        colSpan = 1;
    }
    if (row+rowSpan-1 >= self.rows || column+colSpan-1 >= self.columns) {
        [NSException raise:NSRangeException format:@"WPLGrid.addCell(%@) to row=%ld (%ld), col=%ld (%ld): out of range (%ld,%ld).",
         cell.name, (long)row, (long)rowSpan, (long)column, (long)colSpan,
         (long)self.rows, (long)self.columns];
    }
    cell.extension = [[WPLGridExtension alloc] initWithPosition:WPLCellPosition(row, column, rowSpan, colSpan)];
}

- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan {
    [self createExtension:cell row:row column:column rowSpan:rowSpan colSpan:colSpan];
    [super addCell:cell];
}

- (void)addCell:(id<IWPLCell>)cell position:(const WPLCellPosition &)pos {
    [self addCell:cell row:pos.row column:pos.column rowSpan:pos.rowSpan colSpan:pos.colSpan];
}

- (void)addCell:(id<IWPLCell>)cell locators:(NSDictionary<NSString *,WPLGridCellLocator *> *)locatorMap {
    let loc = locatorMap[cell.name];
    if(loc.updateCell!=nil) {
        loc.updateCell(cell);
    }
    [self addCell:cell row:loc.row column:loc.column rowSpan:loc.rowSpan colSpan:loc.colSpan];
}

/**
 * セルの移動
 */
- (void) moveCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column {
    [self detachCell:cell];
    [self addCell:cell row:row column:column];
}

- (void) moveCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan {
    [self detachCell:cell];
    [self addCell:cell row:row column:column rowSpan:rowSpan colSpan:colSpan];
}
- (void) moveCell:(id<IWPLCell>)cell position:(const WPLCellPosition &)pos {
    [self moveCell:cell row:pos.row column:pos.column rowSpan:pos.rowSpan colSpan:pos.colSpan];
}

- (void) moveCell:(id<IWPLCell>)cell locators:(NSDictionary<NSString *,WPLGridCellLocator *> *)locatorMap {
    let loc = locatorMap[cell.name];
    [self moveCell:cell row:loc.row column:loc.column rowSpan:loc.rowSpan colSpan:loc.colSpan];
}

/**
 * グリッド構成の再構築
 */
- (void) reformWithParams:(const WPLGridParams&) params updateCell:(WPLUpdateCellPosition) updateCellPosition {
    // set CellParams
    [self setParams:params];
    
    // update GridParams
    _cachedSize = MICSize();
    _cellSpacing = params._cellSpacing;
    var rowDefs = params._dimension.rowDefs;
    var colDefs = params._dimension.colDefs;
    rowDefs = (rowDefs!=nil&&rowDefs.count>0) ? rowDefs : (params._requestViewSize.height>0 ? s_single_def_stretch : s_single_def_auto);
    colDefs = (colDefs!=nil&&colDefs.count>0) ? colDefs : (params._requestViewSize.width>0  ? s_single_def_stretch : s_single_def_auto);
//    _table.init(rowDefs,colDefs);
    _listRow.init(rowDefs);
    _listColumn.init(colDefs);

    for(id<IWPLCell> cell in self.cells) {
        WPLCellPosition pos(updateCellPosition(cell, ((WPLGridExtension*)(cell.extension)).cellPosition));
        cell.extension = nil;
        [self createExtension:cell row:pos.row column:pos.column rowSpan:pos.rowSpan colSpan:pos.colSpan];
    }
    self.needsLayoutChildren = true;
    self.needsLayout = true;
}

- (void)reformWithParams:(const WPLGridParams &)params locators:(NSDictionary<NSString *,WPLGridCellLocator *> *)locatorMap {
    [self reformWithParams:params updateCell:^WPLCellPosition(id<IWPLCell> cell, WPLCellPosition pos) {
        let loc = locatorMap[cell.name];
        return [loc updateCell:cell position:pos];
    }];
}

static inline WPLGridExtension* EXT(id<IWPLCell>cell) {
    return (WPLGridExtension*)cell.extension;
}

class RCAccessor {
public:
    RowColumn rc;
    CellList& list;
    RCAccessor(RowColumn rc_, CellList& list_)
    :rc(rc_)
    ,list(list_)
    {}
    
    ~RCAccessor() {
        list.finish();
    }
    
    CGFloat span(id<IWPLCell> cell) {
        if(rc==COL) {
            return EXT(cell).colSpan;
        } else {
            return EXT(cell).rowSpan;
        }
    }
    CGFloat index(id<IWPLCell>cell) {
        if(rc==COL) {
            return EXT(cell).column;
        } else {
            return EXT(cell).row;
        }
    }
    CGFloat calcSize(id<IWPLCell> cell, CGFloat regulationSize) {
        if(rc==COL) {
            return [cell calcCellWidth:regulationSize];
        } else {
            return [cell calcCellHeight:regulationSize];
        }
    }
    CGFloat recalcSize(id<IWPLCell> cell, CGFloat regulationSize) {
        if(rc==COL) {
            return [cell recalcCellWidth:regulationSize];
        } else {
            return [cell recalcCellHeight:regulationSize];
        }
    }
    
    CGFloat requestedSize(id<IWPLCell> cell) {
        if(rc==COL) {
            return cell.requestViewSize.width;
        } else {
            return cell.requestViewSize.height;
        }
    }
    
    CGFloat sizeFrom(CGSize sp) {
        if(rc==COL) {
            return sp.width;
        } else {
            return sp.height;
        }
    }
    
    CGFloat spacing(WPLGrid* g) {
        return sizeFrom(g.cellSpacing);
    }
    
    CGFloat margin(id<IWPLCell> cell) {
        if(rc==COL) {
            return MICEdgeInsets::dw(cell.margin);
        } else {
            return MICEdgeInsets::dh(cell.margin);
        }
    }
    
    CGFloat getFixedSize() const {
        return list.getFixedSize();
    }
    void setFixedSize(CGFloat s) {
        list.setFixedSize(s);
    }
    
    CGFloat getGridSize(WPLGrid* grid, id<IWPLCell> cell) {
        let ex = EXT(cell);
        if(rc==COL) {
            return list.sizeRange(ex.column, ex.colSpan, spacing(grid));
        } else {
            return list.sizeRange(ex.row, ex.rowSpan, spacing(grid));
        }
    }
};

- (void)beginRendering:(WPLRenderingMode)mode {
    if(self.needsLayoutChildren||mode!=WPLRenderingNORMAL) {
        _listColumn.reset();
        _listRow.reset();
    }
    [super beginRendering:mode];
}

- (void)endRendering:(CGRect)finalCellRect {
    if(self.visibility!=WPLVisibilityCOLLAPSED) {
        [self calcCellWidth:0];
        [self calcCellHeight:0];
        for(id<IWPLCell>cell in self.cells) {
            let ex = EXT(cell);
            MICSize size(_listColumn.sizeRange(ex.column, ex.colSpan, _cellSpacing.width),
                         _listRow.sizeRange(ex.row, ex.rowSpan, _cellSpacing.height));
            MICPoint point(_listColumn.offsetAt(ex.column, _cellSpacing.width),
                           _listRow.offsetAt(ex.row, _cellSpacing.height));
            [cell endRendering:MICRect(point,size)];
        }
    }
    [super endRendering:finalCellRect];
}

- (CGFloat)calcCellWidth:(CGFloat)regulatingWidth {
    if(!_listColumn.isFinished()) {
        RCAccessor acc(COL,_listColumn);
        [self calcCellSzie:acc regulatingSize:regulatingWidth];
    }
    let width = _listColumn.getFinalSize(self.cellSpacing.width);

    // 最小・最大サイズでクリップして、マージンを追加
    return WPLCMinMax(self.limitWidth).clip(width) + MICEdgeInsets::dw(self.margin);
}

- (CGFloat)calcCellHeight:(CGFloat)regulatingHeight {
    if(!_listRow.isFinished()) {
        RCAccessor acc(ROW,_listRow);
        [self calcCellSzie:acc regulatingSize:regulatingHeight];
    }
    let height = _listRow.getFinalSize(self.cellSpacing.height);

    // 最小・最大サイズでクリップして、マージンを追加
    return WPLCMinMax(self.limitHeight).clip(height) + MICEdgeInsets::dh(self.margin);
}

- (CGFloat)recalcCellWidth:(CGFloat)regulatingWidth {
    _listColumn.reset();
    return [self calcCellWidth:regulatingWidth];
}

- (CGFloat)recalcCellHeight:(CGFloat)regulatingHeight {
    _listRow.reset();
    return [self calcCellHeight:regulatingHeight];
}

/**
 * セルサイズ計算のエントリポイント（縦横共通）
 */
- (void) calcCellSzie:(RCAccessor&)acc regulatingSize:(CGFloat)regulatingSize {
    acc.list.reset();
    [self phase_0_getPanelSize:acc regulatingSize:regulatingSize];
    do {
        if([self phase_1_apply_def_cells:acc]) {
            break;
        }
        if([self phase_2_calc_simple_cells:acc]) {
            break;
        }
        if([self phase_3_calc_simple_spanned_cells:acc]) {
            break;
        }
    } while(false);

    if(acc.getFixedSize()>0) {
        [self topDown_calc_stretch:acc];
    } else {
        [self bottomUp_calc_stretch:acc];
    }
    
    [self phase_4_finalize_cells:acc];
}

/**
 * Phase-0： トップダウン的にサイズが決定できるかどうか試す。
 * グリッド全体のサイズがFIXED、または、STRCの場合は、中身を計算しなくても、グリッドサイズが確定する。
 * @return true:  TopDown レイアウトへ
 *         false: BottomUp レイアウトへ
 */
- (bool) phase_0_getPanelSize:(RCAccessor&)acc
                  regulatingSize:(CGFloat) regulatingSize {   // マージンを含まない
    CGFloat size = 0;
    CGFloat requestedSize = acc.requestedSize(self);
    if(requestedSize>0) {
        // Any > FIXED
        // Independent | BottomUp
        size = requestedSize;
    }
    if(requestedSize<0 && regulatingSize>0) {
        // STRC|FIXED > STRC
        size = regulatingSize;
    }
    acc.setFixedSize(size);
    return size>0;
}

/**
 * Phase-1： グリッドセルサイズの計算において、グリッドセルのサイズがFIXED指定のものを最優先で確定
 */
- (bool) phase_1_apply_def_cells:(RCAccessor&) acc {
    for(NSInteger i=0, ci=acc.list.count() ; i<ci ; i++) {
        let defs = acc.list.getDefSize(i);
        if(defs>0) {
            acc.list.setSize(i, defs);
            acc.list.completed(i, true);
        }
    }
    return acc.list.isCompleted();
}

/**
 * phase_1 で未確定の（＝rowDefs/colDefsでサイズが決定しなかった）グリッドセルについて、
 * colSpan/rowSpan == 1 のセルのサイズを計算して更新する。
 */
- (bool) phase_2_calc_simple_cells:(RCAccessor&) acc {
    for(id<IWPLCell>cell in self.cells) {
        if(cell.visibility!=WPLVisibilityCOLLAPSED) {
            let index = acc.index(cell);
            let defSize = acc.list.getDefSize(index);
            if(acc.span(cell)==1) {
                if( defSize==0 /*AUTO*/ ||
                   (defSize< 0 /*STRC*/ && acc.getFixedSize()==0 /*親AUTO*/ )) { // 全体のサイズがAUTOなのに、STRCなグリッドがある：矛盾する指定-->グリッドもAUTOとして処理
                    let size = acc.calcSize(cell, 0);
                    acc.list.updateSize(index, size);
                    if(acc.requestedSize(cell)>=0) {
                        // STRCなcellのautoとしての計算結果は参考値
                        // phase-3 に影響しないよう、completedフラグは立てない。
                        acc.list.completed(index, true);
                    }
                }
            }
        }
    }
    return acc.list.isCompleted();
}

/**
 * spanを持つセルのサイズによって、未決定のグリッドセルのサイズが決定されるケースに対応
 */
- (bool) phase_3_calc_simple_spanned_cells:(RCAccessor&) acc {
    bool modified = false;
    do {
        modified = false;
        for(id<IWPLCell>cell in self.cells) {
            let span = acc.span(cell);
            if(span>1 && cell.visibility!=WPLVisibilityCOLLAPSED && acc.requestedSize(cell)>=0) {
                let index = acc.index(cell);
                let uncomp = acc.list.uncompletedCount(index,span);
                if(uncomp==1) {
                    // のこり１つ
                    let ui = acc.list.firstUncompletedIndex(index, span);
                    if(ui>=0 && (acc.getFixedSize()==0 || acc.list.getDefSize(ui)==0)) {
                        let cs = acc.calcSize(cell, 0);
                        let spacing = acc.spacing(self);
                        let sum = acc.list.sizeRangeOnlyCompleted(index, span, spacing);
                        acc.list.setSize(ui, MAX(0,cs-sum-spacing));
                        acc.list.completed(ui, true);
                        modified = true;
                    }
                }
            }
        }
    } while(modified);
    return acc.list.isCompleted();
}

/**
 * 計算結果のグリッドサイズをすべてのセルに伝達し、必要に応じてサイズの再計算を要求する。
 */
- (void) phase_4_finalize_cells:(RCAccessor&) acc {
    // セルに反映する前に、グリッド毎のmin/maxを反映する。
    acc.list.clipAll();

    for(id<IWPLCell>cell in self.cells) {
        let size = acc.getGridSize(self, cell);
        if(acc.requestedSize(cell)<0) {
            acc.recalcSize(cell, size);
        } else {
            acc.calcSize(cell, size);
        }
    }
}

/**
 * グリッド全体のサイズが固定できる場合のSTRCセルサイズ解決
 */
- (void) topDown_calc_stretch:(RCAccessor&) acc {
    CGFloat fixed = 0;
    CGFloat stretch = 0;
    NSInteger stretchCount = 0;
    CGFloat spacing = acc.spacing(self);
    // STRCグリッドセルの情報を集める
    for(NSInteger i=0, ci=acc.list.count() ; i<ci ; i++) {
        let defs = acc.list.getDefSize(i);
        if(defs<0) {
            stretch += ABS(defs);
            stretchCount++;
        } else {
            fixed += acc.list.getSize(i);
        }
    }
    if(stretchCount>0 && stretch>0) {
        CGFloat remain = acc.getFixedSize() - fixed - spacing*(acc.list.count()-1);
        for(NSInteger i=0, ci=acc.list.count() ; i<ci ; i++) {
            let defs = acc.list.getDefSize(i);
            if(defs<0) {
                acc.list.setSize(i, MAX(0, remain*ABS(defs)/stretch));
                acc.list.completed(i, true);
            }
        }
    }
}

- (void) bottomUp_calc_stretch:(RCAccessor&) acc {
    let dic = [self bottomUp_1_groupSpannedCell:acc];
    if(nil!=dic) {
        for(id key in dic.allKeys) {
            [self bottomUp_2_tryResolveSize:dic[key] acc:acc];
        }
    }
}


/**
 *
 */
- (NSMutableDictionary<NSString*,WPLGridSpanRec*>*) bottomUp_1_groupSpannedCell:(RCAccessor&) acc {
    NSMutableDictionary<NSString*,WPLGridSpanRec*>* dic = nil;
    for(id<IWPLCell> cell in self.cells) {
        let span = acc.span(cell);
        if(span>1 && acc.requestedSize(cell)>=0) {
            let index = acc.index(cell);
            let span = acc.span(cell);
            let key = [WPLGridSpanRec keyForIndex:index span:span];
            let size = acc.calcSize(cell, 0);
            if(dic==nil) {
                dic = [NSMutableDictionary dictionaryWithCapacity:acc.list.count()];
            }
            var rec = [dic objectForKey:key];
            if(nil==rec) {
                rec = [[WPLGridSpanRec alloc] initForIndex:index span:span];
                [dic setObject:rec forKey:key];
            }
            [rec updateSize:size];
        }
    }
    return dic;
}

- (void) bottomUp_2_tryResolveSize:(WPLGridSpanRec*)rec acc:(RCAccessor&) acc {
    let index = rec.index;
    let span = rec.span;
    let spacing = acc.sizeFrom(self.cellSpacing);
    var size = rec.size + spacing;      // すべてのセルサイズにspacingが含まれている前提で計算するので、最初に右側のspacingを足しておく
    CGFloat totalStretch = 0;
    NSInteger stretchCount = 0;

    for(NSInteger i=0, ci=span ; i<ci ; i++) {
        NSInteger pos = index+i;
        CGFloat defSize = acc.list.getDefSize(pos);
        if(defSize<0) {
            // STRC
            totalStretch += ABS(defSize);
            stretchCount++;
        } else {
            CGFloat v = acc.list.getSize(pos);
            if(v>0) {
                size -= (v+spacing);
            }
        }
    }

    // 得られた計算結果をセルサイズテーブルに反映
    CGFloat totalSize = size - spacing * (stretchCount-1);
    [self bottomUp_2_2_completeStretched:acc index:index span:span totalSize:totalSize totalStretch:totalStretch];
}

/**
 * indexからspanの範囲の未確定なセルに、totalSizeとtotalStretchから按分されるサイズを設定する。
 */
- (void) bottomUp_2_2_completeStretched:(RCAccessor&)acc index:(NSInteger)index span:(NSInteger)span totalSize:(CGFloat) size totalStretch:(CGFloat) totalStretch {
    if(totalStretch<=0) {
        // stretchなセルはなかった
        return;
    }
    
    // stretchの比率に合わせて、サイズを決定
    for(NSInteger i=0, ci=span ; i<ci ; i++) {
        NSInteger pos = index+i;
        CGFloat defSize = acc.list.getDefSize(pos);
        if(defSize<0) {
            if(size>0) {
                acc.list.setSize(pos, ABS(defSize)*size/totalStretch);
            } else {
                acc.list.setSize(pos, 0);
            }
            acc.list.completed(pos, true);
        }
    }
}

@end
