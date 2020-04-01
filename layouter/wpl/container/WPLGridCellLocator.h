//
//  WPLGridCellLocator.h
//  WPLGrid.reformWithParams をシステム化するためのヘルパー実装
//
//  Created by @toyota-m2k on 2020/03/31.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLGrid.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * CellParamを更新するためのコールバック型
 * この型のコールバックを、WPLレイヤーから呼び出すことはない。
 * WPLUpdateCellPositionを実装するためのヘルパーとして利用することを想定
 */
typedef void (^WPLUpdateCellParams)(id<IWPLCell>cell);

@interface WPLGridCellLocator : NSObject
@property (nonatomic) NSInteger row;
@property (nonatomic,readonly) NSInteger column;
@property (nonatomic,readonly) NSInteger rowSpan;
@property (nonatomic,readonly) NSInteger colSpan;
@property (nonatomic,readonly,nullable) WPLUpdateCellParams updateCell;

- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) new  NS_UNAVAILABLE;

//- (instancetype) initRow:(NSInteger)row column:(NSInteger)col;
//- (instancetype) initRow:(NSInteger)row column:(NSInteger)col updateCell:(nullable WPLUpdateCellParams)updateCell;
//- (instancetype) initRow:(NSInteger)row column:(NSInteger)col rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan;
- (instancetype) initRow:(NSInteger)row column:(NSInteger)col rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan updateCell:(nullable WPLUpdateCellParams)updateCell;

+ (instancetype) newRow:(NSInteger)row column:(NSInteger)col;
+ (instancetype) newRow:(NSInteger)row column:(NSInteger)col updateCell:(nullable WPLUpdateCellParams)updateCell;
+ (instancetype) newRow:(NSInteger)row column:(NSInteger)col rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan;
+ (instancetype) newRow:(NSInteger)row column:(NSInteger)col rowSpan:(NSInteger)rowSpan colSpan:(NSInteger)colSpan updateCell:(WPLUpdateCellParams)updateCell;

- (void) updateCell:(id<IWPLCell>)cell;
- (WPLCellPosition) updateCell:(id<IWPLCell>)cell position:(WPLCellPosition)pos;

@end

NS_ASSUME_NONNULL_END
