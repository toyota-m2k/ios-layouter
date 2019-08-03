//
//  WPLStackPanel.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//
#import "WPLContainerCell.h"

/**
 * StackPanel の伸長方向
 */
typedef enum _WPLOrientation {
    WPLOrientationHORIZONTAL,
    WPLOrientationVERTICAL,
} WPLOrientation;


/**
 * StackPanel セル-コンテナ クラス
 */
@interface WPLStackPanel : WPLContainerCell
@property (nonatomic, readonly) WPLOrientation orientation;

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                  orientation:(WPLOrientation) orientation;

+ (instancetype) stackPanelViewWithName:(NSString*) name
                                 margin:(UIEdgeInsets) margin
                        requestViewSize:(CGSize) requestViewSize
                             hAlignment:(WPLCellAlignment)hAlignment
                             vAlignment:(WPLCellAlignment)vAlignment
                             visibility:(WPLVisibility)visibility
                      containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                            orientation:(WPLOrientation) orientation;

+ (instancetype)stackPanelViewWithName:(NSString*) name
                           orientation:(WPLOrientation)orientation
                            xalignment:(WPLCellAlignment)xalignment
                     containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate;
@end
