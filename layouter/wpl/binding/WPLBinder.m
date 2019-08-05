//
//  WPLBinder.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/04.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLBinder.h"
#import "WPLValueBinding.h"
#import "WPLBoolStateBinding.h"
#import "WPLObservableMutableData.h"
#import "WPLDelegatedObservableData.h"
#import "MICVar.h"

@implementation WPLBinder {
    NSMutableDictionary<id,id<IWPLObservableData>> * _properties;
    NSMutableArray<id<IWPLBinding>>* _bindings;
}

- (instancetype) init {
    self = [super init];
    if(self!=nil) {
        _properties = [NSMutableDictionary dictionary];
        _bindings = [NSMutableArray array];
        _autoDisposeProperties = true;
        _autoDisposeBindings = true;
    }
    return self;
}

- (id<IWPLObservableData>) property:(id)key {
    return _properties[key];
}

- (id) createPropertyWithValue:(id)initialValue withKey:(id) key {
    let ov = [[WPLObservableMutableData alloc] init];
    ov.value = initialValue;
    return [self addProperty:ov forKey:key];
}

- (id) addProperty:(id<IWPLObservableData>) prop forKey:(id) key {
    if(key==nil) {
        key = prop;
    }
    [_properties setObject:prop forKey:key];
    return key;
}

- (void) removeProperty:(id)key {
    if(self.autoDisposeProperties) {
        let prop = [self property:key];
        if(nil!=prop){
            [prop dispose];
        }
    }
    [_properties removeObjectForKey:key];
}

- (void) addBinding:(id<IWPLBinding>) binding {
    [_bindings addObject:binding];
}

- (id<IWPLBinding>) bindProperty:(id)propKey
                 withValueOfCell:(id<IWPLCell>)cell
                     bindingMode:(WPLBindingMode)mode
                     customActin:(WPLBindingCustomAction)customAction {
    let binding = [[WPLValueBinding alloc] initWithCell:cell source:[self property:propKey] bindingMode:mode customAction:customAction];
    [self addBinding:binding];
    return binding;
}

- (id<IWPLBinding>) bindProperty:(id)propKey
             withBoolStateOfCell:(id<IWPLCell>)cell
                      actionType:(WPLBoolStateActionType) actionType
                        negation:(bool) negation
                     customActin:(WPLBindingCustomAction)customAction {
    let binding = [[WPLBoolStateBinding alloc] initWithCell:cell source:[self property:propKey] customAction:customAction actionType:actionType negation:negation];
    [self addBinding:binding];
    return binding;
}

- (void) unbind:(id<IWPLBinding>) bindKey {
    NSInteger i = [_bindings indexOfObject:bindKey];
    if(i != NSNotFound) {
        if(self.autoDisposeBindings) {
            [bindKey dispose];
        }
        [_bindings removeObjectAtIndex:i];
    }
}

- (void)dispose {
    if(nil!=_properties) {
        if(self.autoDisposeProperties) {
            for(id key in _properties.allKeys) {
                let prop = [self property:key];
                if(nil!=prop) {
                    [prop dispose];
                }
            }
        }
        [_properties removeAllObjects];
        _properties = nil;
    }
    if(nil!=_bindings) {
        if(self.autoDisposeBindings) {
            for(id<IWPLBinding> b in _bindings) {
                [b dispose];
            }
        }
        [_bindings removeAllObjects];
        _bindings = nil;
    }
}

@end
