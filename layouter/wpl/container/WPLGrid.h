//
//  WPLGrid.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLContainerCell.h"

// Cell Definition (rowDef/colDef)のサイズとして指定可能なスペシャル値
#define WPL_GRID_SIZING_AUTO 0           // Auto  中身に合わせてサイズを決定する
#define WPL_GRID_SIZING_STRETCH -1.0     // *(1*)   2* は、2*SIZING_STRETCH と指定

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

    WPLGridParams(WPLGridDefinition dim = WPLGridDefinition(), MICEdgeInsets margin=MICEdgeInsets(), MICSize requestViewSize=MICSize(), WPLAlignment align=WPLAlignment(), WPLVisibility visibility=WPLVisibilityVISIBLE)
    : WPLCellParams(margin, requestViewSize, align, visibility)
    , _dimension(dim) {}
    
    WPLGridParams(const WPLGridParams& src)
    : WPLCellParams(src)
    , _dimension(src._dimension) {}
    
    // builder style methods ----
    
    WPLGridParams& margin(const UIEdgeInsets& v) {
        _margin = v;
        return *this;
    }
    WPLCellParams& margin(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom) {
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
};

class WPLGridAddCellParams {
public:
    NSInteger _row;
    NSInteger _column;
    NSInteger _rowSpan;
    NSInteger _colSpan;
    
    WPLGridAddCellParams(NSInteger row=0, NSInteger column=0, NSInteger rowSpan=1, NSInteger colSpan=1)
    : _row(row)
    , _column(column)
    , _rowSpan(rowSpan)
    , _colSpan(colSpan){}
    
    WPLGridAddCellParams& row(NSInteger v) {
        _row = v;
        return *this;
    }
    WPLGridAddCellParams& column(NSInteger v) {
        _column = v;
        return *this;
    }
    WPLGridAddCellParams& rowSpan(NSInteger v) {
        _rowSpan = v;
        return *this;
    }
    WPLGridAddCellParams& colSpan(NSInteger v) {
        _colSpan = v;
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
                      colDefs:(NSArray<NSNumber*>*) colDefs;

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

@property (nonatomic,readonly) NSInteger rows;
@property (nonatomic,readonly) NSInteger columns;

- (void) addCell:(id<IWPLCell>)cell;
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column;
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan;
- (void) addCell:(id<IWPLCell>)cell params:(const WPLGridAddCellParams&) params;

@end
