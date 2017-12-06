//
//  MICUiDsButton.m
//  LayoutDemo
//
//  Created by 豊田 光樹 on 2014/12/11.
//  Copyright (c) 2014年 M.TOYOTA. All rights reserved.
//

#import "MICUiDsTabButton.h"
#import "MICUiDsDefaults.h"
#import "MICCGContext.h"
#import "MICUiRectUtil.h"

@implementation MICUiDsTabButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(nil!=self){
        self.borderWidth = MIC_TAB_BORDER_WIDTH;
        self.roundRadius = MIC_TAB_ROUND_RADIUS;
        self.fontSize = MIC_TAB_FONT_SIZE;
        self.contentMargin = MIC_TAB_CONTENT_MARGIN;
        self.iconTextMargin = MIC_TAB_ICON_TEXT_MARGIN;
    }
    return self;
}


/**
 * タブ風のボタンにするためにオーバーライド
 */
- (void)eraseBackground:(CGContextRef)rctx rect:(CGRect)rect {
    MICCGContext ctx(rctx);
    
    id<MICUiStatefulResourceProtocol> res = self.colorResources;
    MICUiViewState state = self.buttonState;
    UIColor* colorBg = [res resourceOf:MICUiResTypeBGCOLOR forState:state fallbackState:MICUiViewStateNORMAL];
    UIColor* colorFg = [res resourceOf:MICUiResTypeFGCOLOR forState:state fallbackState:MICUiViewStateNORMAL];
    UIColor* colorBorder = [res resourceOf:MICUiResTypeBORDERCOLOR forState:state fallbackState:MICUiViewStateNORMAL];
    
    if(nil==colorBg) {
        colorBg = [UIColor darkGrayColor];
    }
    if(nil==colorFg) {
        colorFg = [UIColor whiteColor];
    }
    if(nil==colorBorder) {
        colorBorder = colorFg;
    }
    
    MICRect rc = self.bounds;
    
    CGFloat radius = self.roundRadius;
    MICCGContext::Path path = ctx.createPath();
    if(!_attachBottom) {
        path.moveTo(rc.LB());
        path.lineTo(rc.LT());
        
        if(radius!=0) {
            path.addArcToPoint(rc.RT(), rc.RB(), radius);
        } else {
            path.lineTo(rc.LT());
            path.lineTo(rc.RT());
        }
        path.lineTo(rc.RB());
    } else {
        path.moveTo(rc.LT());
        path.lineTo(rc.LB());
        if(radius!=0) {
            path.addArcToPoint(rc.RB(), rc.RT(), radius);
        } else {
            path.lineTo(rc.LB());
            path.lineTo(rc.RB());
        }
        path.lineTo(rc.RT());
    }
    MICCGPath pathCached;
    path.copyPath(pathCached);
    
    path.closePath();
    ctx.setFillColor(colorBg);
    ctx.fillPath();

    if(self.borderWidth>0) {
        path.addPath(pathCached);
        ctx.setStrokeColor(colorBorder);
        ctx.setLineWidth(self.borderWidth);
        ctx.strokePath();
    }
}

//- (void)drawRect:(CGRect)rect {
//    id<MICUiStatefulResourceProtocol> res = self.colorResources;
//    MICUiViewState state = self.buttonState;
//    UIColor* colorBg = [res resourceOf:MICUiResTypeBGCOLOR forState:state fallbackState:MICUiViewStateNORMAL];
//    UIColor* colorFg = [res resourceOf:MICUiResTypeFGCOLOR forState:state fallbackState:MICUiViewStateNORMAL];
//    UIColor* colorBorder = [res resourceOf:MICUiResTypeBORDERCOLOR forState:state fallbackState:MICUiViewStateNORMAL];
//    
//    if(nil==colorBg) {
//        colorBg = [UIColor darkGrayColor];
//    }
//    if(nil==colorFg) {
//        colorFg = [UIColor whiteColor];
//    }
//    if(nil==colorBorder) {
//        colorBorder = colorFg;
//    }
//    
//    MICRect rc = self.bounds;
//    
//    CGFloat radius = ROUND_RADIUS;
//    MICCGContext ctx;
//    MICCGContext::Path path = ctx.createPath();
//    path.moveTo(rc.left(), rc.bottom());
//    path.lineTo(rc.left(), rc.top());
////    path.lineTo(rc.right()-radius*4, rc.top());
//    path.addArc(rc.right()-radius, rc.top()+radius, radius, MIC_RADIAN(-90), 0, false);
////    path.moveTo(rc.right(), rc.top()+radius);
////    path.lineTo(rc.right(), rc.top()+radius);
//    path.lineTo(rc.right(), rc.bottom());
//    MICCGPath pathCached;
//    path.copyPath(pathCached);
//    
//
//    path.closePath();
//    ctx.setFillColor(colorBg);
////    ctx.fillRect(rc);
//    ctx.fillPath();
//    
//    if(self.borderWidth>0) {
//        path.addPath(pathCached);
//        ctx.setStrokeColor(colorBorder);
//        ctx.setLineWidth(1.0f);
//        ctx.strokePath();
//    }
//    
//    
//    
//    if(nil!=self.text) {
//        UIFont *font = [UIFont boldSystemFontOfSize:self.fontSize];
//        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//        style.lineBreakMode = NSLineBreakByTruncatingTail;
//        style.alignment = NSTextAlignmentCenter;
//        NSDictionary *attr = @{
//                               NSForegroundColorAttributeName: colorFg,
//                               NSFontAttributeName: font,
//                               NSParagraphStyleAttributeName: style
//                               };
//        
//        CGSize size = [self.text sizeWithAttributes:attr];
//        
//        rc.deflate(self.borderWidth);
//        rc.deflate(self.contentMargin);
//        
//        MICRect rcText = rc;
//        rcText.size.height = size.height;
//        rcText.moveToVCenterOfOuterRect(rc);
//        
//        [self.text drawInRect:rcText withAttributes:attr];
//    }
//}


@end
