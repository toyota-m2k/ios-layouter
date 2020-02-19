//
//  WPLGridView.h
//  WP Layouter
//  WP Layouter のルートコンテナとしての機能を持った、WPLGridをホスティングするビュークラス
//
//  Created by toyota-m2k on 2019/08/09.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCellHostingView.h"
#import "WPLGrid.h"

@protocol IWPLGridView <IWPLCellHostingView>
/**
 * ルートコンテナセルを取得
 * (WPLFrame*) o.containerCell
 * と同じ。frame というプロパティ名にしたかったが、UIView#frameと名前が衝突するから。。。
 */
@property (nonatomic) WPLGrid* container;
@end

@interface WPLGridView : WPLCellHostingView<IWPLGridView>
/**
 * ルートコンテナセルを取得
 * (WPLFrame*) o.containerCell
 * と同じ。frame というプロパティ名にしたかったが、UIView#frameと名前が衝突するから。。。
 */
@property (nonatomic) WPLGrid* container;

#if defined(__cplusplus)

- (instancetype) initWithFrame:(CGRect)frame
                         named:(NSString*) name
                        params:(WPLGridParams)params;

/**
 * Gridコンテナをルートにもつホスティグビューを作成
 *  C++以外は相手にしない。
 */
+ (instancetype) gridViewWithName:(NSString*) name
                           params:(WPLGridParams) params;

#endif

@end
