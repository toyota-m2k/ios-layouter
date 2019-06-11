//
//  MICPathRepository.m
//  Anytime
//
//  Created by @toyota-m2k on 2019/03/12.
//  Copyright  2019年 @toyota-m2k Corporation. All rights reserved.
//

#import "MICPathRepository.h"
#import "MICSvgPath.h"
#import "MICVar.h"

@interface MICPathRec : NSObject
@property (nonatomic, readonly) MICSvgPath* path;
@end

@implementation MICPathRec {
    NSInteger _refCount;
}

- (instancetype) initWithPath:(MICSvgPath*) path {
    self = [super init];
    if(nil!=self) {
        _refCount = 1;
        _path = path;
    }
    return self;
}

- (bool) releaseRef {
    _refCount--;
    if(_refCount==0) {
        _path = nil;
    }
    return _refCount>0;
}

- (void) addRef {
    _refCount++;
}

@end

@implementation MICPathRepository {
    NSMutableDictionary* _dic;
}

+ (instancetype) instance {
    static MICPathRepository* sInstance = nil;
    if(nil==sInstance) {
        sInstance = [[MICPathRepository alloc] init];
    }
    return sInstance;
}

- (instancetype) init {
    self = [super init];
    if(nil!=self) {
        _dic = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
    return self;
}

- (MICSvgPath*) getPath:(NSString*)pathString viewboxSize:(CGSize)size {
    @synchronized (self) {
        MICPathRec* rec = [_dic objectForKey:pathString];
        if(rec!=nil) {
            [rec addRef];
            return rec.path;
        }
        rec = [[MICPathRec alloc ] initWithPath:[MICSvgPath pathWithViewboxSize:size pathString:pathString]];
        [_dic setObject:rec forKey:pathString];
        return rec.path;
    }
}

- (void) releasePath:(MICSvgPath*)path {
    if(nil==path) {
        return;
    }
    @synchronized (self) {
        MICPathRec* rec = [_dic objectForKey:path.pathString];
        if(nil!=rec) {
            if(![rec releaseRef]) {
                [_dic removeObjectForKey:path.pathString];
            }
        }
    }
}


@end
