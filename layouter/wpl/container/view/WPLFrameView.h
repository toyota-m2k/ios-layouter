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

@interface WPLFrameView : WPLCellHostingView

/**
 * ルートコンテナセルを取得
 * (WPLFrame*) o.containerCell
 * と同じ。frame というプロパティ名にしたかったが、UIView#frameと名前が衝突するから。。。
 */
@property (nonatomic) WPLFrame* container;

#if defined(__cplusplus)
/**
 * Frameコンテナをルートにもつホスティグビューを作成
 *  C++以外は相手にしない。
 */
+ (instancetype) frameViewWithName:(NSString*) name
                            params:(WPLCellParams) params;

#endif

@end
