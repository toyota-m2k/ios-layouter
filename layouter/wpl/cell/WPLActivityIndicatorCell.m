//
//  WPLActivityIndicatorCell.m
//
//  Created by toyota-m2k on 2020/04/16.
//  Copyright © 2020 toyota-m2k. All rights reserved.
//

#import "WPLActivityIndicatorCell.h"

@implementation WPLActivityIndicatorCell {
    
}

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                    limitWidth:(WPLMinMax) limitWidth
                   limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility {
    if(nil==view) {
        view = [[UIActivityIndicatorView alloc] init];
    }
    NSAssert([view isKindOfClass:UIActivityIndicatorView.class], @"WPLActivityIndicatorCell: view must be instance of UIActivityIndicatorView");
    self = [super initWithView:view
                          name:name
                        margin:margin
               requestViewSize:requestViewSize
                    limitWidth:limitWidth
                   limitHeight:limitHeight
                    hAlignment:hAlignment
                    vAlignment:vAlignment
                    visibility:visibility];
    if(nil!=self) {
    }
    return self;
}

- (id) value {
    return @(((UIActivityIndicatorView*)self.view).isAnimating);
}

- (void) setValue:(id)v {
    bool bv = ([v isKindOfClass:NSNumber.class]) ? ((NSNumber*)v).boolValue : false;
    if(bv!=((UIActivityIndicatorView*)self.view).isAnimating) {
        if(bv) {
            [(UIActivityIndicatorView*)self.view startAnimating];
        } else {
            [(UIActivityIndicatorView*)self.view stopAnimating];
        }
    }
}


@end
