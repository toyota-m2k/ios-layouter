//
//  WPLGridCellLocator.mm
//
//  Created by @toyota-m2k on 2020/03/31.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLGridCellLocator.h"

@implementation WPLGridCellLocator

- (instancetype)initRow:(NSInteger)row
                 column:(NSInteger)col
                rowSpan:(NSInteger)rowSpan
                colSpan:(NSInteger)colSpan
             updateCell:(WPLUpdateCellParams)updateCell {
    self = [super init];
    if(nil!=self) {
        _row = row;
        _column = col;
        _rowSpan = rowSpan;
        _colSpan = colSpan;
        _updateCell = updateCell;
    }
    return self;
}

//- (instancetype)initRow:(NSInteger)row column:(NSInteger)col rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan {
//    return [self initRow:row column:col rowSpan:rowSpan colSpan:colSpan updateCell:nil];
//}
//
//- (instancetype)initRow:(NSInteger)row column:(NSInteger)col {
//    return [self initRow:row column:col rowSpan:1 colSpan:1 updateCell:nil];
//}
//
//- (instancetype)initRow:(NSInteger)row column:(NSInteger)col updateCell:(WPLUpdateCellParams)updateCell {
//    return [self initRow:row column:col rowSpan:1 colSpan:1 updateCell:updateCell];
//}


+ (instancetype)newRow:(NSInteger)row
                column:(NSInteger)col
               rowSpan:(NSInteger)rowSpan
               colSpan:(NSInteger)colSpan
            updateCell:(WPLUpdateCellParams)updateCell {
    return [[self alloc] initRow:row column:col rowSpan:rowSpan colSpan:colSpan updateCell:updateCell];
}

+ (instancetype)newRow:(NSInteger)row column:(NSInteger)col updateCell:(WPLUpdateCellParams)updateCell {
    return [[self alloc] initRow:row column:col rowSpan:1 colSpan:1 updateCell:updateCell];
}

+ (instancetype)newRow:(NSInteger)row column:(NSInteger)col rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan {
    return [[self alloc] initRow:row column:col rowSpan:rowSpan colSpan:colSpan updateCell:nil];
}

+ (instancetype)newRow:(NSInteger)row column:(NSInteger)col {
    return [[self alloc] initRow:row column:col rowSpan:1 colSpan:1 updateCell:nil];
}

- (void) updateCell:(id<IWPLCell>)cell {
    if(nil!=_updateCell) {
        _updateCell(cell);
    }
}

- (WPLCellPosition) updateCell:(id<IWPLCell>)cell position:(WPLCellPosition)pos {
    pos.row = _row;
    pos.column = _column;
    pos.rowSpan = _rowSpan;
    pos.colSpan = _colSpan;
    [self updateCell:cell];
    return pos;
}



@end
