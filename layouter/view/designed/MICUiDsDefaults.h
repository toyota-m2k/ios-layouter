//
//  MICUiDsDefaults.h
//
//  Designedクラスのデフォルトの配色、サイズなどの定義
//
//  Created by 豊田 光樹 on 2014/12/18.
//  Copyright (c) 2014年 M.TOYOTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiStatefulResource.h"

#define MICCOLOR_BTN_FASE                [UIColor darkGrayColor]
#define MICCOLOR_BTN_TEXT                [UIColor whiteColor]
#define MICCOLOR_BTN_FACE_ACTIVATED      [UIColor lightGrayColor]
#define MICCOLOR_BTN_TEXT_ACTIVATED      [UIColor darkGrayColor]

#define MICCOLOR_PANEL_FACE            [UIColor lightGrayColor]
#define MICCOLOR_PANEL_TEXT            [UIColor darkGrayColor]

#define MICCOLOR_TAB_FACE                [UIColor grayColor]
#define MICCOLOR_TAB_TEXT                [UIColor blackColor]

#define MICCOLOR_TAB_FACE_SELECTED       MICCOLOR_PANEL_FACE
#define MICCOLOR_TAB_TEXT_SELECTED       [UIColor darkGrayColor]

#define MICCOLOR_TAB_FACE_ACTIVATED      [UIColor darkGrayColor]
#define MICCOLOR_TAB_TEXT_ACTIVATED      [UIColor whiteColor]

#define MICCOLOR_TAB_FACE_DISABLED      [UIColor grayColor]
#define MICCOLOR_TAB_TEXT_DISABLED      [UIColor lightGrayColor]

#define MICCOLOR_TAB_BORDER             [UIColor whiteColor]
#define MICCOLOR_TAB_BACKGROUND         [UIColor blackColor]

// CustomButtonのデフォルト値
#define MIC_BTN_BORDER_WIDTH            0
#define MIC_BTN_ROUND_RADIUS            0
#define MIC_BTN_FONT_SIZE               (12.0f)
#define MIC_BTN_CONTENT_MARGIN          UIEdgeInsetsMake(2.0f,2.0f,2.0f,2.0f)
#define MIC_BTN_ICON_TEXT_MARGIN        (2.0f)

// TabButton のデフォルト値
#define MIC_TAB_BORDER_WIDTH            (0.5f)
#define MIC_TAB_FONT_SIZE               (12.0f)
#define MIC_TAB_ROUND_RADIUS            (10.0f)
#define MIC_TAB_CONTENT_MARGIN          UIEdgeInsetsMake(2.0f,2.0f,2.0f,2.0f)
#define MIC_TAB_ICON_TEXT_MARGIN        (2.0f)

@interface MICUiDsDefaults : NSObject

/**
 * タブ耳ボタンのデフォルト配色
 */
+ (id<MICUiStatefulResourceProtocol>) tabColor;

@end
