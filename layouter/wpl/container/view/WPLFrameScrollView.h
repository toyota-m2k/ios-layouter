//
//  WPLFrameScrollView.h
//
//  Created by toyota-m2k on 2020/02/03.
//  Copyright © 2020 toyota-m2k. All rights reserved.
//

#import "WPLCellHostingScrollView.h"
#import "WPLFrameView.h"

@interface WPLFrameScrollView : WPLCellHostingScrollView<IWPLFrameView>

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

