//
//  WPLCell.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLCellDef.h"

/**
 * ICell i/f を実装した、セルの基底クラス
 * ReadOnly や Value を持たないビュー(UIView,UIButtonなど)は、このセルを利用可。
 */

@interface WPLCell : NSObject<IWPLCell>

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate;

+ (instancetype) newCellWithView:(UIView*)view
                            name:(NSString*) name
                          margin:(UIEdgeInsets) margin
                 requestViewSize:(CGSize) requestViewSize
                      hAlignment:(WPLCellAlignment)hAlignment
                      vAlignment:(WPLCellAlignment)vAlignment
                      visibility:(WPLVisibility)visibility
               containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate;

@end
