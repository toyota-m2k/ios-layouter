//
//  WPLStackPanelScrollView.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/19.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLStackPanelScrollView.h"
#import "MICVar.h"

@implementation WPLStackPanelScrollView

- (WPLStackPanel*) container {
    let s = self.containerCell;
    return ([s isKindOfClass:WPLStackPanel.class]) ? (WPLStackPanel*)s : nil;
}

- (void) setContainer:(WPLStackPanel*) v {
    self.containerCell = v;
}

+ (instancetype) stackPanelViewWithName:(NSString*) name
                                 params:(WPLStackPanelParams) params {
    let view = [WPLStackPanelScrollView new];
    view.container = [WPLStackPanel stackPanelWithName:name params:params];
    return view;
}

@end
