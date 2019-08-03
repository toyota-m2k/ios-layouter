﻿//
//  MICUiStatefulResource.h
//
//  状態依存のリソースを保持するためのクラス
//
//  Created by @toyota-m2k on 2014/12/15.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * ビューの状態
 */
typedef enum _micUiViewState {
    MICUiViewStateNORMAL,
    MICUiViewStateSELECTED,
    MICUiViewStateACTIVATED,
    MICUiViewStateDISABLED,
} MICUiViewState;

/**
 * リソースのタイプ
 */
typedef enum _micUiResType {
    MICUiResTypeBGCOLOR,
    MICUiResTypeFGCOLOR,
    MICUiResTypeBORDERCOLOR,
    MICUiResTypeBGIMAGE,
    MICUiResTypeICON,
    MICUiResTypeSVG_PATH,       // SVG Path
    MICUiResTypeSVG_COLOR,      // fill color of SVG path
    ////
    __MICUIRESTYPECOUNT
} MICUiResType;

#define MICUiStatefulBgColorNORMAL    @"BgNormal"
#define MICUiStatefulBgColorSELECTED  @"BgSelected"
#define MICUiStatefulBgColorACTIVATED @"BgActivated"
#define MICUiStatefulBgColorDISABLED  @"BgDisabled"

#define MICUiStatefulFgColorNORMAL    @"FgNormal"
#define MICUiStatefulFgColorSELECTED  @"FgSelected"
#define MICUiStatefulFgColorACTIVATED @"FgActivated"
#define MICUiStatefulFgColorDISABLED  @"FgDisabled"

#define MICUiStatefulBorderColorNORMAL    @"BorderNormal"
#define MICUiStatefulBorderColorSELECTED  @"BorderSelected"
#define MICUiStatefulBorderColorACTIVATED @"BorderActivated"
#define MICUiStatefulBorderColorDISABLED  @"BorderDisabled"

#define MICUiStatefulBgImageNORMAL    @"BgImageNormal"
#define MICUiStatefulBgImageSELECTED  @"BgImageSelected"
#define MICUiStatefulBgImageACTIVATED @"BgImageActivated"
#define MICUiStatefulBgImageDISABLED  @"BgImageDisabled"

#define MICUiStatefulIconNORMAL    @"IconNormal"
#define MICUiStatefulIconSELECTED  @"IconSelected"
#define MICUiStatefulIconACTIVATED @"IconActivated"
#define MICUiStatefulIconDISABLED  @"IconDisabled"

#define MICUiStatefulSvgPathNORMAL    @"SvgPathNormal"
#define MICUiStatefulSvgPathSELECTED  @"SvgPathSelected"
#define MICUiStatefulSvgPathACTIVATED @"SvgPathActivated"
#define MICUiStatefulSvgPathDISABLED  @"SvgPathDisabled"

#define MICUiStatefulSvgColorNORMAL    @"SvgColorNormal"
#define MICUiStatefulSvgColorSELECTED  @"SvgColorSelected"
#define MICUiStatefulSvgColorACTIVATED @"SvgColorActivated"
#define MICUiStatefulSvgColorDISABLED  @"SvgColorDisabled"

/**
 * 状態依存リソースのi/f定義
 */
@protocol MICUiStatefulResourceProtocol

- (id)resourceOf:(MICUiResType)type forState:(MICUiViewState)state;
- (id)resourceOf:(MICUiResType)type forState:(MICUiViewState)state fallbackState:(MICUiViewState)fallback;

@end

/**
 * 状態依存リソースの実装クラス
 */
@interface MICUiStatefulResource : NSObject<MICUiStatefulResourceProtocol>

- (instancetype) init;
- (instancetype) initWithDictionary:(NSDictionary*)definition;

- (void)setResource:(id)res forName:(NSString *)name;
- (void)complementResource:(id)res forName:(NSString *)name;
- (void)mergeResource:(MICUiStatefulResource*) src overwrite:(bool)overwrite;
- (void)mergeWithDictionary:(NSDictionary*) src overwrite:(bool)overwrite;

- (id)getResourceForName:(NSString *)name;
+ (NSString*)getStateName:(MICUiResType)type forState:(MICUiViewState)state;

@end

/**
 * 状態依存リソースi/fを継承する、状態やタイプに依存しない固定リソース。
 * 状態依存リソースを要求するプロパティなどに、状態に依存しないリソース（アイコンなど）を指定する場合に使用。
 */
@interface MICUiMonoResource : NSObject<MICUiStatefulResourceProtocol>

- (instancetype) init;
- (instancetype) initWithResource:(id)res;

@property (nonatomic) id resource;
@end

/**
 * 状態依存リソースi/fを継承する、状態に依存しない
 * 状態依存リソースを要求するプロパティなどに、状態に依存しないリソース（アイコンなど）を指定する場合に使用。
 */
@interface MICUiUnstatefulResource : NSObject<MICUiStatefulResourceProtocol>

- (instancetype) init;
- (instancetype) initWithBackground:(id)bg foreground:(id)fg border:(id)border bgimage:(id)bgimage icon:(id)icon;


@end

