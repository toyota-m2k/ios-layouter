//
//  WPLFrame.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/08.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLContainerCell.h"

/**
 * WPLFrame
 *  1x1 の WPLGridと同等のレイアウト能力を持つクラス
 *  WPLGridに比べてかなり軽量なので、１x１で済む場合は、こちらを使った方がよい。
 */
@interface WPLFrame : WPLContainerCell

#if defined(__cplusplus)

- (instancetype) initWithView:(UIView*) view
                         name:(NSString*)name
                       params:(WPLCellParams) params;

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) frameWithName:(NSString*)name
                        params:(WPLCellParams) params;

+ (instancetype) frameWithView:(UIView*) view
                          name:(NSString*)name
                        params:(WPLCellParams) params;

#endif

@end

@interface WPLFrame (WHRendering)

@end

