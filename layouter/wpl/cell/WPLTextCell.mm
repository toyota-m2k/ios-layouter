//
//  WPLTextCell.mm
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLTextCell.h"
#import "MICUiRectUtil.h"
#import "MICListeners.h"
#import "MICVar.h"

/**
 * UITextView用のCellクラス
 */
@implementation WPLTextCell {
    bool _textFieldReadOnly;
    MICListeners* _commandListeners;
}

/**
 * 完全な初期化
 */
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
        _commandListeners = nil;
        _textFieldReadOnly = false;
        _closeKeyboardOnReturn = true;
        if([view isKindOfClass:UITextView.class]) {
            ((UITextView*)view).delegate = self;
        } else if([view isKindOfClass:UITextField.class]) {
            ((UITextField*)view).delegate = self;
        }
    }
    return self;
}

- (id) value {
    let view = self.view;
    if([view isKindOfClass:UILabel.class]) {
        return ((UILabel*)view).text;
    } else if([view isKindOfClass:UITextView.class]) {
        return ((UITextView*)view).text;
    } else if([view isKindOfClass:UITextField.class]) {
        return ((UITextField*)view).text;
    } else if([view isKindOfClass:UIButton.class]) {
        return [(UIButton*)view titleForState:UIControlStateNormal];
    } else {
        return @"";
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
        } else if([view isKindOfClass:UIButton.class]) {
            return [(UIButton*)view setTitle:v forState:UIControlStateNormal];
        } else {
            return;
        }
        // [self onValueChanged];
        
        // サイズの自動調整が要求されていれば、変更後の文字列のサイズに合わせてリサイズする
        if(self.requestViewSize.width==WPL_CELL_SIZING_AUTO||self.requestViewSize.height==WPL_CELL_SIZING_AUTO) {
            [view sizeToFit];
            self.needsLayout = true;
        }
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self onValueChanging];
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onValueChanging];
    if(_closeKeyboardOnReturn) {
        [textField resignFirstResponder];
    }
    if(nil!=_actionOnReturn) {
        id me = self;
        [_actionOnReturn performWithParam:&me];
    }
    if(nil!=_commandListeners) {
        [_commandListeners fire:self];
    }
    return false;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self onValueChanging];
    return true;
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

- (void) onValueChanging {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1*NSEC_PER_SEC), dispatch_get_main_queue(), ^(){
        [self onValueChanged];
    });
}

/**
 * Viewへの入力が更新されたときのリスナー登録
 * @param target        listener object
 * @param selector      (cell)->Unit
 * @return key  removeInputListenerに渡して解除する
 */
- (id) addCommandListener:(id)target selector:(SEL)selector {
    if(_commandListeners==nil) {
        _commandListeners = MICListeners.listeners;
    }
    return [_commandListeners addListener:(id)target action:selector];
}

/**
* リスナーの登録を解除
*/
- (void)removeCommandListener:(id)key {
    if(nil!=_commandListeners) {
        [_commandListeners removeListener:key];
    }
}

/**
 * リソースを解放
 */
- (void)dispose {
    [super dispose];
    _actionOnReturn = nil;
    if(nil!=_commandListeners) {
        [_commandListeners removeAll];
        _commandListeners = nil;
    }
}
@end
