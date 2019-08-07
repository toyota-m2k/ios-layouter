//
//  WPLGridL.h
//  WPL_GRID_SIZING_AUTO とか、WPL_GRID_SIZING_STRETCH とか、長くて面倒だし、並べたときに数や違いが見えにくいので、
//  短い定義を用意する。ただし、ネームスペースのないobj-cでは、なにかプレフィクスをつけないといけないので、これをグローバルに定義することはできない。
//  仕方がないから、このヘッダファイルは、それを使うソースファイルにのみインポートするように気をつける、という対応で。
//
//  Created by Mitsuki Toyota on 2019/08/07.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//
#import "WPLGrid.h"

#define AUTO    @(WPL_GRID_SIZING_AUTO)
#define STRC    @(WPL_GRID_SIZING_STRETCH)
