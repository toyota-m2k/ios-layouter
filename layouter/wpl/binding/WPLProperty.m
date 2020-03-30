//
//  WPLProperty.m
//
//  Created by @toyota-m2k on 2020/03/25.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLProperty.h"
#import "WPLObservableMutableData.h"
#import "WPLDelegatedObservableData.h"
#import "WPLRxObservableData.h"
#import "WPLSubject.h"
#import "MICVar.h"

@implementation WPLProperty

- (instancetype) initAsName:(NSString*)name andData:(id<IWPLObservableData>)data {
    self = [super init];
    if(nil!=self) {
        _name = name;
        _data = data;
    }
    return self;
}

- (void) dispose {
    [self.data dispose];
}

+ (instancetype)delegatedDataAsName:(NSString *)name sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(WPLProperty*)relations, ... {
    va_list args;
    va_start(args, relations);
    id r = [self delegatedDataAsName:name sourceProc:sourceProc dependsOn:relations dependsOnArgument:args];
    va_end(args);
    return r;

}

+ (instancetype)delegatedDataAsName:(NSString *)name sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(WPLProperty*)firstRelation dependsOnArgument:(va_list)args {
    let ov = [WPLDelegatedObservableData newDataWithSourceBlock:sourceProc];
    WPLProperty* rel = firstRelation;
    while(rel!=nil) {
        [rel.data addRelation:ov];
        rel = va_arg(args, id);
    }
    return [[self alloc] initAsName:name andData:ov];
}

+ (instancetype)selectAsName:(NSString *)name src:(id<IWPLObservableData>)src func:(WPLRx1Proc)fn {
    let s = [WPLRxObservableData select:src func:fn];
    return [[self alloc] initAsName:name andData:s];
}

+ (instancetype)mapAsName:(NSString *)name src:(id<IWPLObservableData>)src func:(WPLRx1Proc)fn {
    let s = [WPLRxObservableData map:src func:fn];
    return [[self alloc] initAsName:name andData:s];
}

+ (instancetype)combineLatestAsName:(NSString *)name src:(id<IWPLObservableData>)src with:(id<IWPLObservableData>)src2 func:(WPLRx2Proc)fn {
    let s = [WPLRxObservableData combineLatest:src with:src2 func:fn];
    return [[self alloc] initAsName:name andData:s];
}

+ (instancetype)combineLatestAsName:(NSString *)name sources:(NSArray<id<IWPLObservableData>>*)sources func:(WPLRxNProc)fn {
    let s = [WPLRxObservableData combineLatest:sources func:fn];
    return [[self alloc] initAsName:name andData:s];
}

+ (instancetype)whereAsName:(NSString *)name src:(id<IWPLObservableData>)src func:(WPLRx1BoolProc)fn {
    let s = [WPLRxObservableData where:src func:fn];
    return [[self alloc] initAsName:name andData:s];
}

+ (instancetype)mergeAsName:(NSString *)name src:(id<IWPLObservableData>)src with:(id<IWPLObservableData>)src2 {
    let s = [WPLRxObservableData merge:src with:src2];
    return [[self alloc] initAsName:name andData:s];
}

+ (instancetype)scanAsName:(NSString *)name src:(id<IWPLObservableData>)src func:(WPLRx2Proc)fn {
    let s = [WPLRxObservableData scan:src func:fn];
    return [[self alloc] initAsName:name andData:s];
}
@end

@implementation WPLMutableProperty

- (id<IWPLObservableMutableData>)mutableData {
    if(self.data!=nil && [self.data conformsToProtocol:@protocol(IWPLObservableMutableData)]) {
        return (id<IWPLObservableMutableData>)self.data;
    } else {
        return nil;
    }
}

+ (instancetype)dataAsName:(NSString *)name initialValue:(id)initialValue {
    let ov = [WPLObservableMutableData new];
    ov.value = initialValue;
    return [[self alloc] initAsName:name andData:ov];
}

@end

@implementation WPLCommand

- (WPLSubject *)subject {
    if(self.data !=nil && [self.data isKindOfClass:WPLSubject.class]) {
        return (WPLSubject*)self.data;
    } else {
        return nil;
    }
}

+ (instancetype)commandAsName:(NSString *)name initialValue:(id)initialValue {
    let ov = [WPLSubject new];
    ov.value = initialValue;
    return [[self alloc] initAsName:name andData:ov];
}

- (id) subscribe:(id)target action:(SEL)action {
    return [self.subject addValueChangedListener:target selector:action];
}

- (void) unsubscribe:(id)key {
    return [self.subject removeValueChangedListener:key];
}

@end
