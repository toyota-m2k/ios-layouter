//
//  WPLContainerCell.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
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

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate;

@end
