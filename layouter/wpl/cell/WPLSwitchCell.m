//
//  WPLSwitchCell.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/04.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLSwitchCell.h"
#import "MICVar.h"

@implementation WPLSwitchCell

- (instancetype) initWithView:(UISwitch*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility {
    if(nil==view) {
        view = [[UISwitch alloc] init];
    }
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:nil];
    if(nil!=self) {
        [view addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

+ (instancetype) newCellWithSwitchView:(UISwitch*)switchView
                                name:(NSString*) name
                              margin:(UIEdgeInsets) margin
                     requestViewSize:(CGSize) requestViewSize
                          hAlignment:(WPLCellAlignment)hAlignment
                          vAlignment:(WPLCellAlignment)vAlignment
                          visibility:(WPLVisibility)visibility {
    return [[WPLSwitchCell alloc] initWithView:switchView name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility];
}

- (id) value {
    return @(((UISwitch*)self.view).on);
}

- (void) setValue:(id)v {
    bool bv = ([v isKindOfClass:NSNumber.class]) ? ((NSNumber*)v).boolValue : false;
    ((UISwitch*)self.view).on = bv;
}

- (void) onSwitchChanged:(id) _ {
    [self onValueChanged];
}

@end
