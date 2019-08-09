//
//  WPLContainersL.h
//  WPL_GRID_SIZING_AUTO とか、WPL_GRID_SIZING_STRETCH とか、長くて面倒だし、並べたときに数や違いが見えにくいので、
//  短い定義を用意する。ただし、ネームスペースのないobj-cでは、なにかプレフィクスをつけないといけないので、これをグローバルに定義することはできない。
//  仕方がないから、このヘッダファイルは、それを使うソースファイルにのみインポートするように気をつける、という対応で。
//  つまり、ヘッダファイルにインポートしないで、m/mmふぁいるにのみインポートすること。
//
//  Created by Mitsuki Toyota on 2019/08/07.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//
#import "WPLContainerDef.h"

#define AUTO        @(WPL_CELL_SIZING_AUTO)
#define STRC        @(WPL_CELL_SIZING_STRETCH)
#define STRCx(x)    @(WPL_CELL_SIZING_STRETCH*(x))

#define VAUTO       WPL_CELL_SIZING_AUTO
#define VSTRC       WPL_CELL_SIZING_STRETCH

