//
//  MICUiResTypeState.h
//  Anytime
//
//  Created by toyota.m2k on 2020/10/15.
//  Copyright © 2020 toyota.m2k. All rights reserved.
//

#import <Foundation/Foundation.h>

#if NOT_USED

/**
 * ビューの状態
 */
typedef enum _micUiViewState : unsigned int {
    MICUiViewStateNORMAL        = 0,
    MICUiViewStateSELECTED_      = 0x01,
    MICUiViewStateACTIVATED_     = 0x02,
    MICUiViewStateDISABLED_      = 0x04,
    MICUiViewStateDISABLED_SELECTED     = 0x04|0x01,
    MICUiViewStateACTIVATED_SELECTED    = 0x02|0x01,
} MICUiViewState;

#define MICUiViewState_IsSelected(v) (((v)&MICUiViewStateSELECTED_)==MICUiViewStateSELECTED_)
#define MICUiViewState_IsDisabled(v) (((v)&MICUiViewStateDISABLED_)==MICUiViewStateDISABLED_)
#define MICUiViewState_IsActivated(v) (((v)&MICUiViewStateACTIVATED_)==MICUiViewStateACTIVATED_)

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
    MICUiResTypeSVG_BGPATH,     // SVG BGPath
    MICUiResTypeSVG_COLOR,      // fill color of fg SVG path
    MICUiResTypeSVG_BGCOLOR,    // fill color of bg SVG Path
    MICUiResTypeSVG_STROKE_COLOR,      // stroke color of fg SVG path
    MICUiResTypeSVG_STROKE_BGCOLOR,    // stroke color of bg SVG Path
    MICUiResTypeSVG_STROKE_WIDTH,      // stroke width of fg SVG path
    MICUiResTypeSVG_STROKE_BG_WIDTH,   // stroke width of bg SVG Path
    //----
    MICUiResTypeLAST
} MICUiResType;

@interface MICUiResTypeState : NSObject
@property (nonatomic, readonly) MICUiResType type;
@property (nonatomic, readonly) MICUiViewState state;
@property (nonatomic, readonly, nonnull) NSString* key;
- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) type:(MICUiResType) type state:(MICUiViewState)state;
+ (NSString*) keyForType:(MICUiResType)type state:(MICUiViewState)state;
+ (void) makeKeyTable;
@end

#define MICUiRES(t,s)  [MICUiResTypeState type:t state:s]

// 従来の名前ベースの実装との互換性のための定義
#define MICUiStatefulBgColorNORMAL @"BgColorNORMAL"
#define MICUiStatefulBgColorSELECTED @"BgColorSELECTED"
#define MICUiStatefulBgColorACTIVATED @"BgColorACTIVATED"
#define MICUiStatefulBgColorDISABLED @"BgColorDISABLED"
#define MICUiStatefulBgColorDISABLED_SELECTED @"BgColorDISABLED_SELECTED"
#define MICUiStatefulBgColorACTIVATED_SELECTED @"BgColorACTIVATED_SELECTED"

#define MICUiStatefulFgColorNORMAL @"FgColorNORMAL"
#define MICUiStatefulFgColorSELECTED @"FgColorSELECTED"
#define MICUiStatefulFgColorACTIVATED @"FgColorACTIVATED"
#define MICUiStatefulFgColorDISABLED @"FgColorDISABLED"
#define MICUiStatefulFgColorDISABLED_SELECTED @"FgColorDISABLED_SELECTED"
#define MICUiStatefulFgColorACTIVATED_SELECTED @"FgColorACTIVATED_SELECTED"

#define MICUiStatefulBorderColorNORMAL @"BorderColorNORMAL"
#define MICUiStatefulBorderColorSELECTED @"BorderColorSELECTED"
#define MICUiStatefulBorderColorACTIVATED @"BorderColorACTIVATED"
#define MICUiStatefulBorderColorDISABLED @"BorderColorDISABLED"
#define MICUiStatefulBorderColorDISABLED_SELECTED @"BorderColorDISABLED_SELECTED"
#define MICUiStatefulBorderColorACTIVATED_SELECTED @"BorderColorACTIVATED_SELECTED"

#define MICUiStatefulBgImageNORMAL @"BgImageNORMAL"
#define MICUiStatefulBgImageSELECTED @"BgImageSELECTED"
#define MICUiStatefulBgImageACTIVATED @"BgImageACTIVATED"
#define MICUiStatefulBgImageDISABLED @"BgImageDISABLED"
#define MICUiStatefulBgImageDISABLED_SELECTED @"BgImageDISABLED_SELECTED"
#define MICUiStatefulBgImageACTIVATED_SELECTED @"BgImageACTIVATED_SELECTED"

#define MICUiStatefulIconNORMAL @"IconNORMAL"
#define MICUiStatefulIconSELECTED @"IconSELECTED"
#define MICUiStatefulIconACTIVATED @"IconACTIVATED"
#define MICUiStatefulIconDISABLED @"IconDISABLED"
#define MICUiStatefulIconDISABLED_SELECTED @"IconDISABLED_SELECTED"
#define MICUiStatefulIconACTIVATED_SELECTED @"IconACTIVATED_SELECTED"

#define MICUiStatefulSvgPathNORMAL @"SvgPathNORMAL"
#define MICUiStatefulSvgPathSELECTED @"SvgPathSELECTED"
#define MICUiStatefulSvgPathACTIVATED @"SvgPathACTIVATED"
#define MICUiStatefulSvgPathDISABLED @"SvgPathDISABLED"
#define MICUiStatefulSvgPathDISABLED_SELECTED @"SvgPathDISABLED_SELECTED"
#define MICUiStatefulSvgPathACTIVATED_SELECTED @"SvgPathACTIVATED_SELECTED"

#define MICUiStatefulSvgBgPathNORMAL @"SvgBgPathNORMAL"
#define MICUiStatefulSvgBgPathSELECTED @"SvgBgPathSELECTED"
#define MICUiStatefulSvgBgPathACTIVATED @"SvgBgPathACTIVATED"
#define MICUiStatefulSvgBgPathDISABLED @"SvgBgPathDISABLED"
#define MICUiStatefulSvgBgPathDISABLED_SELECTED @"SvgBgPathDISABLED_SELECTED"
#define MICUiStatefulSvgBgPathACTIVATED_SELECTED @"SvgBgPathACTIVATED_SELECTED"

#define MICUiStatefulSvgColorNORMAL @"SvgColorNORMAL"
#define MICUiStatefulSvgColorSELECTED @"SvgColorSELECTED"
#define MICUiStatefulSvgColorACTIVATED @"SvgColorACTIVATED"
#define MICUiStatefulSvgColorDISABLED @"SvgColorDISABLED"
#define MICUiStatefulSvgColorDISABLED_SELECTED @"SvgColorDISABLED_SELECTED"
#define MICUiStatefulSvgColorACTIVATED_SELECTED @"SvgColorACTIVATED_SELECTED"

#define MICUiStatefulSvgBgColorNORMAL @"SvgBgColorNORMAL"
#define MICUiStatefulSvgBgColorSELECTED @"SvgBgColorSELECTED"
#define MICUiStatefulSvgBgColorACTIVATED @"SvgBgColorACTIVATED"
#define MICUiStatefulSvgBgColorDISABLED @"SvgBgColorDISABLED"
#define MICUiStatefulSvgBgColorDISABLED_SELECTED @"SvgBgColorDISABLED_SELECTED"
#define MICUiStatefulSvgBgColorACTIVATED_SELECTED @"SvgBgColorACTIVATED_SELECTED"

#define MICUiStatefulSvgStrokeColorNORMAL @"SvgStrokeColorNORMAL"
#define MICUiStatefulSvgStrokeColorSELECTED @"SvgStrokeColorSELECTED"
#define MICUiStatefulSvgStrokeColorACTIVATED @"SvgStrokeColorACTIVATED"
#define MICUiStatefulSvgStrokeColorDISABLED @"SvgStrokeColorDISABLED"
#define MICUiStatefulSvgStrokeColorDISABLED_SELECTED @"SvgStrokeColorDISABLED_SELECTED"
#define MICUiStatefulSvgStrokeColorACTIVATED_SELECTED @"SvgStrokeColorACTIVATED_SELECTED"

#define MICUiStatefulSvgStrokeBgColorNORMAL @"SvgStrokeBgColorNORMAL"
#define MICUiStatefulSvgStrokeBgColorSELECTED @"SvgStrokeBgColorSELECTED"
#define MICUiStatefulSvgStrokeBgColorACTIVATED @"SvgStrokeBgColorACTIVATED"
#define MICUiStatefulSvgStrokeBgColorDISABLED @"SvgStrokeBgColorDISABLED"
#define MICUiStatefulSvgStrokeBgColorDISABLED_SELECTED @"SvgStrokeBgColorDISABLED_SELECTED"
#define MICUiStatefulSvgStrokeBgColorACTIVATED_SELECTED @"SvgStrokeBgColorACTIVATED_SELECTED"

#define MICUiStatefulSvgStrokeWidthNORMAL @"SvgStrokeWidthNORMAL"
#define MICUiStatefulSvgStrokeWidthSELECTED @"SvgStrokeWidthSELECTED"
#define MICUiStatefulSvgStrokeWidthACTIVATED @"SvgStrokeWidthACTIVATED"
#define MICUiStatefulSvgStrokeWidthDISABLED @"SvgStrokeWidthDISABLED"
#define MICUiStatefulSvgStrokeWidthDISABLED_SELECTED @"SvgStrokeWidthDISABLED_SELECTED"
#define MICUiStatefulSvgStrokeWidthACTIVATED_SELECTED @"SvgStrokeWidthACTIVATED_SELECTED"

#define MICUiStatefulSvgStrokeBgWidthNORMAL @"SvgStrokeBgWidthNORMAL"
#define MICUiStatefulSvgStrokeBgWidthSELECTED @"SvgStrokeBgWidthSELECTED"
#define MICUiStatefulSvgStrokeBgWidthACTIVATED @"SvgStrokeBgWidthACTIVATED"
#define MICUiStatefulSvgStrokeBgWidthDISABLED @"SvgStrokeBgWidthDISABLED"
#define MICUiStatefulSvgStrokeBgWidthDISABLED_SELECTED @"SvgStrokeBgWidthDISABLED_SELECTED"
#define MICUiStatefulSvgStrokeBgWidthACTIVATED_SELECTED @"SvgStrokeBgWidthACTIVATED_SELECTED"

#endif
