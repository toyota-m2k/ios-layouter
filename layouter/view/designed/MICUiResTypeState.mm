//
//  MICUiResTypeState.m
//  Anytime
//
//  Created by toyota.m2k on 2020/10/15.
//  Copyright © 2020 toyota.m2k. All rights reserved.
//

#import "MICUiResTypeState.h"
#import "MICVar.h"

#if NOT_USED

@implementation MICUiResTypeState

- (instancetype)initWithType:(MICUiResType)type state:(MICUiViewState) state {
    self = [super init];
    if(nil!=self) {
        _type = type;
        _state = state;
    }
    return self;
}

+ (NSString*)stringOfType:(MICUiResType)type {
    switch(type) {
        case MICUiResTypeBGCOLOR:               return @"BgColor";
        case MICUiResTypeFGCOLOR:               return @"FgColor";
        case MICUiResTypeBORDERCOLOR:           return @"BorderColor";
        case MICUiResTypeBGIMAGE:               return @"BgImage";
        case MICUiResTypeICON:                  return @"Icon";
        case MICUiResTypeSVG_PATH:              return @"SvgPath";
        case MICUiResTypeSVG_BGPATH:            return @"SvgBgPath";
        case MICUiResTypeSVG_COLOR:             return @"SvgColor";
        case MICUiResTypeSVG_BGCOLOR:           return @"SvgBgColor";
        case MICUiResTypeSVG_STROKE_COLOR:      return @"SvgStrokeColor";
        case MICUiResTypeSVG_STROKE_BGCOLOR:    return @"SvgStrokeBgColor";
        case MICUiResTypeSVG_STROKE_WIDTH:      return @"SvgStrokeWidth";
        case MICUiResTypeSVG_STROKE_BG_WIDTH:   return @"SvgStrokeBgWidth";
        case MICUiResTypeLAST:
        default:
            NSAssert1(false, @"unknown resource type. (&d)", type);
            return [NSString stringWithFormat:@"<%d>", type];
    }
}

+ (NSString*)stringOfState:(MICUiViewState)state {
    switch(state) {
        case MICUiViewStateNORMAL:              return @"NORMAL";
        case MICUiViewStateSELECTED_:           return @"SELECTED";
        case MICUiViewStateACTIVATED_:          return @"ACTIVATED";
        case MICUiViewStateDISABLED_:           return @"DISABLED";
        case MICUiViewStateDISABLED_SELECTED:   return @"DISABLED_SELECTED";
        case MICUiViewStateACTIVATED_SELECTED:  return @"ACTIVATED_SELECTED";
    }
}

+ (instancetype)type:(MICUiResType)type state:(MICUiViewState)state {
    return [[MICUiResTypeState alloc] initWithType:type state:state];
}

+ (NSString *)keyForType:(MICUiResType)type state:(MICUiViewState)state {
    return [[self stringOfType:type] stringByAppendingString:[self stringOfState:state]];
}

- (NSString *)key {
    return [self.class keyForType:_type state:_state];
}

+ (void) makeKeyTable {
    int stateList[] = {MICUiViewStateNORMAL, MICUiViewStateSELECTED_, MICUiViewStateACTIVATED_, MICUiViewStateDISABLED_, MICUiViewStateDISABLED_SELECTED, MICUiViewStateACTIVATED_SELECTED, -1};
    for(int t = 0 ; t<MICUiResTypeLAST; t++) {
        for(int* s=stateList ; *s!=-1 ; s++) {
            let key = [self keyForType:(MICUiResType)t state:(MICUiViewState)*s];
            NSLog(@"#define MICUiStateful%@ @\"%@\"", key, key);
        }
        NSLog(@"");
    }
}

@end
#endif

