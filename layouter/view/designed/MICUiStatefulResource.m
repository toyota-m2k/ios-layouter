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
    self = [super init];
    if(nil!=self){
        _resources = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)definition {
    self = [super init];
    if(nil!=self){
        _resources = definition;
    }
    return self;
}

- (void)setResource:(id)res forName:(NSString *)name {
    if(![_resources isKindOfClass:NSMutableDictionary.class]) {
        _resources = [NSMutableDictionary dictionaryWithDictionary:_resources];
    }
    [(NSMutableDictionary*)_resources setObject:res forKey:name];
}

- (void)complementResource:(id)res forName:(NSString *)name {
    if(_resources[name]==nil) {
        [self setResource:res forName:name];
    }
}

- (void)mergeWithDictionary:(NSDictionary*) src overwrite:(bool)overwrite {
    for(id key in src.keyEnumerator) {
        if(overwrite||_resources[key]==nil) {
            [self setResource:src[key] forName:key];
        }
    }
}

- (void)mergeResource:(MICUiStatefulResource*) src overwrite:(bool)overwrite {
    [self mergeWithDictionary:src->_resources overwrite:overwrite];
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
        if(nil==r && state != MICUiViewStateNORMAL && fallback != MICUiViewStateNORMAL) {
            return [self resourceOf:type forState:MICUiViewStateNORMAL];
        }
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


@implementation MICUiMonoResource

- (instancetype)init {
    return [self initWithResource:nil];
}

- (instancetype)initWithResource:(id)res {
    self = [super init];
    if( nil!=self) {
        _resource = res;
    }
    return self;
}

- (id)resourceOf:(MICUiResType)type forState:(MICUiViewState)state {
    return _resource;
}

- (id)resourceOf:(MICUiResType)type forState:(MICUiViewState)state fallbackState:(MICUiViewState)fallback{
    return _resource;
}

@end

@implementation MICUiUnstatefulResource {
    id _resources[__MICUIRESTYPECOUNT];
}

- (instancetype)init {
    return [self initWithBackground:nil foreground:nil border:nil bgimage:nil icon:nil];
}

- (instancetype) initWithBackground:(id)bg foreground:(id)fg border:(id)border bgimage:(id)bgimage icon:(id)icon {
    self = [super init];
    if(nil!=self){
        _resources[MICUiResTypeBGCOLOR] = bg;
        _resources[MICUiResTypeFGCOLOR] = fg;
        _resources[MICUiResTypeBORDERCOLOR] = border;
        _resources[MICUiResTypeBGIMAGE] = bgimage;
        _resources[MICUiResTypeICON] = icon;
    }
    return self;
}

- (id)resourceOf:(MICUiResType)type forState:(MICUiViewState)state {
    return (type<__MICUIRESTYPECOUNT) ? _resources[type] : nil;
}

- (id)resourceOf:(MICUiResType)type forState:(MICUiViewState)state fallbackState:(MICUiViewState)fallback{
    id r = [self resourceOf:type forState:state];
    if( nil==r && state != fallback) {
        r = [self resourceOf:type forState:fallback];
    }
    return r;
}


@end
