//
//  WPLContainerCell.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCell.h"
#import "WPLContainerDef.h"

/**
 * コンテナセル(StackPanel/Grid)の共通実装 (abstract class)
 * １つ以上のセルを保持できるコンテナであり、且つ、自身もセルとして入れ子にできる。
 */
@interface WPLContainerCell : WPLCell<IWPLContainerCell>
/**
 * 子セルの再レイアウトが必要か？
 */
@property (nonatomic) bool needsLayoutChildren;

/**
 * 子セルの配列
 */
@property (nonatomic) NSArray<id<IWPLCell>>* cells;


@property (nonatomic) CGSize cachedSize;

@end
