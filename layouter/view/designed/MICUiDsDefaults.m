//
//  MICUiDsDef.m
//
//  Designedクラスのデフォルトの配色、サイズなどの定義
//
//  Created by @toyota-m2k on 2014/12/18.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiDsDefaults.h"

@implementation MICUiDsDefaults

/**
 * タブ耳の配色
 */
+ (id<MICUiStatefulResourceProtocol>) tabColor {
    static MICUiStatefulResource* s_res = nil;
    if(s_res == nil) {
        s_res = [[MICUiStatefulResource alloc] initWithDictionary:@{
                        MICUiStatefulBgColorNORMAL: MICCOLOR_TAB_FACE,
                        MICUiStatefulBgColorSELECTED: MICCOLOR_TAB_FACE_SELECTED,
                        MICUiStatefulBgColorACTIVATED: MICCOLOR_TAB_FACE_ACTIVATED,
                        MICUiStatefulBgColorDISABLED: MICCOLOR_TAB_FACE_DISABLED,
                        
                        MICUiStatefulFgColorNORMAL: MICCOLOR_TAB_TEXT,
                        MICUiStatefulFgColorSELECTED: MICCOLOR_TAB_TEXT_SELECTED,
                        MICUiStatefulFgColorACTIVATED: MICCOLOR_TAB_TEXT_ACTIVATED,
                        MICUiStatefulFgColorDISABLED: MICCOLOR_TAB_TEXT_DISABLED,
                        
                        MICUiStatefulBorderColorNORMAL: MICCOLOR_TAB_BORDER,
                        }];
    }
    return s_res;
}


@end
