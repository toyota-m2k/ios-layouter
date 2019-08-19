//
//  WPLValueCell.h
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCell.h"

/**
 * Value属性を持つセルクラス (abstract)
 */
@interface WPLValueCell : WPLCell<IWPLCellSupportValue>

// @protected
- (void) onValueChanged;

@end
