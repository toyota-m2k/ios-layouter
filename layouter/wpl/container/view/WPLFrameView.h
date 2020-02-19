//
//  WPLFrameView.h
//  WP Layouter
//  WP Layouter のルートコンテナとしての機能を持った、WPLFrameをホスティングするビュークラス
//
//  Created by toyota-m2k on 2019/08/09.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCellHostingView.h"
#import "WPLFrame.h"

@protocol IWPLFrameView <IWPLCellHostingView>

/**
 * ルートコンテナセルを取得
 * (WPLFrame*) o.containerCell
 * と同じ。frame というプロパティ名にしたかったが、UIView#frameと名前が衝突するから。。。
 */
@property (nonatomic) WPLFrame* container;

@end

@interface WPLFrameView : WPLCellHostingView<IWPLFrameView>

/**
 * ルートコンテナセルを取得
 * (WPLFrame*) o.containerCell
 * と同じ。frame というプロパティ名にしたかったが、UIView#frameと名前が衝突するから。。。
 */
@property (nonatomic) WPLFrame* container;

#if defined(__cplusplus)

- (instancetype) initWithFrame:(CGRect)frame
                         named:(NSString*) name
                        params:(WPLCellParams)params;

/**
 * Frameコンテナをルートにもつホスティグビューを作成
 *  C++以外は相手にしない。
 */
+ (instancetype) frameViewWithName:(NSString*) name
                            params:(WPLCellParams) params;

#endif

@end
