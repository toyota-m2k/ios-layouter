//
//  WPLNamedValueHost.m
//
//  Created by @toyota-m2k on 2020/02/03.
//  Copyright @toyota-m2k. All rights reserved.
//

#import "WPLNamedValueHost.h"
#import "MICTargetSelector.h"
#import "MICVar.h"

@interface WPLNamedValueEntity : NSObject
@property (nonatomic) id value;
@property (nonatomic,readonly) NSArray<MICTargetSelector*>* listeners;
@end

@implementation WPLNamedValueEntity {
    NSMutableArray<MICTargetSelector*>* _listeners;
}

- (instancetype)initWithValue:(id)value {
    self = [super init];
    if(nil!=self) {
        _value = value;
        _listeners = NSMutableArray.array;
    }
    return self;
}

- (id) addListener:(id)target action:(SEL)selector {
    let ts = [[MICTargetSelector alloc] initWithTarget:target selector:selector];
    [_listeners addObject:ts];
    return ts;
}

- (void) removeListener:(id)key {
    [_listeners removeObject:key];
}

- (void) clearListeners {
    [_listeners removeAllObjects];
}

@end

@implementation WPLNamedValueHost {
    NSMutableDictionary<NSString*,WPLNamedValueEntity*>* _dic;
    __weak id<IWPLCell> _ownerCell;
}

- (instancetype) initWithOwner:(id<IWPLCell>) ownerCell {
    self = [super init];
    if(self!=nil) {
        _dic = NSMutableDictionary.dictionary;
        _ownerCell = ownerCell;
    }
    return self;
}

- (void) setupName:(NSString*) name value:(id)initialValue {
    [_dic setObject:[[WPLNamedValueEntity alloc] initWithValue:initialValue] forKey:name];
}

- (void) setup:(NSDictionary<NSString*,id>*) table {
    for(NSString* name in table.allKeys) {
        [_dic setObject:[[WPLNamedValueEntity alloc] initWithValue:table[name]] forKey:name];
    }
}

- (id)valueForName:(NSString *)name {
    let e = _dic[name];
    if(e==nil) {
        @throw [NSException exceptionWithName:NSUndefinedKeyException
                                       reason:[NSString stringWithFormat:@"WPLNamedValueHost.valueForName: unknown name (%@)",name]
                                     userInfo:nil];
    }
    return e.value;
}

- (void)setValue:(id)value forName:(NSString *)name {
    let e = _dic[name];
    if(e==nil) {
        @throw [NSException exceptionWithName:NSUndefinedKeyException
                                       reason:[NSString stringWithFormat:@"WPLNamedValueHost.setValue: unknown name (%@)",name]
                                     userInfo:nil];
    }
    if(![e.value isEqual:value]) {
        e.value = value;
        for(MICTargetSelector* ts in e.listeners) {
            id c = _ownerCell;
            id n = name;
            [ts beginCall];
            [ts addArgument:&c];
            [ts addArgument:&n];
            [ts endCall];
        }
    }
}


- (id)addNamed:(NSString *)name valueListener:(id)target selector:(SEL)selector {
    let e = _dic[name];
    if(e==nil) {
        @throw [NSException exceptionWithName:NSUndefinedKeyException
                                       reason:[NSString stringWithFormat:@"WPLNamedValueHost.addNamedValueListener: unknown name (%@)",name]
                                     userInfo:nil];
    }
    return [e addListener:target action:selector];
}

- (void)removeNamed:(NSString *)name valueListener:(id)key {
    let e = _dic[name];
    if(e==nil) {
        @throw [NSException exceptionWithName:NSUndefinedKeyException
                                       reason:[NSString stringWithFormat:@"WPLNamedValueHost.removeNamedValueListener: unknown name (%@)",name]
                                     userInfo:nil];
    }
    if(key!=nil) {
        [e removeListener:key];
    } else {
        [e clearListeners];
    }
}

- (void) dispose {
    [_dic removeAllObjects];
}

@end
