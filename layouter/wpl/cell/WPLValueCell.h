//
//  WPLValueCell.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLCell.h"

/**
 * Value属性を持つセルクラス (abstract)
 */
@interface WPLValueCell : WPLCell<IWPLCellSupportValue>

// @protected
- (void) onValueChanged;

@end
