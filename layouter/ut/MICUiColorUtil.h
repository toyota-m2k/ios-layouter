//
//  MICUiColorUtil.h
//
//  Created by @toyota-m2k on 2015/03/17.
//  Copyright (c) 2015年 @toyota-m2k Corporation. All rights reserved.
//

/**
 * 0xABCDEF のような　UINT型RGB値から　UIColorを生成
 */
#define MICUiColorRGB(rgbValue) [UIColor colorWithRed:((CGFloat)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((CGFloat)(((rgbValue) & 0xFF00) >> 8))/255.0 blue:((CGFloat)((rgbValue) & 0xFF))/255.0 alpha:1.0]

/**
 * 0xFFABCDEF のような　UINT型ARGB値から　UIColorを生成
 */
#define MICUiColorARGB(rgbValue) [UIColor colorWithRed:((CGFloat)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((CGFloat)(((rgbValue) & 0xFF00) >> 8))/255.0 blue:((CGFloat)((rgbValue) & 0xFF))/255.0 alpha:((CGFloat)(((rgbValue)&0xFF000000)>>24))/255.0]

/**
 * 256階調R,G,B値からUIColorを生成
 */
#define MICUiColorRGB256(r,g,b) [UIColor colorWithRed:((CGFloat)(r))/255.0 green:((CGFloat)(g))/255.0 blue:((CGFloat)(b))/255.0 alpha:1.0]

/**
 * 256階調A,R,G,B値からUIColorを生成
 */
#define MICUiColorARGB256(a,r,g,b) [UIColor colorWithRed:((CGFloat)(r))/255.0 green:((CGFloat)(g))/255.0 blue:((CGFloat)(b))/255.0 alpha:((CGFloat)(a))/255.0]
