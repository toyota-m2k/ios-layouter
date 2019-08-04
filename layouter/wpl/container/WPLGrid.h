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

/**
 * Row/Column でレイアウト可能なコンテナセルクラス
 */
@interface WPLGrid : WPLContainerCell
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

+ (instancetype) newGridWithView:(UIView*)view
                            name:(NSString*) name
                          margin:(UIEdgeInsets) margin
                 requestViewSize:(CGSize) requestViewSize
                      hAlignment:(WPLCellAlignment)hAlignment
                      vAlignment:(WPLCellAlignment)vAlignment
                      visibility:(WPLVisibility)visibility
                         rowDefs:(NSArray<NSNumber*>*) rowDefs
                         colDefs:(NSArray<NSNumber*>*) colDefs
               containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate;

+ (instancetype) newGridOfRows:(NSArray<NSNumber*>*) rowDefs
                    andColumns:(NSArray<NSNumber*>*) colDefs;

- (void) addCell:(id<IWPLCell>)cell;
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column;
- (void) addCell:(id<IWPLCell>)cell row:(NSInteger)row column:(NSInteger)column rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan;

@end
