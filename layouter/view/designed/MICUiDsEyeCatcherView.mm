//
//  MICUiDsEyeCatcherView.m
//  吹き出しにiマーク＋メッセージで、ちょっとした注意や説明を表示するビュー
//
//  Created by @toyota-m2k on 2020/02/05.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "MICUiDsEyeCatcherView.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "MICUiColorUtil.h"
#import "MICCGContext.h"

#define PATH_BALLOON @"M12,3C17.5,3 22,6.58 22,11C22,15.42 17.5,19 12,19C10.76,19 9.57,18.82 8.47,18.5C5.55,21 2,21 2,21C4.33,18.67 4.7,17.1 4.75,16.5C3.05,15.07 2,13.13 2,11C2,6.58 6.5,3 12,3M11,14V16H13V14H11M11,12H13V6H11V12Z"

@implementation MICUiDsEyeCatcherView

- (instancetype) initWithMessage:(NSString*) string
                     isMultiLine:(bool) isMultiLine
                  pathRepository:(MICPathRepository*) repo {
    self = [super initWithFrame:MICRect() iconSize:MICSize(24) pathViewboxSize:MICSize(24) pathRepositiory:repo];
    if(nil!=self) {
        self.text = string;
        self.multiLineText = isMultiLine;
        self.borderWidth = 0.5;
        self.contentMargin += MICEdgeInsets(8);
        self.roundRadius = 3;
        self.textHorzAlignment = MICUiAlignLEFT;
        self.iconTextMargin += 4;
        self.colorResources = [[MICUiStatefulResource alloc] initWithDictionary:@{
            MICUiStatefulBgColorNORMAL:UIColor.whiteColor,
            MICUiStatefulFgColorNORMAL:UIColor.blackColor,
            MICUiStatefulBorderColorNORMAL:UIColor.grayColor,
            MICUiStatefulSvgPathNORMAL:PATH_BALLOON,
            MICUiStatefulSvgColorNORMAL:MICUiColorRGB(0x0050FF),
        }];
    }
    return self;
}

- (CGSize)iconSize {
    return MICSize(self.fontSize * 1.3);
}

- (void)getContentRect:(UIImage *)icon iconRect:(CGRect *)prcIcon textRect:(CGRect *)prcText {
    MICRect rcIcon, rcText;
    [super getContentRect:icon iconRect:&rcIcon textRect:&rcText];
    if(rcText.top()<rcIcon.top()) {
        rcIcon.moveTop(rcText.top());
    }
    *prcIcon = rcIcon;
    *prcText = rcText;
}

- (void)drawIcon:(CGContextRef)rctx icon:(UIImage *)icon rect:(CGRect)rect {
    [[self.pathRepository getPath:PATH_BALLOON viewboxSize:MICSize(24)] draw:rctx
                                                                     dstRect:rect
                                                                   fillColor:[self.colorResources resourceOf:MICUiResTypeSVG_COLOR
                                                                                                    forState:MICUiViewStateNORMAL]
                                                                      stroke:nil
                                                                 strokeWidth:0
                                                                     mirrorX:true
                                                                     mirrorY:false];
}

@end
