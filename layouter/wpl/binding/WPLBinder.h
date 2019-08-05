//
//  WPLBinder.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/04.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPLBindingDef.h"


@interface WPLBinder : NSObject

@property (nonatomic) bool autoDisposeBindings;
@property (nonatomic) bool autoDisposeProperties;

- (id<IWPLObservableData>) property:(id)key;
- (id) createPropertyWithValue:(id)initialValue withKey:(id) key;
- (id) createDependentPropertyWithKey:(id)key sourceProc:(WPLSourceDelegateProc)proc dependsOn:(id)relations, ... NS_REQUIRES_NIL_TERMINATION;

- (id) addProperty:(id<IWPLObservableData>) prop forKey:(id) key;

- (void) removeProperty:(id)key;

- (void) addBinding:(id<IWPLBinding>) binding;

- (id<IWPLBinding>) bindProperty:(id)propKey
                 withValueOfCell:(id<IWPLCell>)cell
                     bindingMode:(WPLBindingMode)mode
                     customActin:(WPLBindingCustomAction)customAction;

- (id<IWPLBinding>) bindProperty:(id)propKey
             withBoolStateOfCell:(id<IWPLCell>)cell
                      actionType:(WPLBoolStateActionType) actionType
                        negation:(bool) negation
                     customActin:(WPLBindingCustomAction)customAction;

- (void) unbind:(id<IWPLBinding>) bindKey;

- (void) dispose;

@end

#if defined(__cplusplus)

#if 0
class CWPLObservableDataBuilder {
private:
    id<IWPLObservableData> _od;

public:
    CWPLObservableDataBuilder(id initialValue=nil) {
        _od = [WPLObservableMutableData new];
        if(nil!=initialValue) {
            ((WPLObservableMutableData*)_od).value = initialValue;
        }
    }
    
    CWPLObservableDataBuilder(WPLSourceDelegateProc proc) {
        _od = [WPLDelegatedObservableData newDataWithSourceBlock:proc];
    }
    
    CWPLObservableDataBuilder(id target, SEL sel) {
        _od = [WPLDelegatedObservableData newDataWithSourceTarget:target selector:sel];
    }

    CWPLObservableDataBuilder(const CWPLObservableDataBuilder& src) {
        _od = src._od;
    }
    virtual ~CWPLObservableDataBuilder() {
        _od = nil;
    }
    
    CWPLObservableDataBuilder& addValueChangeListener( id target, SEL selector ) {
        [_od addValueChangedListener:target selector:selector];
        return *this;
    }
    
    CWPLObservableDataBuilder& addRelation(id<IWPLObservableData> rel) {
        [_od addRelation:rel];
        return *this;
    }
    
    id<IWPLObservableData> create() {
        id r = _id;
        _id = nil;
        return r;
    }
    
    void abort() {
        if(nil!=_od) {
            [_od dispose];
            _od = nil;
        }
    }
};

#endif			

#endif

