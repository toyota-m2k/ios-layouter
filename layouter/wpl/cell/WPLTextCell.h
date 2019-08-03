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
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility;

+ (instancetype) newCellWithTextView:(UITextView*)textView
                                name:(NSString*) name
                              margin:(UIEdgeInsets) margin
                     requestViewSize:(CGSize) requestViewSize
                          hAlignment:(WPLCellAlignment)hAlignment
                          vAlignment:(WPLCellAlignment)vAlignment
                          visibility:(WPLVisibility)visibility;

+ (instancetype) newTextViewCellWithName:(NSString*) name
                                  margin:(UIEdgeInsets) margin
                         requestViewSize:(CGSize) requestViewSize
                              hAlignment:(WPLCellAlignment)hAlignment
                              vAlignment:(WPLCellAlignment)vAlignment
                              visibility:(WPLVisibility)visibility;


@end
