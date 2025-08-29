//
//  MICImageUtil.mm
//  layouter
//
//  Created by @toyota-m2k on 2015/02/04.
//  Copyright (c) 2015年 @toyota-m2k. All rights reserved.
//

#import "MICImageUtil.h"
#import "MICCGContext.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

@implementation MICImageUtil

/**
 * UIGraphicsImageRendererのラッパー
 * formatに、opaque, scale を指定する（それら以外はデフォルト値のまま）
 */
+ (UIImage*) withImageRendererContext:(CGSize)size opaque:(bool)opaque scale:(CGFloat)scale action: (void (^)(CGContextRef))action {
    return micWithImageRendererContext(size, opaque, scale, ^(MICCGContext &ctx) {
        action(ctx);
    });
}

/**
 * UIGraphicsImageRendererのラッパー
 * 仕様的に怪しい format 引数を指定しないUIGraphicsImageRendererを使わないようにしている。
 * [MICImageUtil withImageRendererContext:size opaque:false scale:0 action:action] と等価。
 * sale=0 の場合は、UIScreen.mainScreen.scale が使用される。
 */
+ (UIImage*) withImageRendererContext:(CGSize)size action: (void (^)(CGContextRef))action {
    return [self withImageRendererContext:size opaque:false scale:0 action:action];
}

/**
 * 画像のサイズを変更する
 */
+ (UIImage*) image:(UIImage*)originalImage resizeTo:(CGSize)size {
    return micWithImageRendererContext(size, ^(MICCGContext &ctx) {
    [originalImage drawInRect:MICRect(size)];
    });
}

/**
 * 画像（マスク画像）の色を変更する。
 */
+ (UIImage*) image:(UIImage*)maskImage setColor:(UIColor*)color resizeTo:(CGSize)size{
    return micWithImageRendererContext(size, ^(MICCGContext &ctx) {
    MICRect rect(size);
    ctx.setBlendMode(kCGBlendModeNormal);
    [maskImage drawInRect:rect];
    
    ctx.setBlendMode(kCGBlendModeSourceIn);
    ctx.setFillColor(color);
    ctx.createPath().addRect(rect).closePath();
    ctx.fillPath();
    });
}

/**
 * 画像（マスク画像）の色を変更する。
 */
+ (UIImage*) image:(UIImage*)maskImage setColor:(UIColor*)color {
    return [self image:maskImage setColor:color resizeTo:maskImage.size];
}

/**
 * 塗りつぶし用の淡色画像を生成
 */
+ (UIImage*) imageWithColor:(UIColor*)color {
    MICRect rect(0,0,1,1);
    return micWithImageRendererContext(rect.size, ^(MICCGContext &ctx) {
    ctx.setFillColor(color.CGColor);
    ctx.fillRect(rect);
    });
}

/**
 * ビューを画像化する
 */
+ (UIImage*) createImageOfView:(UIView*) view {
    return micWithImageRendererContext(view.bounds.size, view.opaque, ^(MICCGContext &ctx) {
    [view.layer renderInContext:ctx];
    });
}


@end
