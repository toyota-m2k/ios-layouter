//
//  MICTree.m
//  ツリー型コンテナクラス
//
//  Created by @toyota-m2k on 2014/11/05.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICTree.h"

@implementation MICTreeNode {
    NSMutableArray* _children;
}

- (NSInteger) count {
    return _children.count;
}

- (void) setParent:(MICTreeNode *)parent {
    _parent = parent;
}

- (MICTreeNode*) root {
    MICTreeNode* p = _parent;
    while( nil!=p.parent) {
        p = p.parent;
    }
    return p;
}

- (MICTreeNode*) init {
    return [self initWithValue:nil];
}

- (MICTreeNode*) initWithValue:(id)value {
    self = [super init];
    if(nil!=self) {
        _children = [[NSMutableArray alloc] init];
        _parent = nil;
        _value = value;
    }
    return self;
}

- (MICTreeNode*) initWithValue:(id)value andCapacity:(NSUInteger)capa {
    self = [super init];
    if(nil!=self) {
        _children = [[NSMutableArray alloc] initWithCapacity:capa];
        _parent = nil;
        _value = value;
    }
    return self;
}

- (void) addChild:(MICTreeNode*)node {
    [_children addObject:node];
    node.parent = self;
}

- (void) insertChild:(MICTreeNode*)node beforeSibling:(MICTreeNode*)sibling {
    [self insertChild:node atIndex:[self indexOfChild:sibling]];
}
- (void) insertChild:(MICTreeNode*)node afterSibling:(MICTreeNode*)sibling {
    [self insertChild:node atIndex:[self indexOfChild:sibling]+1];
}
- (void) insertChild:(MICTreeNode*)node atIndex:(NSInteger)index {
    if(index<0||index>=_children.count) {
        [_children addObject:node];
    } else {
        [_children insertObject:node atIndex:index];
    }
    node.parent = self;
}

//- (MICTreeNode*) addChildValue:(id)value {
//    MICTreeNode* node = [[MICTreeNode alloc] initWithValue:value];
//    [self addChild:node];
//    return node;
//}
//
//- (MICTreeNode*) insertChildValue:(id)value beforeSibling:(MICTreeNode*)sibling {
//    MICTreeNode* node = [[MICTreeNode alloc] initWithValue:value];
//    [self insertChild:node beforeSibling:sibling];
//    return node;
//}
//- (MICTreeNode*) insertChildValue:(id)value afterSibling:(MICTreeNode*)sibling {
//    MICTreeNode* node = [[MICTreeNode alloc] initWithValue:value];
//    [self insertChild:node afterSibling:sibling];
//    return node;
//}
//- (MICTreeNode*) insertChildValue:(id)value atIndex:(int)index {
//    MICTreeNode* node = [[MICTreeNode alloc] initWithValue:value];
//    [self insertChild:node atIndex:index];
//    return node;
//}


- (void) removeChild:(MICTreeNode*)node {
    [_children removeObject:node];
    node.parent = nil;
}

- (void) clearAllChild {
    // 子ノードを再帰的に削除
    for(MICTreeNode* node in _children) {
        [node clearAllChild];
        node.parent = nil;
    }
    [_children removeAllObjects];
}

/**
 *
 */
- (NSInteger) indexOfChild:(MICTreeNode*)node {
    NSUInteger idx = [_children indexOfObject:node];
    return (idx == NSNotFound) ? -1 : idx;
}


- (MICTreeNode*) childAt:(NSInteger)index {
    return _children[index];
}

- (MICTreeNode*) forEach:(bool (^)(MICTreeNode*)) visit {
    // 行きがけ順になぞる
    if(visit(self)) {
        return self;
    }
    for(MICTreeNode* node in _children ) {
        MICTreeNode* r = [node forEach:visit];
        if(nil!=r) {
            return r;
        }
    }
    return nil;
}

- (MICTreeNode*) forEach_postorder:(bool (^)(MICTreeNode*)) visit {
    // 帰りがけ順になぞる
    for(MICTreeNode* node in _children ) {
        MICTreeNode* r = [node forEach_postorder:visit];
        if(nil!=r) {
            return r;
        }
    }
    if(visit(self)) {
        return self;
    }
    return nil;
}


- (bool) isAncestorOf:(MICTreeNode*) node {
    for(MICTreeNode* p=node.parent ; p!=nil ; p=p.parent) {
        if(self == p) {
            return true;
        }
    }
    return false;
}

- (bool) isDescendantOf:(MICTreeNode*) node {
    return [node isAncestorOf:self];
}

- (NSInteger) depth {
    NSInteger d = 0;
    for(MICTreeNode* p = self.parent ; nil!=p ; p=p.parent) {
        d++;
    }
    return d;
}

@end

@implementation MICTree

- (MICTree*) init {
    return [self initWithRoot:nil];
}

- (MICTree*) initWithRoot:(MICTreeNode*)root {
    self = [super init];
    if( nil!=self) {
        _root = root;
    }
    return self;
}

- (void) setRoot:(MICTreeNode *)root {
    _root = root;
}

//- (MICTree*) initWithRootValue:(id)value {
//    self = [super init];
//    if( nil!=self) {
//        _root = [[MICTreeNode alloc] initWithValue:value];
//    }
//    return self;
//}

- (MICTreeNode*) forEach:(bool (^)(MICTreeNode*)) visit {
    return [_root forEach:visit];
}

- (MICTreeNode*) forEachPostorder:(bool (^)(MICTreeNode*)) visit {
    return [_root forEach_postorder:visit];
}

- (void) clear {
    [_root clearAllChild];
}

- (NSInteger) countOfNodes {
    __block NSInteger count = 0;
    [self forEach:^bool (MICTreeNode* node){
        count++;
        return true;
    }];
    return count;
}

@end
