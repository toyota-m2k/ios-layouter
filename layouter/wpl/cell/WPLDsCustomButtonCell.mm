//
//  WPLDsCustomButtonCell.mm
//  loginMock
//
//  Created by toyota-m2k on 2019/10/30.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLDsCustomButtonCell.h"

@implementation WPLDsCustomButtonCell

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    NSAssert([view isKindOfClass:MICUiDsCustomButton.class], @"WPLSwitchCell: view must be instance of UISwitch");
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:nil];
    return self;
}

- (WPLDsCustomButtonCell*) customButton {
    return [self.view isKindOfClass:MICUiDsCustomButton.class] ? (WPLDsCustomButtonCell*)self.view : nil;
}

/**
 * 有効・無効 getter
 */
- (bool) enabled {
    return self.customButton.enabled;
}

/**
 * 有効・無効 setter
 */
- (void) setEnabled:(bool)v {
    self.customButton.enabled = v;
}

- (id)addTappedListener:(id)target selector:(SEL)selector {
    if(!self.tappedListenerRegistered) {
        [(MICUiDsCustomButton*)self.view setTarget:self action:@selector(onButtonTapped:)];
    }
    return [super addTappedListener:target selector:selector];
}

//- (void)onCustomButtonTapped:(MICUiDsCustomButton *)view {
//
//}
//
//- (void)onCustomButtonStateChangedAt:(MICUiDsCustomButton *)view from:(MICUiViewState)before to:(MICUiViewState)after {
//
//}
@end
