//
//  WPLStackPanelScrollView.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/19.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLCellHostingScrollView.h"
#import "WPLStackPanel.h"

@interface WPLStackPanelScrollView : WPLCellHostingScrollView

/**
 * ルートコンテナセルを取得
 * (WPLFrame*) o.containerCell
 * と同じ。frame というプロパティ名にしたかったが、UIView#frameと名前が衝突するから。。。
 */
@property (nonatomic) WPLStackPanel* container;

#if defined(__cplusplus)

/**
 * Frameコンテナをルートにもつホスティグビューを作成
 *  C++以外は相手にしない。
 */
+ (instancetype) stackPanelViewWithName:(NSString*) name
params:(WPLStackPanelParams) params;

#endif

@end

