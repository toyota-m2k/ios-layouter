//
//  MICUiColorUtil.m
//  Anytime
//
//  Created by Mitsuki Toyota on 2021/05/26.
//  Copyright © 2025 toyota-m2k Corporation. All rights reserved.
//

#import "MICUiColorUtil.h"

UIColor* MICUiDynColor(UIColor* light, UIColor* dark) {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * (UITraitCollection * dynamicProvider) {
            if (dynamicProvider.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return  dark;
            } else {
                return light;
            }
        }];
    } else {
        return light;
    }
}

