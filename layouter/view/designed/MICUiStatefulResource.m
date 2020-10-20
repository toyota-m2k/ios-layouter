//
//  MICUiStatefulResource.m
//
//  状態依存のリソースを保持するためのクラス
//
//  Created by @toyota-m2k on 2014/12/15.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiStatefulResource.h"
#import "MICVar.h"

@implementation MICUiStatefulResource {
    NSDictionary* _resources;
}

- (instancetype)init {
    return [self initWithDictionary:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)definitions {
    self = [super init];
    if(nil!=self){
        if(definitions!=nil) {
            _resources = definitions;
        } else {
            _resources = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (NSDictionary *)asDictionary {
    return [NSMutableDictionary dictionaryWithDictionary:_resources];
}

- (void)setResource:(id)res forName:(NSString *)name {
    if(![_resources isKindOfClass:NSMutableDictionary.class]) {
        _resources = [NSMutableDictionary dictionaryWithDictionary:_resources];
    }
    if(res!=nil) {
        [(NSMutableDictionary*)_resources setObject:res forKey:name];
    } else {
        [(NSMutableDictionary*)_resources removeObjectForKey:name];
    }
}

- (void)complementResource:(id)res forName:(NSString *)name {
    if(_resources[name]==nil && res!=nil) {
        [self setResource:res forName:name];
    }
}

- (void)mergeWithDictionary:(NSDictionary*) src overwrite:(bool)overwrite {
    if(nil==src) return;
    for(id key in src.keyEnumerator) {
        if(overwrite||_resources[key]==nil) {
            [self setResource:src[key] forName:key];
        }
    }
}

- (void)mergeResource:(MICUiStatefulResource*) src overwrite:(bool)overwrite {
    if(nil==src) return;
    [self mergeWithDictionary:src->_resources overwrite:overwrite];
}


- (void)mergeWith:(id<MICUiStatefulResourceProtocol>) src
             type:(MICUiResType)type
            state:(MICUiViewState)state
        overwrite:(bool)overwrite {
    if(nil==src) return;
    let name = [self.class getStateName:type forState:state];
    if(overwrite || _resources[name]==nil) {
        [self setResource:[src resourceOf:type forState:state] forName:name];
    }
}


- (id)getResourceForName:(NSString *)name {
    return [_resources objectForKey:name];
}

- (id)resourceOf:(MICUiResType)type forState:(MICUiViewState)state {
    return [self getResourceForName:[MICUiStatefulResource getStateName:type forState:state]];
}

- (id)resourceOf:(MICUiResType)type forState:(MICUiViewState)state fallbackState:(MICUiViewState)fallback{
    id r = [self resourceOf:type forState:state];
    if( nil==r && state != fallback) {
        r = [self resourceOf:type forState:fallback];
    }
    if(nil==r && state != MICUiViewStateNORMAL && fallback != MICUiViewStateNORMAL) {
        return [self resourceOf:type forState:MICUiViewStateNORMAL];
    }
    return r;
}

+ (NSString*)getStateName:(MICUiResType)type forState:(MICUiViewState)state {
    switch(type) {
        case MICUiResTypeBGCOLOR:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulBgColorACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulBgColorDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulBgColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulBgColorNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulBgColorDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulBgColorACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeFGCOLOR:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulFgColorACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulFgColorDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulFgColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulFgColorNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulFgColorDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulFgColorACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeBORDERCOLOR:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulBorderColorACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulBorderColorDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulBorderColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulBorderColorNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulBorderColorDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulBorderColorACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeBGIMAGE:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulBgImageACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulBgImageDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulBgImageSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulBgImageNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulBgImageDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulBgImageACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeICON:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulIconACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulIconDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulIconSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulIconNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulIconDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulIconACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_PATH:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulSvgPathACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulSvgPathDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulSvgPathSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgPathNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulSvgPathDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulSvgPathACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_COLOR:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulSvgColorACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulSvgColorDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulSvgColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgColorNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulSvgColorDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulSvgColorACTIVATED_SELECTED;
                default:
                    break;
            }
        case MICUiResTypeSVG_BGPATH:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulSvgBgPathACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulSvgBgPathDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulSvgBgPathSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgBgPathNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulSvgBgPathDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulSvgBgPathACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_BGCOLOR:
            switch(state){
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulSvgBgColorACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulSvgBgColorDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulSvgBgColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgBgColorNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulSvgBgColorDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulSvgBgColorACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_STROKE_COLOR:
            switch(state) {
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulSvgStrokeColorACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulSvgStrokeColorDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulSvgStrokeColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgStrokeColorNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulSvgStrokeColorDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulSvgStrokeColorACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_STROKE_BGCOLOR:
            switch(state) {
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulSvgStrokeBgColorACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulSvgStrokeBgColorDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulSvgStrokeBgColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgStrokeBgColorNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulSvgStrokeBgColorDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulSvgStrokeBgColorACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_STROKE_WIDTH:
            switch(state) {
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulSvgStrokeWidthACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulSvgStrokeWidthDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulSvgStrokeWidthSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgStrokeWidthNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulSvgStrokeWidthDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulSvgStrokeWidthACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_STROKE_BG_WIDTH:
            switch(state) {
                case MICUiViewStateACTIVATED_:
                    return MICUiStatefulSvgStrokeBgWidthACTIVATED;
                case MICUiViewStateDISABLED_:
                    return MICUiStatefulSvgStrokeBgWidthDISABLED;
                case MICUiViewStateSELECTED_:
                    return MICUiStatefulSvgStrokeBgWidthSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgStrokeBgWidthNORMAL;
                case MICUiViewStateDISABLED_SELECTED:
                    return MICUiStatefulSvgStrokeBgWidthDISABLED_SELECTED;
                case MICUiViewStateACTIVATED_SELECTED:
                    return MICUiStatefulSvgStrokeBgWidthACTIVATED_SELECTED;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return nil;
}

@end
