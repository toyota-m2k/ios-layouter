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
    }
    return r;
}

+ (NSString*)getStateName:(MICUiResType)type forState:(MICUiViewState)state {
    switch(type) {
        case MICUiResTypeBGCOLOR:
            switch(state){
                case MICUiViewStateACTIVATED:
                    return MICUiStatefulBgColorACTIVATED;
                case MICUiViewStateDISABLED:
                    return MICUiStatefulBgColorDISABLED;
                case MICUiViewStateSELECTED:
                    return MICUiStatefulBgColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulBgColorNORMAL;
                default:
                    break;
            }
            break;
        case MICUiResTypeFGCOLOR:
            switch(state){
                case MICUiViewStateACTIVATED:
                    return MICUiStatefulFgColorACTIVATED;
                case MICUiViewStateDISABLED:
                    return MICUiStatefulFgColorDISABLED;
                case MICUiViewStateSELECTED:
                    return MICUiStatefulFgColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulFgColorNORMAL;
                default:
                    break;
            }
            break;
        case MICUiResTypeBORDERCOLOR:
            switch(state){
                case MICUiViewStateACTIVATED:
                    return MICUiStatefulBorderColorACTIVATED;
                case MICUiViewStateDISABLED:
                    return MICUiStatefulBorderColorDISABLED;
                case MICUiViewStateSELECTED:
                    return MICUiStatefulBorderColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulBorderColorNORMAL;
                default:
                    break;
            }
            break;
        case MICUiResTypeBGIMAGE:
            switch(state){
                case MICUiViewStateACTIVATED:
                    return MICUiStatefulBgImageACTIVATED;
                case MICUiViewStateDISABLED:
                    return MICUiStatefulBgImageDISABLED;
                case MICUiViewStateSELECTED:
                    return MICUiStatefulBgImageSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulBgImageNORMAL;
                default:
                    break;
            }
            break;
        case MICUiResTypeICON:
            switch(state){
                case MICUiViewStateACTIVATED:
                    return MICUiStatefulIconACTIVATED;
                case MICUiViewStateDISABLED:
                    return MICUiStatefulIconDISABLED;
                case MICUiViewStateSELECTED:
                    return MICUiStatefulIconSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulIconNORMAL;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_PATH:
            switch(state){
                case MICUiViewStateACTIVATED:
                    return MICUiStatefulSvgPathACTIVATED;
                case MICUiViewStateDISABLED:
                    return MICUiStatefulSvgPathDISABLED;
                case MICUiViewStateSELECTED:
                    return MICUiStatefulSvgPathSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgPathNORMAL;
                default:
                    break;
            }
            break;
        case MICUiResTypeSVG_COLOR:
            switch(state){
                case MICUiViewStateACTIVATED:
                    return MICUiStatefulSvgColorACTIVATED;
                case MICUiViewStateDISABLED:
                    return MICUiStatefulSvgColorDISABLED;
                case MICUiViewStateSELECTED:
                    return MICUiStatefulSvgColorSELECTED;
                case MICUiViewStateNORMAL:
                    return MICUiStatefulSvgColorNORMAL;
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
