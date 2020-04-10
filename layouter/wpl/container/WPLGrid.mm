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

#define GRID_CELL_MIN_MAX_SUPPORT

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
    @property (nonatomic) CGSize size;
    @property (nonatomic) bool rowComp;
    @property (nonatomic) bool colComp;
    @property (nonatomic, readonly) WPLCellPosition cellPosition;
@end

@implementation WPLGridExtension

- (instancetype) initWithPosition:(const WPLCellPosition&) pos {
    self = [super init];
    if(nil!=self) {
        _row = pos.row;
        _column = pos.column;
        _rowSpan = pos.rowSpan;
        _colSpan = pos.colSpan;
        _size = MICSize();
        _rowComp = false;
        _colComp = false;
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

- (CGFloat) size:(RowColumn) rc {
    return (rc==COL) ? _size.width : _size.height;
}

- (void) setSize:(RowColumn) rc value:(CGFloat)value{
    if (rc==COL) {
        _size.width = value;
    } else {
        _size.height = value;
    }
}

- (bool) isCompleted:(RowColumn) rc {
    return (rc==COL) ? _colComp : _rowComp;
}

- (void) completed:(RowColumn) rc {
    if(rc==COL) {
        _colComp = true;
    } else {
        _rowComp = true;
    }
}

- (void) reset {
    _size = MICSize::zero();
    _rowComp = false;
    _colComp = false;
}

- (NSString*) keyForSpan:(RowColumn)rc {
    if(rc==COL) {
        return [NSString stringWithFormat:@"col=%ld,span=%ld", (long)_column, (long)_colSpan];
    } else {
        return [NSString stringWithFormat:@"row=%ld,span=%ld", (long)_row, (long)_rowSpan];
    }
}

@end

#ifdef GRID_CELL_MIN_MAX_SUPPORT
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
#else
class CellInfo {
private:
    CGFloat def;
public:
    CGFloat size;
    bool completed;
public:
    CellInfo(CGFloat defSize) {
        def = defSize;
        size = 0;
        completed = false;
    }
    CellInfo(const CellInfo& src) {
        def = src.def;
        size = src.size;
        completed = src.completed;
    }
    CGFloat defSize() const {
        return def;
    }
};
#endif

class CellTable {
    std::vector<CellInfo> _cols;
    std::vector<CellInfo> _rows;
    
public:
    CellTable() {
        
    }
    
    void init(NSArray<id>* rowDefs, NSArray<id>* colDefs) {
#ifdef GRID_CELL_MIN_MAX_SUPPORT
        _rows.assign(rowDefs.count, CellInfo(S_AUTO, WPLCMinMax()));
        _cols.assign(colDefs.count, CellInfo(S_AUTO, WPLCMinMax()));
        WPLCMinMax minmax;
        for(NSInteger i=0 ; i<rowDefs.count ; i++) {
            CGFloat v = [WPLRangedSize toSize:rowDefs[i] span:minmax];
            if(v!=S_AUTO||minmax.isSpecified()) {
                _rows[i] = CellInfo(v,minmax);
            }
        }
        for(NSInteger i=0 ; i<colDefs.count ; i++) {
            CGFloat v = [WPLRangedSize toSize:colDefs[i] span:minmax];
            if(v!=S_AUTO||minmax.isSpecified()) {
                _cols[i] = CellInfo(v,minmax);
            }
        }
#else
        _rows.assign(rowDefs.count, CellInfo(S_AUTO));
        _cols.assign(colDefs.count, CellInfo(S_AUTO));
        for(NSInteger i=0 ; i<rowDefs.count ; i++) {
            CGFloat v = number_to_cgfloat(rowDefs[i]);
            _rows[i] = CellInfo(v);
        }
        for(NSInteger i=0 ; i<colDefs.count ; i++) {
            CGFloat v = number_to_cgfloat(colDefs[i]);
            _cols[i] = CellInfo(v);
        }
#endif
    }
    
    void reset(RowColumn rc) {
        if(rc==COL) {
            for(NSInteger i=_cols.size()-1 ; i>=0 ; i--) {
                _cols[i].completed = false;
                _cols[i].size = 0;
            }
        } else {
            for(NSInteger i=_rows.size()-1 ; i>=0 ; i--) {
                _rows[i].completed = false;
                _rows[i].size = 0;
            }
        }
    }
    
    void reset() {
        reset(ROW);
        reset(COL);
    }
    
    NSInteger count(RowColumn rc) const {
        return (rc==COL) ? _cols.size() : _rows.size();
    }
    
    void setSize(RowColumn rc, NSInteger index, CGFloat value) {
        if(rc==COL) {
            _cols[index].size = value;
        } else {
            _rows[index].size = value;
        }
    }
    
    CGFloat getSize(RowColumn rc, NSInteger index) const {
        if(rc==COL) {
            return _cols[index].size;
        } else {
            return _rows[index].size;
        }
    }
    
    CGFloat getDefSize(RowColumn rc, NSInteger index) const {
        if(rc==COL) {
            return _cols[index].defSize();
        } else {
            return _rows[index].defSize();
        }
    }
    
#ifdef GRID_CELL_MIN_MAX_SUPPORT
    const WPLCMinMax getMinMax(RowColumn rc, NSInteger index) const {
        if(rc==COL) {
            return _cols[index].getMinMax();
        } else {
            return _rows[index].getMinMax();
        }
    }
#endif
    

    CGFloat getDefSize(RowColumn rc, NSInteger index, NSInteger span, CGFloat spacing) const {
        if(span==1) {
            return getDefSize(rc,index);
        }
        if(rc==COL) {
            return sumDefSize(_cols, index, span, spacing);
        } else {
            return sumDefSize(_rows, index, span, spacing);
        }
    }
    
    
//    CGFloat getDefSize(RowColumn rc, WPLGridExtension* ex) {
//        if(rc==COL) {
//            return _cols[ex.column].defSize();
//        } else {
//            return _rows[ex.row].defSize();
//        }
//    }
             
     bool isCompleted(RowColumn rc, NSInteger index) const{
        if(rc==COL) {
            return _cols[index].completed;
        } else {
            return _rows[index].completed;
        }
     }
    
    void completed(RowColumn rc, NSInteger index, bool completed) {
        if(rc==COL) {
            _cols[index].completed = completed;
        } else {
            _rows[index].completed = completed;
        }
    }
    
    NSInteger uncompletedCount(RowColumn rc) {
        if(rc==COL) {
            return uncompletedCount(_cols);
        } else {
            return uncompletedCount(_rows);
        }
    }
    
    CGFloat sizeRange(RowColumn rc, NSInteger index, NSInteger span, CGFloat spacing) {
        CGFloat value = 0;
        for(NSInteger i=0 ; i<span ; i++) {
            CGFloat v = getSize(rc, index+i);
            if(v>0) {
                if(value!=0) {
                    value+=spacing;
                }
                value += v;
            }
        }
        return value;
    }
    
    CGFloat offsetAt(RowColumn rc, NSInteger index, CGFloat spacing) {
        CGFloat value = sizeRange(rc, 0, index, spacing);
        if(value>0) {
            value += spacing;
        }
        return value;
    }
   
   
private:
    static CGFloat sumDefSize(const std::vector<CellInfo>& ary, NSInteger index, NSInteger span, CGFloat spacing) {
        CGFloat value = 0;
        bool a = false;
        for(NSInteger i=0 ; i<span ; i++) {
            CGFloat v = ary[i+index].defSize();
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
    
    static NSInteger uncompletedCount(const std::vector<CellInfo>& ary) {
        NSInteger count = 0;
        for(NSInteger i=ary.size()-1 ; i>=0 ; i--) {
            if(!ary[i].completed) {
                count++;
            }
        }
        return count;
    }

};

class CellList {
private:
    std::vector<CellInfo> _list;
    bool finished;
    CGFloat fixedSize;
public:
#ifdef GRID_CELL_MIN_MAX_SUPPORT
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
#else
    void init(NSArray<id>* defs) {
        _list.assign(defs.count, CellInfo(S_AUTO));
        WPLCMinMax minmax;
        for(NSInteger i=0, ci = defs.count ; i<ci ; i++) {
            CGFloat v = number_to_cgfloat(defs[i]);
            if(v!=S_AUTO) {
                _list[i] = CellInfo(v);
            }
        }
    }
#endif
       
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
        
#ifdef GRID_CELL_MIN_MAX_SUPPORT
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
#endif

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
    CellTable _table;

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
        _table.init(rowDefs,colDefs);
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
    return _table.count(ROW);
}
// カラム数
- (NSInteger) columns {
    return _table.count(COL);
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
    _table.init(rowDefs,colDefs);
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

#pragma mark - レイアウト計算用

#pragma mark レイアウト計算：Pass1 ... 初期化＋内部セルの必要サイズを計算

/**
 * セルマージンを含むセルサイズを計算する
 * 各セルに対して、layoutPrepare を呼び出してセルが管理しているサイズを取得し、それに対してセルマージンを付加して返す。
 */
- (void) calcCellSizeWithCellSpacing:(id<IWPLCell>)cell {
    let ex = (WPLGridExtension*)cell.extension;
    if(cell.visibility!=WPLVisibilityCOLLAPSED) {
        // regulatingCellSize: Stretchセルのサイズを決めるためのヒント
        // ここでは、defCols/defRowsに正値を指定すると、それが regulatingSizeになる。
        // layoutPrepareは負値（stretch）を扱えないので、そのときは 0(auto)を渡すようにする。
        MICSize regSize( MAX(0, _table.getDefSize(COL, ex.column, ex.colSpan, _cellSpacing.width )),
                         MAX(0, _table.getDefSize(ROW, ex.row,    ex.rowSpan, _cellSpacing.height)));
        MICSize size = [cell layoutPrepare:regSize];
        
        
        // 固定サイズ指定のセルはサイズを確定する
        ex.size = size;
        if(cell.requestViewSize.width >0 || regSize.width>0) {
            ex.colComp = true;
        }
        if(cell.requestViewSize.height>0 || regSize.height>0) {
            ex.rowComp = true;
        }
    } else {
        // Invisibleなセルはサイズゼロとして扱う
        ex.size = MICSize::zero();
        ex.rowComp = true;
        ex.colComp = true;
    }
}

/**
 * Pass1
 *
 * すべてのセルのminSize を計算して、GridExtensionにセットする
 * グリッドセルのサイズが固定の場合は無駄になるかもしれないが、Row/Columnのどちらかで必要になるケースもあるので、
 * とにかく全部計算しておく。
 */
- (void) pass1_initParams {
    _cachedSize = MICSize::zero();
    _table.reset();
    for(id<IWPLCell> c in self.cells) {
        [(WPLGridExtension*)(c.extension) reset];
        [self calcCellSizeWithCellSpacing:c];
    }
}

#pragma mark レイアウト計算：Pass2 ... Row/Columnのサイズを計算


/**
 * Pass2
 *
 * pass1で各セルの必要最小サイズを求めたので、それを集計して、row/column毎の最大値（row/columnの必要サイズ）を計算する。
 * GridDefinitionで、固定サイズが指定されているrow/columnは、それを優先的に採用する。
 */
- (void) pass2_getMinRowColumnSize:(RowColumn)rc {
    for(id<IWPLCell> c in self.cells) {
        let ex = (WPLGridExtension*)c.extension;
        NSInteger pos = [ex index:rc];
        
       if(!_table.isCompleted(rc, pos)) {
            CGFloat defSize = _table.getDefSize(rc, pos);
            if (defSize > 0) {
                // GridDefinietionで、カラムの高さ/幅が固定値として指定されている
                _table.setSize(rc, pos, defSize);
                _table.completed(rc, pos, true);    // このサイズで確定
            } else if ([ex span:rc] == 1) {  // span>1 のものは除外
                CGFloat csize = [ex size:rc];
                _table.setSize(rc, pos, MAX(_table.getSize(rc,pos), csize));
            }
        }
    }
    
    // Pass2 を終えた時点で　AUTOのセルは、すべてサイズは確定している。
    for(NSInteger i = _table.count(rc)-1 ; i>=0 ; i--) {
        if(/*_table.getSize(rc, i)>=0 &&*/ _table.getDefSize(rc, i)>=0) {
            _table.completed(rc, i, true);
        }
    }
}


#pragma mark レイアウト計算：Pass3 ... Stretch指定されたrow/columnのサイズを計算

/**
 * Pass3
 *
 * RowSpan/ColSpan >1 のセルサイズが固定or Autoで与えられている場合、それを基準に解決可能なstretchセルのサイズを計算する。
 */

/**
 * Row+RowSpan, Column+ColSpan によってグループ化して、最もサイズが大きいものを取り出す。
 */
- (NSDictionary<NSString*,WPLGridExtension*>*) groupCellBySpanning:(RowColumn) rc {
    NSMutableDictionary<NSString*,WPLGridExtension*>* dic = nil;
    for(id<IWPLCell> c in self.cells) {
        let ex = (WPLGridExtension*)c.extension;
        if([ex span:rc]>1 && [ex isCompleted:rc]) {
            let key = [ex keyForSpan:rc];
            if(nil==dic) {
                dic = [[NSMutableDictionary alloc] init];
                [dic setObject:ex forKey:key];
            } else {
                WPLGridExtension* prev = [dic objectForKey:key];
                if([prev size:rc]<[ex size:rc]) {
                    [dic setObject:ex forKey:key];
                }
            }
        }
    }
    return dic;
}

/**
 * Span>1でサイズが固定されているものを基準に、そのspanに含まれる stretchセルのサイズを決定する。
 */
- (void) resolveStretchBySpannedCell:(RowColumn) rc {
    let dic = [self groupCellBySpanning:rc];
    if(nil==dic) {
        return;
    }
    
    for(id key in dic.allKeys) {
        [self tryResolveSize:rc by:dic[key]];
    }
}

/**
 * ex (Span>1でサイズ固定のセル)を基準に　そのspanに含まれる stretchセルのサイズを決定する。
 */
- (void) tryResolveSize:(RowColumn) rc by:(WPLGridExtension*)ex {
    NSInteger index = [ex index:rc];
    NSInteger span = [ex span:rc];
    CGFloat spacing = [self cellSpacingFor:rc];
    CGFloat size = [ex size:rc] + spacing;      // すべてのセルサイズにspacingが含まれている前提で計算するので、最初に右側のspacingを足しておく
    CGFloat totalStretch = 0;
    NSInteger stretchCount = 0;

    for(NSInteger i=0, ci=span ; i<ci ; i++) {
        NSInteger pos = index+i;
        if(!_table.isCompleted(rc, pos)) {
            CGFloat defSize = _table.getDefSize(rc, pos);
            if(defSize<0) {
                totalStretch += ABS(defSize);
                stretchCount++;
            } else {
//                NSAssert(false, @"non-stretched cell but unknown size.");
                NSLog(@"non-stretched cell but unknown size.(%@) : index=%ld defSize=%f", (rc==COL?@"COL":@"ROW"), (long)pos, defSize);
            }
        } else {
            CGFloat v = _table.getSize(rc, pos);
            if(v>0) {
                size -= (v+spacing);
            }
        }
    }

    // 得られた計算結果をセルサイズテーブルに反映
    CGFloat totalSize = size - spacing * (stretchCount-1);
    [self completeStretched:rc index:index span:span totalSize:totalSize totalStretch:totalStretch];
}

/**
 * indexからspanの範囲の未確定なセルに、totalSizeとtotalStretchから按分されるサイズを設定する。
 */
- (void) completeStretched:(RowColumn)rc index:(NSInteger)index span:(NSInteger)span totalSize:(CGFloat) size totalStretch:(CGFloat) totalStretch {
    if(totalStretch<=0) {
        // stretchなセルはなかった
        return;
    }
    
    // stretchの比率に合わせて、サイズを決定
    for(NSInteger i=0, ci=span ; i<ci ; i++) {
        NSInteger pos = index+i;
        if(!_table.isCompleted(rc, pos)) {
            CGFloat defSize = _table.getDefSize(rc, pos);
            if(defSize<0) {
                if(size>0) {
                    _table.setSize(rc, pos, ABS(defSize)*size/totalStretch);
                } else {
                    _table.setSize(rc, pos, 0);
                }
                _table.completed(rc, pos, true);
            }
        }
    }
}

- (CGFloat) cellSpacingFor:(RowColumn) rc {
    return (rc==COL) ? _cellSpacing.width : _cellSpacing.height;
}

/**
 * グリッドのサイズが固定サイズとして指定されている場合に、それを基準にStretchセルのサイズを計算する。
 */
- (void) resolveStretchByFixedSize:(RowColumn) rc fixed:(CGFloat) fixed {
    CGFloat totalStretch = 0;
    CGFloat occupied = 0;
    CGFloat spacing = [self cellSpacingFor:rc];
    NSInteger countStretch = 0;
    for(NSInteger i=0, ci=_table.count(rc) ; i<ci ; i++) {
        if(!_table.isCompleted(rc, i)) {
            CGFloat defSize = _table.getDefSize(rc, i);
            if(defSize<0) {
                totalStretch += ABS(defSize);
                countStretch++;
            }
        } else {
            CGFloat v = _table.getSize(rc, i);
            if(v>0) {
                occupied += (v+spacing);
            }
        }
    }
    CGFloat totalSize = fixed-occupied-spacing*(countStretch-1);
    [self completeStretched:rc index:0 span:_table.count(rc) totalSize:totalSize totalStretch:totalStretch];
}

- (void) pass3_calcStretch:(RowColumn)rc fixedSize:(CGFloat)fixedSize {
    //NSAssert(fixedSize>=0, @"fixed size must have positive value (auto|fixed).");
    if(fixedSize==0) {
        // Auto: 内部のセルサイズを優先
        [self resolveStretchBySpannedCell:rc];
    } else {
        // Fixed: グリッドのサイズを優先
        [self resolveStretchByFixedSize:rc fixed:MAX(fixedSize,0)];
    }
}

#pragma mark レイアウト計算：Pass4 ... 各セルに配置を反映

/**
 * セルを配置する
 * widths/heights に入っている各column/rowの幅・高さの計算結果を、セルに反映する
 */
- (void) pass4_finalize {
    for(id<IWPLCell> c in self.cells) {
        let ex = (WPLGridExtension*) c.extension;
        MICSize size(_table.sizeRange(COL, ex.column, ex.colSpan, _cellSpacing.width),
                     _table.sizeRange(ROW, ex.row, ex.rowSpan, _cellSpacing.height));
        MICPoint point(_table.offsetAt(COL, ex.column, _cellSpacing.width),
                       _table.offsetAt(ROW, ex.row, _cellSpacing.height));
        [c layoutCompleted:MICRect(point,size)];
    }
}

#pragma mark レイアウト エントリーポイント

- (CGFloat) calcGridSize:(RowColumn)rc fixedSize:(CGFloat) fixedSize {
    _table.reset(rc);
    [self pass2_getMinRowColumnSize:rc];
    [self pass3_calcStretch:rc fixedSize:fixedSize];
    return (fixedSize > 0) ? fixedSize : _table.sizeRange(rc, 0, _table.count(rc), [self cellSpacingFor:rc]);
}

/**
 * レイアウト内部処理
 *
 * @param innerRegulatingSize   親コンテナによって要求されるセルサイズ（マージンを含まない＝ビューのサイズ）
 *                              負値(STRC)は入らず、STRCの場合は親コンテナのサイズが入っている。
 *                              親がAUTOの場合はゼロが入っている。
 */
- (CGSize) innerLayout:(CGSize) innerRegulatingSize {
    //        MICSize fixSize( (self.requestViewSize.width>=0)  ? self.requestViewSize.width  : regSize.width,
    //                         (self.requestViewSize.height>=0) ? self.requestViewSize.height : regSize.height );

    if(_cachedSize.width==0) {
        CGFloat width = self.requestViewSize.width>=0 ? self.requestViewSize.width : innerRegulatingSize.width;
        _cachedSize.width = [self calcGridSize:COL fixedSize:width];
    }
    if(_cachedSize.height==0) {
        CGFloat height = self.requestViewSize.height>=0 ? self.requestViewSize.height : innerRegulatingSize.height;
        _cachedSize.height = [self calcGridSize:ROW fixedSize:height];
    }
    [self pass4_finalize];
    self.needsLayoutChildren = false;
    return _cachedSize;
}

//- (CGSize) innerLayout:(CGSize) fixedSize {
////    NSAssert(fixedSize.width>=0 && fixedSize.height>=0, @"Grid.innerLayout: fix < 0");
//    if(_cachedSize.width==0) {
//        _cachedSize.width = [self calcGridSize:COL fixedSize:fixedSize.width];
//    }
//    if(_cachedSize.height==0) {
//        _cachedSize.height = [self calcGridSize:ROW fixedSize:fixedSize.height];
//    }
//    [self pass4_finalize];
//    self.needsLayoutChildren = false;
//    return _cachedSize;
//}

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
    return [self sizeWithMargin:_cachedSize];
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
        _cachedSize = CGSizeZero;
        return MICSize::zero();
    }

    if(self.needsLayoutChildren) {
        [self pass1_initParams];
        MICSize innerSize([self limitRegulatingSize:[self sizeWithoutMargin:regulatingCellSize]]);
        [self innerLayout:innerSize];
    }
    return [self sizeWithMargin:[self limitSize:_cachedSize]];
}
//- (CGSize) layoutPrepare:(CGSize) regulatingCellSize {
//    if(self.visibility==WPLVisibilityCOLLAPSED) {
//        _cachedSize = CGSizeZero;
//        return MICSize::zero();
//    }
//
//    MICSize regSize([self limitRegulatingSize:[self sizeWithoutMargin:regulatingCellSize]]);
//    if(self.needsLayoutChildren) {
//        [self pass1_initParams];
//        MICSize fixSize( (self.requestViewSize.width>=0)  ? self.requestViewSize.width  : regSize.width,
//                         (self.requestViewSize.height>=0) ? self.requestViewSize.height : regSize.height );
//
//        [self innerLayout:[self sizeWithoutMargin:fixSize]];
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

    NSAssert(!self.needsLayoutChildren, @"layout must be calculated.");
    
    MICSize viewSize([self sizeWithoutMargin:finalCellRect.size]);
    // layoutPrepareの計算結果とセルサイズが異なる場合、STRETCH 指定なら、与えられたサイズを使って配置を再計算する
    if(viewSize.width!=_cachedSize.width && self.requestViewSize.width<0 /* stretch */) {
        _cachedSize.width = 0;
    }
    if(viewSize.height!=_cachedSize.height && self.requestViewSize.height<0 /* stretch */ ) {
        _cachedSize.height = 0;
    }
    if(_cachedSize.width==0||_cachedSize.height==0) {
        [self innerLayout:viewSize];
    }
    // [super layoutCompleted:] は、auto-sizing のときにview のサイズを配置計算に使用するので、ここでサイズを設定しておく
    if (MICSize(_cachedSize) != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    [super layoutCompleted:finalCellRect];
}




@end




@implementation WPLGrid (WHRendering)

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

//    void comp(id<IWPLCell> cell, bool flag=true) {
//        if(rc==COL) {
//            EXT(cell).colComp = flag;
//        } else {
//            EXT(cell).rowComp = flag;
//        }
//    }
//    bool isComp(id<IWPLCell> cell) {
//        if(rc==COL) {
//            return EXT(cell).colComp;
//        } else {
//            return EXT(cell).rowComp;
//        }
//    }
    void setExtSize(id<IWPLCell>cell, CGFloat size) {
        let ext = EXT(cell);
        MICSize exSize(ext.size);
        if(rc==COL) {
            exSize.width = size;
        } else {
            exSize.height = size;
        }
        ext.size = exSize;
    }
    CGFloat extSize(id<IWPLCell>cell) {
        if(rc==COL) {
            return EXT(cell).size.width;
        } else {
            return EXT(cell).size.height;
        }
    }
    
    NSString* keyForSpan(id<IWPLCell>cell) {
        return [EXT(cell) keyForSpan:rc];
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

- (void)endRenderingInRect:(CGRect)finalCellRect {
    if(self.visibility!=WPLVisibilityCOLLAPSED) {
        for(id<IWPLCell>cell in self.cells) {
            let ex = EXT(cell);
            MICSize size(_listColumn.sizeRange(ex.column, ex.colSpan, _cellSpacing.width),
                         _listRow.sizeRange(ex.row, ex.rowSpan, _cellSpacing.height));
            MICPoint point(_listColumn.offsetAt(ex.column, _cellSpacing.width),
                           _listRow.offsetAt(ex.row, _cellSpacing.height));
            [cell endRenderingInRect:MICRect(point,size)];
        }
    }
    [super endRenderingInRect:finalCellRect];
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
- (NSMutableDictionary<NSString*,id<IWPLCell>>*) bottomUp_1_groupSpannedCell:(RCAccessor&) acc {
    NSMutableDictionary<NSString*,id<IWPLCell>>* dic = nil;
    for(id<IWPLCell> cell in self.cells) {
        let span = acc.span(cell);
        if(span>1 && acc.requestedSize(cell)>=0) {
            let key = acc.keyForSpan(cell);
            let size = acc.calcSize(cell, 0);
            if(dic==nil) {
                dic = [NSMutableDictionary dictionaryWithCapacity:acc.list.count()];
            }
            let org = [dic objectForKey:key];
            if(nil==org || acc.extSize(org)<size) {
                acc.setExtSize(cell, size);
                [dic setObject:cell forKey:key];
            }
        }
    }
    return dic;
}

- (void) bottomUp_2_tryResolveSize:(id<IWPLCell>)cell acc:(RCAccessor&) acc {
    let index = acc.index(cell);
    let span = acc.span(cell);
    let spacing = acc.sizeFrom(self.cellSpacing);
    var size = acc.extSize(cell) + spacing;      // すべてのセルサイズにspacingが含まれている前提で計算するので、最初に右側のspacingを足しておく
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
