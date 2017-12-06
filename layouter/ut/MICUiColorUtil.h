//
//  MICUiColorUtil.h
//
//  Created by 豊田 光樹 on 2015/03/17.
//  Copyright (c) 2015年 M.TOYOTA Corporation. All rights reserved.
//

/**
 * 0xABCDEF のような　UINT型RGB値から　UIColorを生成
 */
#define MICUiColorRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/**
 * 0xFFABCDEF のような　UINT型ARGB値から　UIColorを生成
 */
#define MICUiColorARGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((rgbValue&0xFF000000)>>24))/255.0];

/**
 * 256階調R,G,B値からUIColorを生成
 */
#define MICUiColorRGB256(r,g,b) [UIColor colorWithRed:((float)(r))/255.0 green:((float)(g))/255.0 blue:((float)(b))/255.0 alpha:1.0]

/**
 * 256階調A,R,G,B値からUIColorを生成
 */
#define MICUiColorARGB256(a,r,g,b) [UIColor colorWithRed:((float)(r))/255.0 green:((float)(g))/255.0 blue:((float)(b))/255.0 alpha:((float)(a))/255.0];
