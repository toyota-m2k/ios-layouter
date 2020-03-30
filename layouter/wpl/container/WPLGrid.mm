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
#import <vector>

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

class CellTable {
    std::vector<CellInfo> _cols;
    std::vector<CellInfo> _rows;
    
public:
    CellTable() {
        
    }
    
    void init(NSArray<NSNumber*>* rowDefs, NSArray<NSNumber*>* colDefs) {
        _rows.assign(rowDefs.count, CellInfo(S_AUTO));
        _cols.assign(colDefs.count, CellInfo(S_AUTO));
        for(NSInteger i=0 ; i<rowDefs.count ; i++) {
            NSInteger v = rowDefs[i].integerValue;
            if(v!=S_AUTO) {
                _rows[i] = CellInfo(v);
            }
        }
        for(NSInteger i=0 ; i<colDefs.count ; i++) {
            NSInteger v = colDefs[i].integerValue;
            if(v!=S_AUTO) {
                _cols[i] = CellInfo(v);
            }
        }
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

static NSArray<NSNumber*>* s_single_def_auto = @[@(0)];
static NSArray<NSNumber*>* s_single_def_stretch = @[@(-1)];

@implementation WPLGrid {
   
    CGSize _cachedSize;
    CGSize _cellSpacing;

    // Row/Column definitions
    CellTable _table;
}

#pragma mark - 初期化

/**
* Gridの正統なコンストラクタ
*/
- (instancetype)initWithView:(UIView *)view name:(NSString *)name margin:(UIEdgeInsets)margin requestViewSize:(CGSize)requestViewSize hAlignment:(WPLCellAlignment)hAlignment vAlignment:(WPLCellAlignment)vAlignment visibility:(WPLVisibility)visibility containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate rowDefs:(NSArray<NSNumber *> *)rowDefs colDefs:(NSArray<NSNumber *> *)colDefs cellSpacing:(CGSize)cellSpacing {

    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
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
    }
    return self;
}

- (instancetype)initWithView:(UIView*)view name:(NSString*)name params:(const WPLGridParams&) params containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    return [self initWithView:view name:name margin:params._margin requestViewSize:params._requestViewSize hAlignment:params._align.horz vAlignment:params._align.vert visibility:params._visibility containerDelegate:containerDelegate rowDefs:params._dimension.rowDefs colDefs:params._dimension.colDefs cellSpacing:params._cellSpacing];
}
/**
 * WPLCell.initWithView のオーバーライド
 * （１x１のグリッド≒WPLFrame を作成する）
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
    return [[self alloc] initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment
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

+ (instancetype) gridWithView:(UIView*) view
                         name:(NSString*) name
                       params:(const WPLGridParams&) params {
    return [[self alloc] initWithView:view name:name margin:params._margin requestViewSize:params._requestViewSize hAlignment:params._align.horz vAlignment:params._align.vert visibility:params._visibility containerDelegate:nil rowDefs:params._dimension.rowDefs colDefs:params._dimension.colDefs cellSpacing:params._cellSpacing];
}


#pragma mark - プロパティ

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
        [NSException raise:NSRangeException format:@"WPLGrid.addCell(%@): out of range (%ld,%ld).", cell.name, (long)self.rows, (long)self.columns];
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

    for(id<IWPLCell> cell in self.cells) {
        WPLCellPosition pos(updateCellPosition(cell, ((WPLGridExtension*)(cell.extension)).cellPosition));
        cell.extension = nil;
        [self createExtension:cell row:pos.row column:pos.column rowSpan:pos.rowSpan colSpan:pos.colSpan];
    }
    self.needsLayoutChildren = true;
    self.needsLayout = true;
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
        if(cell.requestViewSize.width >=0 || regSize.width>=0) {
            ex.colComp = true;
        }
        if(cell.requestViewSize.height>=0 || regSize.height>=0) {
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
 * キャッシュサイズが確定していない場合（cachedSize.width/height==0f）には、サイズを計算する(Pass2 ～ Pass4)。
 * 計算結果に基づいて、セルを配置する(Pass5)。
 */
- (CGSize) innerLayout:(CGSize) fixedSize {
//    NSAssert(fixedSize.width>=0 && fixedSize.height>=0, @"Grid.innerLayout: fix < 0");
    if(_cachedSize.width==0) {
        _cachedSize.width = [self calcGridSize:COL fixedSize:fixedSize.width];
    }
    if(_cachedSize.height==0) {
        _cachedSize.height = [self calcGridSize:ROW fixedSize:fixedSize.height];
    }
    [self pass4_finalize];
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
    return [self sizeWithMargin:_cachedSize];
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
        [self pass1_initParams];
        MICSize fixSize( (self.requestViewSize.width>=0)  ? self.requestViewSize.width  : regSize.width,
                         (self.requestViewSize.height>=0) ? self.requestViewSize.height : regSize.height );
        
        [self innerLayout:[self sizeWithoutMargin:fixSize]];
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
