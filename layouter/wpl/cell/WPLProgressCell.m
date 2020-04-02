//
//  WPLProgressCell.m
//  Anytime
//
//  Created by @toyota-m2k on 2020/02/18.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLProgressCell.h"
#import "MICDicUtil.h"

@implementation WPLProgressCell

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    if(nil==view) {
        view = [[UIProgressView alloc] init];
    }
    NSAssert([view isKindOfClass:UIProgressView.class], @"WPLProgressCell: view must be instance of UIProgressView");
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:nil];
    if(nil!=self) {
    }
    return self;
}

- (id) value {
    return @(((UIProgressView*)self.view).progress);
}

- (void) setValue:(id)v {
    bool fv = ([v isKindOfClass:NSNumber.class]) ? ((NSNumber*)v).floatValue : 0;
    if(fv!=((UIProgressView*)self.view).progress) {
        ((UIProgressView*)self.view).progress = fv;
    }
}

@end
