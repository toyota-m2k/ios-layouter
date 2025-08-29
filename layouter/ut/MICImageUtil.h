//
//  MICImageUtil.h
//
//  すでにあるのかもしれないし、ないかもしれない、あったとしても、どこにあるかわからない、そんなUIImageに対する操作を実装するクラス。
//
//  Created by @toyota-m2k on 2015/02/04.
//  Copyright (c) 2015年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MICImageUtil : NSObject

/**
 * UIGraphicsImageRendererのラッパー
 * formatに、opaque, scale を指定する（それら以外はデフォルト値のまま）
 */
+ (UIImage*) withImageRendererContext:(CGSize)size opaque:(bool)opaque scale:(CGFloat)scale action: (void (^)(CGContextRef))action;

/**
 * UIGraphicsImageRendererのラッパー
 * 仕様的に怪しい format 引数を指定しないUIGraphicsImageRendererを使わないようにしている。
 * [MICImageUtil withImageRendererContext:size opaque:false scale:0 action:action] と等価。
 * sale=0 の場合は、UIScreen.mainScreen.scale が使用される。
 */
+ (UIImage*) withImageRendererContext:(CGSize)size action: (void (^)(CGContextRef))action;

/**
 * 画像のサイズを変更する
 */
+ (UIImage*) image:(UIImage*)originalImage resizeTo:(CGSize)size;

/**
 * 画像（マスク画像）の色を変更する。
 */
+ (UIImage*) image:(UIImage*)maskImage setColor:(UIColor*)color;

/**
 * 画像（マスク画像）の色を変更し、サイズも指定する。
 */
+ (UIImage*) image:(UIImage*)maskImage setColor:(UIColor*)color resizeTo:(CGSize)size;

/**
 * 塗りつぶし用の単色画像を生成
 */
+ (UIImage*) imageWithColor:(UIColor*)color;

/**
 * ビューを画像化する
 */
+ (UIImage*) createImageOfView:(UIView*) view;

@end
