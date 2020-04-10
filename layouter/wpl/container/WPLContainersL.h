//
//  WPLContainersL.h
//  WPL_GRID_SIZING_AUTO とか、WPL_GRID_SIZING_STRETCH とか、長くて面倒だし、並べたときに数や違いが見えにくいので、
//  短い定義を用意する。ただし、ネームスペースのないobj-cでは、なにかプレフィクスをつけないといけないので、これをグローバルに定義することはできない。
//  仕方がないから、このヘッダファイルは、それを使うソースファイルにのみインポートするように気をつける、という対応で。
//  つまり、ヘッダファイルにインポートしないで、m/mmふぁいるにのみインポートすること。
//
//  Created by toyota-m2k on 2019/08/07.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//
#import "WPLCellL.h"
#import "WPLContainerDef.h"
#import "WPLRangedSize.h"

#define AUTO        @(WPL_CELL_SIZING_AUTO)
#define STRC        @(WPL_CELL_SIZING_STRETCH)
#define STRCx(x)    @(WPL_CELL_SIZING_STRETCH*(x))

#define AUTO_MIN(min)           [WPLRangedSize rangedAutoMin:min max:CGFLOAT_MAX];
#define AUTO_MAX(ax)            [WPLRangedSize rangedAutoMin:CGFLOAT_MIN max:max];
#define AUTO_MIN_MAX(min,max)   [WPLRangedSize rangedAutoMin:min max:max];

#define STRC_MIN(min)           [WPLRangedSize rangedStretch:1 min:min max:CGFLOAT_MAX];
#define STRC_MAX(max)           [WPLRangedSize rangedStretch:1 min:CGFLOAT_MIN max:max];
#define STRC_MIN_MAX(min,max)   [WPLRangedSize rangedStretch:1 min:min max:max];

#define STRCx_MIN(s,min)           [WPLRangedSize rangedStretch:s min:min max:CGFLOAT_MAX];
#define STRCx_MAX(s,max)           [WPLRangedSize rangedStretch:s min:CGFLOAT_MIN max:max];
#define STRCx_MIN_MAX(s,min,max)   [WPLRangedSize rangedStretch:s min:min max:max];

#define VAUTO       WPL_CELL_SIZING_AUTO
#define VSTRC       WPL_CELL_SIZING_STRETCH


