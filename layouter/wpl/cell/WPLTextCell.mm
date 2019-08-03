//
//  WPLTextCell.mm
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLTextCell.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

/**
 * UITextView用のCellクラス
 */
@implementation WPLTextCell {
    bool _textFieldReadOnly;
}
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
    if(nil!=self) {
        _textFieldReadOnly = false;
        if([view isKindOfClass:UITextView.class]) {
            ((UITextView*)view).delegate = self;
        } else if([view isKindOfClass:UITextField.class]) {
            ((UITextField*)view).delegate = self;
        }
    }
    return self;
}

+ (instancetype) newCellWithView:(UIView*)view
                            name:(NSString*) name
                          margin:(UIEdgeInsets) margin
                 requestViewSize:(CGSize) requestViewSize
                      hAlignment:(WPLCellAlignment)hAlignment
                      vAlignment:(WPLCellAlignment)vAlignment
                      visibility:(WPLVisibility)visibility
               containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    
    return [[WPLTextCell alloc] initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
}

- (id) value {
    let view = self.view;
    if([view isKindOfClass:UILabel.class]) {
        return ((UILabel*)view).text;
    } else if([view isKindOfClass:UITextView.class]) {
        return ((UITextView*)view).text;
    } else if([view isKindOfClass:UITextField.class]) {
        return ((UITextField*)view).text;
    } else {
        return nil;
    }
}

- (void) setValue:(id)v {
    id current = self.value;
    if(nil==current) {
        current = @"";
    }
    if(nil==v) {
        v = @"";
    }
    
    if([v isKindOfClass:NSString.class] && ![v isEqual:current]) {
        let view = self.view;
        if([view isKindOfClass:UILabel.class]) {
            ((UILabel*)view).text = v;
        } else if([view isKindOfClass:UITextView.class]) {
            ((UITextView*)view).text = v;
        } else if([view isKindOfClass:UITextField.class]) {
            ((UITextField*)view).text = v;
        } else {
            return;
        }
        // [self onValueChanged];
    }
}

- (NSString*) textValue {
    return (NSString*) self.value;
}

- (void) setTextValue:(NSString*)v {
    self.value = v;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self onValueChanged];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self onValueChanged];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return !_textFieldReadOnly;
}

- (bool) readonly {
    let view = self.view;
    if([view isKindOfClass:UILabel.class]) {
        return true;
    } else if([view isKindOfClass:UITextView.class]) {
        return !((UITextView*)view).editable;
    } else if([view isKindOfClass:UITextField.class]) {
        return _textFieldReadOnly;
    } else {
        return false;
    }
}

- (void) setReadonly:(bool)readonly {
    let view = self.view;
    if([view isKindOfClass:UILabel.class]) {
    } else if([view isKindOfClass:UITextView.class]) {
        ((UITextView*)view).editable = !readonly;
    } else if([view isKindOfClass:UITextField.class]) {
        _textFieldReadOnly = readonly;
    } else {
    }
}

@end
