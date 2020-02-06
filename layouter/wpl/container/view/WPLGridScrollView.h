//
//  WPLGridScrollView.h
//  WP Layouter
//  WP Layouter のルートコンテナとしての機能を持った、WPLGridをホスティングするスクロールビュークラス
//
//  Created by toyota-m2k on 2019/08/19.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCellHostingScrollView.h"
#import "WPLGridView.h"

@interface WPLGridScrollView : WPLCellHostingScrollView<IWPLGridView>

/**
 * ルートコンテナセルを取得
 * (WPLFrame*) o.containerCell
 * と同じ。frame というプロパティ名にしたかったが、UIView#frameと名前が衝突するから。。。
 */
@property (nonatomic) WPLGrid* container;

#if defined(__cplusplus)
/**
 * Gridコンテナをルートにもつホスティグビューを作成
 *  C++以外は相手にしない。
 */
+ (instancetype) gridViewWithName:(NSString*) name
                           params:(WPLGridParams) params;

#endif

@end
