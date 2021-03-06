//
//  WPLGrid.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/11/05.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLContainerCell.h"

// Cell Definition (rowDef/colDef)のサイズとして指定可能なスペシャル値
#define WPL_GRID_SIZING_AUTO        WPL_CELL_SIZING_AUTO        // Auto  中身に合わせてサイズを決定する
#define WPL_GRID_SIZING_STRETCH     WPL_CELL_SIZING_STRETCH     // *(1*)   2* は、2*SIZING_STRETCH と指定

#if defined(__cplusplus)

@class WPLGridCellLocator;

class WPLGridDefinition {
public:
    NSArray<NSNumber*>* rowDefs;
    NSArray<NSNumber*>* colDefs;

    WPLGridDefinition() {
        rowDefs = nil;
        colDefs = nil;
    }
    
    WPLGridDefinition(const WPLGridDefinition& src) {
        rowDefs = src.rowDefs;
        colDefs = src.colDefs;
    }
    
    WPLGridDefinition(NSArray<NSNumber*>* rows, NSArray<NSNumber*>* cols) {
        rowDefs = rows;
        colDefs = cols;
    }
    
    ~WPLGridDefinition() {
        rowDefs = nil;
        colDefs = nil;
    }
    
    WPLGridDefinition& rows(NSArray<NSNumber*>* v) {
        rowDefs = v;
        return *this;
    }
    WPLGridDefinition& cols(NSArray<NSNumber*>* v) {
        colDefs = v;
        return *this;
    }
};

class WPLGridParams : public WPLCellParams {
public:
    WPLGridDefinition _dimension;
    MICSize _cellSpacing;

    WPLGridParams(WPLGridDefinition dim = WPLGridDefinition())
    : _dimension(dim)
    , _cellSpacing(MICSize()) {}
    
    WPLGridParams(const WPLGridParams& src)
    : WPLCellParams(src)
    , _dimension(src._dimension)
    , _cellSpacing(src._cellSpacing){}
    
    WPLGridParams(const WPLCellParams& cellParams, WPLGridDefinition dim = WPLGridDefinition(), CGSize cellSpacing=MICSize())
    : WPLCellParams(cellParams)
    , _dimension(dim)
    , _cellSpacing(cellSpacing) {}
    
    // builder style methods ----
    
    WPLGridParams& margin(const UIEdgeInsets& v) {
        _margin = v;
        return *this;
    }
    WPLGridParams& margin(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom) {
        _margin = MICEdgeInsets(left, top, right, bottom);
        return *this;
    }
    WPLGridParams& requestViewSize(const CGSize& v) {
        _requestViewSize = v;
        return *this;
    }
    WPLGridParams& requestViewSize(CGFloat width, CGFloat height) {
        _requestViewSize = MICSize(width, height);
        return *this;
    }
    WPLGridParams& align(const WPLAlignment& v) {
        _align = v;
        return *this;
    }
    WPLGridParams& align(const WPLCellAlignment align) {
        _align = WPLAlignment(align);
        return *this;
    }
    WPLGridParams& align(const WPLCellAlignment horz, const WPLCellAlignment vert) {
        _align = WPLAlignment(horz, vert);
        return *this;
    }
   
    WPLGridParams& horzAlign(const WPLCellAlignment v) {
        _align.horz = v;
        return *this;
    }
    
    WPLGridParams& vertAlign(const WPLCellAlignment v) {
        _align.vert = v;
        return *this;
    }

    WPLGridParams& visibility(const WPLVisibility v) {
        _visibility = v;
        return *this;
    }
    
    WPLGridParams& dimension(const WPLGridDefinition& dim) {
        _dimension = dim;
        return *this;
    }
    
    WPLGridParams& rowDefs(NSArray<NSNumber*>* v) {
        _dimension.rows(v);
        return *this;
    }
    
    WPLGridParams& colDefs(NSArray<NSNumber*>* v) {
        _dimension.cols(v);
        return *this;
    }
    
    WPLGridParams& cellSpacing(const CGSize& cellSpacing) {
        _cellSpacing = cellSpacing;
        return *this;
    }
    WPLGridParams& cellSpacing(CGFloat width, CGFloat height) {
        _cellSpacing = MICSize(width, height);
        return *this;
    }
    
    // Min/Max Width/Height
    WPLGridParams& limitWidth(const WPLMinMax& v) {
        _limitWidth = v;
        return *this;
    }
    WPLGridParams& limitWidth(CGFloat min, CGFloat max) {
        _limitWidth.min = min;
        _limitWidth.max = max;
        return *this;
    }
    WPLGridParams& maxWidth(const CGFloat& v) {
        _limitWidth.max = v;
        return *this;
    }
    WPLGridParams& minWidth(const CGFloat& v) {
        _limitWidth.min = v;
        return *this;
    }
    WPLGridParams& limitHeight(const WPLMinMax& v) {
        _limitHeight = v;
        return *this;
    }
    WPLGridParams& limitHeight(CGFloat min, CGFloat max) {
        _limitHeight.min = min;
        _limitHeight.max = max;
        return *this;
    }
    WPLGridParams& maxHeight(const CGFloat& v) {
        _limitHeight.max = v;
        return *this;
    }
    WPLGridParams& minHeight(const CGFloat& v) {
        _limitHeight.min = v;
        return *this;
    }

};

class WPLCellPosition {
public:
    NSInteger row;
    NSInteger column;
    NSInteger rowSpan;
    NSInteger colSpan;
public:
    WPLCellPosition(NSInteger row_, NSInteger column_) {
        row = row_;
        column = column_;
        colSpan = rowSpan = 1;
    }
    
    WPLCellPosition(NSInteger row_, NSInteger column_, NSInteger rowSpan_, NSInteger colSpan_) {
        row = row_;
        column = column_;
        colSpan = colSpan_;
        rowSpan = rowSpan_;
    }
    
    WPLCellPosition(const WPLCellPosition& src) {
        row = src.row;
        column = src.column;
        colSpan = src.colSpan;
        rowSpan = src.rowSpan;
    }
};

/**
 * グリッドの構成変更にともない、グリッドセルの位置を再マップするためのコールバック型
 */
typedef WPLCellPosition (^WPLUpdateCellPosition)(id<IWPLCell>cell, WPLCellPosition pos);

#endif // cpp

@interface WPLGrid : WPLContainerCell

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
                 cellSpacing:(CGSize)cellSpacing;

@property (nonatomic) CGSize cellSpacing;
@property (nonatomic,readonly) NSInteger rows;
@property (nonatomic,readonly) NSInteger columns;

- (void) addCell:(id<IWPLCell>)cell;
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column;
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan;

// 追加されているセルを、他のセルに移動する(detachCell-->addCellと同じ）
- (void) moveCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column;
- (void) moveCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan;

#if defined(__cplusplus)

- (instancetype)initWithView:(UIView*)view name:(NSString*)name params:(const WPLGridParams&) params;

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) gridWithName:(NSString*) name
                       params:(const WPLGridParams&) params;

+ (instancetype) gridWithView:(UIView*) view
                         name:(NSString*) name
                       params:(const WPLGridParams&) params;

- (void) addCell:(id<IWPLCell>)cell position:(const WPLCellPosition&) pos;
- (void) addCell:(id<IWPLCell>)cell locators:(NSDictionary<NSString*,WPLGridCellLocator*>*) locatorMap;
- (void) moveCell:(id<IWPLCell>)cell position:(const WPLCellPosition&) pos;
- (void) moveCell:(id<IWPLCell>)cell locators:(NSDictionary<NSString*,WPLGridCellLocator*>*) locatorMap;

- (void) reformWithParams:(const WPLGridParams&) params updateCell:(WPLUpdateCellPosition) updateCellPosition;
- (void) reformWithParams:(const WPLGridParams&) params locators:(NSDictionary<NSString*,WPLGridCellLocator*>*) locatorMap;



#endif

@end

