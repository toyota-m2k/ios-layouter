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
@end
