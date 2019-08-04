//
//  WPLSwitchCell.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/04.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLValueCell.h"

@interface WPLSwitchCell : WPLValueCell

- (instancetype) initWithView:(UISwitch*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility;

+ (instancetype) newCellWithSwitchView:(UISwitch*)switchView
                                  name:(NSString*) name
                                margin:(UIEdgeInsets) margin
                       requestViewSize:(CGSize) requestViewSize
                            hAlignment:(WPLCellAlignment)hAlignment
                            vAlignment:(WPLCellAlignment)vAlignment
                            visibility:(WPLVisibility)visibility;

@end

