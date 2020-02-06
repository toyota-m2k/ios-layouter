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

@implementation MICImageUtil


/**
 * 画像のサイズを変更する
 */
+ (UIImage*) image:(UIImage*)originalImage resizeTo:(CGSize)size {
    MICCGImageContext ctx(size);
    [originalImage drawInRect:MICRect(size)];
    return ctx.getCurrentImage();
}

/**
 * 画像（マスク画像）の色を変更する。
 */
+ (UIImage*) image:(UIImage*)maskImage setColor:(UIColor*)color resizeTo:(CGSize)size{
    MICRect rect(size);
    MICCGImageContext ctx(size);
    ctx.setBlendMode(kCGBlendModeNormal);
    [maskImage drawInRect:rect];
    
    ctx.setBlendMode(kCGBlendModeSourceIn);
    ctx.setFillColor(color);
    ctx.createPath().addRect(rect).closePath();
    ctx.fillPath();

    return ctx.getCurrentImage();
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
    MICCGImageContext ctx(rect.size);
    ctx.setFillColor(color.CGColor);
    ctx.fillRect(rect);
    return ctx.getCurrentImage();
}

/**
 * ビューを画像化する
 */
+ (UIImage*) createImageOfView:(UIView*) view {
    MICCGImageContext ctx(view.bounds.size, view.opaque, 0);
    [view.layer renderInContext:ctx];
    return ctx.getCurrentImage();
}


@end
