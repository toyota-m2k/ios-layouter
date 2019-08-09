//
//  WPLStackPanelView.mm
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/09.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLStackPanelView.h"
#import "MICVar.h"

@implementation WPLStackPanelView

- (WPLStackPanel*) container {
    let s = self.containerCell;
    return ([s isKindOfClass:WPLStackPanel.class]) ? (WPLStackPanel*)s : nil;
}

- (void) setContainer:(WPLStackPanel*) v {
    self.containerCell = v;
}

+ (instancetype) stackPanelViewWithName:(NSString*) name
                                 params:(WPLStackPanelParams) params {
    let view = [WPLStackPanelView new];
    view.container = [WPLStackPanel stackPanelWithName:name params:params];
    return view;
}

@end
