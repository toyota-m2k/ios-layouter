//
//  WPLGrid.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/03.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLContainerCell.h"

// Cell Definition (rowDef/colDef)のサイズとして指定可能なスペシャル値
#define WPL_GRID_SIZING_AUTO        WPL_CELL_SIZING_AUTO        // Auto  中身に合わせてサイズを決定する
#define WPL_GRID_SIZING_STRETCH     WPL_CELL_SIZING_STRETCH     // *(1*)   2* は、2*SIZING_STRETCH と指定

#if defined(__cplusplus)

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

    WPLGridParams(WPLGridDefinition dim = WPLGridDefinition(), CGSize cellMargin=MICSize(), UIEdgeInsets margin=MICEdgeInsets(), CGSize requestViewSize=MICSize(), WPLAlignment align=WPLAlignment(), WPLVisibility visibility=WPLVisibilityVISIBLE)
    : WPLCellParams(margin, requestViewSize, align, visibility)
    , _dimension(dim)
    , _cellSpacing(cellMargin) {}
    
    WPLGridParams(const WPLGridParams& src)
    : WPLCellParams(src)
    , _dimension(src._dimension)
    , _cellSpacing(src._cellSpacing){}
    
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
};

#endif

/**
 * Row/Column でレイアウト可能なコンテナセルクラス
 */
@interface WPLGrid : WPLContainerCell

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
                  cellSpacing:(CGSize) cellSpacing;

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
                  cellSpacing:(CGSize) cellSpacing
                    superview:(UIView*)superview;

//+ (instancetype) newGridOfRows:(NSArray<NSNumber*>*) rowDefs
//                    andColumns:(NSArray<NSNumber*>*) colDefs
//               requestViewSize:(CGSize) requestViewSize;

#if defined(__cplusplus)
/**
 * C++用インスタンス生成ヘルパー
 * (Root Container 用）
 * Grid用UIViewを自動生成して、superviewにaddSubviewする。
 */
+ (instancetype) gridWithName:(NSString*) name
                       params:(const WPLGridParams&) params
                    superview:(UIView*)superview
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate;

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) gridWithName:(NSString*) name
                       params:(const WPLGridParams&) params;

#endif

@property (nonatomic) CGSize cellSpacing;
@property (nonatomic,readonly) NSInteger rows;
@property (nonatomic,readonly) NSInteger columns;

- (void) addCell:(id<IWPLCell>)cell;
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column;
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan;

@end
