//
//  MICImageUtil.h
//
//  すでにあるのかもしれないし、ないかもしれない、あったとしても、どこにあるかわからない、そんなUIImageに対する操作を実装するクラス。
//
//  Created by 豊田 光樹 on 2015/02/04.
//  Copyright (c) 2015年 M.TOYOTA Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MICImageUtil : NSObject

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
 * 塗りつぶし用の淡色画像を生成
 */
+ (UIImage*) imageWithColor:(UIColor*)color;

/**
 * ビューを画像化する
 */
+ (UIImage*) createImageOfView:(UIView*) view;

@end
