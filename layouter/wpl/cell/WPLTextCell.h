//
//  WPLTextCell.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLValueCell.h"

/**
 * UITextView用のCellクラス
 */
@interface WPLTextCell : WPLValueCell<IWPLCellSuportReadonly, UITextViewDelegate, UITextFieldDelegate>

@end
