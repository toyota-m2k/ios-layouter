//
//  WPLSliderCell.h
//
//  Created by @toyota-m2k on 2020/02/03.
//  Copyright @toyota-m2k. All rights reserved.
//

#import "WPLValueCell.h"

#define WPLSliderCell_MIN_NAME @"min"
#define WPLSliderCell_MAX_NAME @"max"

@interface WPLSliderCell : WPLValueCell<IWPLCellSupportNamedValue>

@property (nonatomic) float min;
@property (nonatomic) float max;

@end
