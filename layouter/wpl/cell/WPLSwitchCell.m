//
//  WPLSwitchCell.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/04.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLSwitchCell.h"
#import "MICVar.h"

@implementation WPLSwitchCell

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    if(nil==view) {
        view = [[UISwitch alloc] init];
    }
    NSAssert([view isKindOfClass:UISwitch.class], @"WPLSwitchCell: view must be instance of UISwitch");
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:nil];
    if(nil!=self) {
        [(UISwitch*)view addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (id) value {
    return @(((UISwitch*)self.view).on);
}

- (void) setValue:(id)v {
    bool bv = ([v isKindOfClass:NSNumber.class]) ? ((NSNumber*)v).boolValue : false;
    if(!(((UISwitch*)self.view).on)!=!bv) {
        ((UISwitch*)self.view).on = bv;
    }
}

- (void) onSwitchChanged:(id) _ {
    [self onValueChanged];
}

@end
