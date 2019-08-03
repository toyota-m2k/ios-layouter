//
//  WPLTextCell.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLValueCell.h"

/**
 * UITextView用のCellクラス
 */
@interface WPLTextCell : WPLValueCell<IWPLCellSuportReadonly, UITextViewDelegate, UITextFieldDelegate>
@end
