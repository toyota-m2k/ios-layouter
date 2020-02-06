//
//  MICSortedArray.mm
//  AnotherWorld
//
//  Created by @toyota-m2k on 2019/04/23.
//  Copyright  2019 @toyota-m2k. All rights reserved.
//

#import "MICSortedArray.h"
#import "MICVar.h"

@implementation MICSortedArray {
    NSMutableArray* _array;
    NSComparisonResult(^_comparator)(id o1, id o2);
    NSInteger _ascending;
}

- (NSArray *)array {
    return _array;
}

- (instancetype) initWithComparator:(NSComparisonResult(^)(id o1, id o2)) comparator ascending:(bool) ascending allowDuplication:(bool) allowDuplication capacity:(NSInteger)capacity {
    self = [super init];
    if(nil!=self) {
        _array = [NSMutableArray arrayWithCapacity:capacity];
        _comparator = comparator;
        _ascending = ascending ? 1 : -1;
        _allowDuplication = allowDuplication;
    }
    return self;
}

- (instancetype)initWithComparator:(NSComparisonResult (^)(id, id))comparator ascending:(bool)ascending {
    return [self initWithComparator:comparator ascending:ascending allowDuplication:false capacity:16];
}

- (void)sortWithComparator:(NSComparisonResult (^)(id, id))comparator ascending:(bool)ascending {
    _comparator = comparator;
    _ascending = ascending;

    let cmp = _comparator;
    let asc = _ascending;
    let ary = [_array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return (NSComparisonResult)(cmp(obj1, obj2) * asc);
    }];
    _array = [NSMutableArray arrayWithArray:ary];
}

- (NSInteger)addElement:(id)element {
    CMICSortedArrayPosition pos;
    if([self findElement:element result:&pos]>=0) {
        if(!_allowDuplication) {
            return false;
        }
        // 重複する場合は、ヒットしたエレメントの位置（＝ヒットしたエレメントの前）に挿入する
        pos.next = pos.hit;
    }
    if(pos.next<0) {
        [_array addObject:element];
        return _array.count-1;
    } else {
        [_array insertObject:element atIndex:pos.next];
        return pos.next;
    }
}

- (NSInteger)compare:(id)o1 to:(id)o2 {
    return _comparator(o1, o2)*_ascending;
}

- (NSInteger)findElement:(id)element result:(MICSortedArrayPosition *)r {
    CMICSortedArrayPosition result;
    if(r!=NULL) {
        *r = result;
    } else {
        r = &result;
    }
    
    NSInteger count = _array.count;
    NSInteger s = 0;
    NSInteger e = count-1;
    NSInteger m = 0;
    if(e<0) {
        // 要素が空
        return -1;
    }
    NSInteger cmp = [self compare:_array[e] to:element];
    if(cmp<0) {
        // 最後の要素より後ろ
        r->prev = e;
        return -1;
    }
    
    while(s<=e){
        m = (s+e)/2;
        id v = _array[m];
        cmp = [self compare:v to:element];
        if(cmp==0) {
            r->hit = m;
            r->prev = m-1;
            if(m<count-1) {
                r->next = m+1;
            }
            return m;   // 一致する要素が見つかった
        } else if(cmp<0) {
            s = m+1;
        } else {
            e = m-1;
        }
    }
    r->next = s;
    r->prev = s-1;
    return -1;
}

- (MICSortedArrayPosition)findElement:(id)element {
    CMICSortedArrayPosition result;
    [self findElement:element result:&result];
    return result;
}

- (void) removeAll {
    [_array removeAllObjects];
}

- (void) removeAt:(NSInteger)index {
    [_array removeObjectAtIndex:index];
}

- (NSInteger) indexOf:(id)element {
    CMICSortedArrayPosition pos;
    NSInteger i = [self findElement:element result:&pos];
    return i>=0 ? i : NSNotFound;
}

@end
