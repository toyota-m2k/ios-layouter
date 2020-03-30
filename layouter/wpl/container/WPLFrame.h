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

+ (instancetype) frameWithName:(NSString*) name
                        margin:(UIEdgeInsets) margin
               requestViewSize:(CGSize) requestViewSize
                    hAlignment:(WPLCellAlignment)hAlignment
                    vAlignment:(WPLCellAlignment)vAlignment
                    visibility:(WPLVisibility)visibility
             containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                     superview:(UIView*)superview;

#if defined(__cplusplus)

/**
 * C++版インスタンス生成ヘルパー
 * (Root Container 用）
 */
+ (instancetype) frameWithName:(NSString*)name
                        params:(WPLCellParams) params
             containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                     superview:(UIView*)superview;

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) frameWithName:(NSString*)name
                        params:(WPLCellParams) params;

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       params:(const WPLCellParams&) params
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate;


#endif

@end

