//
//  MICTree.h
//  ツリー型コンテナクラス
//
//  Created by 豊田 光樹 on 2014/11/05.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * ツリーノードクラス
 */
@interface MICTreeNode  : NSObject

@property (nonatomic) id value;
@property (nonatomic,readonly,weak) MICTreeNode* parent;
@property (nonatomic,readonly) NSArray* children;
@property (nonatomic,readonly) NSInteger count;
@property (nonatomic,readonly) MICTreeNode* root;
@property (nonatomic,readonly) NSInteger depth;

- (MICTreeNode*) init;
- (MICTreeNode*) initWithValue:(id)value;
- (MICTreeNode*) initWithValue:(id)value andCapacity:(NSUInteger)capa;

- (void) addChild:(MICTreeNode*)node;
- (void) insertChild:(MICTreeNode*)node beforeSibling:(MICTreeNode*)sibling;
- (void) insertChild:(MICTreeNode*)node afterSibling:(MICTreeNode*)sibling;
- (void) insertChild:(MICTreeNode*)node atIndex:(NSInteger)index;

//- (MICTreeNode*) addChildValue:(id)value;
//- (MICTreeNode*) insertChildValue:(id)value beforeSibling:(MICTreeNode*)sibling;
//- (MICTreeNode*) insertChildValue:(id)value afterSibling:(MICTreeNode*)sibling;
//- (MICTreeNode*) insertChildValue:(id)value atIndex:(int)index;

- (void) removeChild:(MICTreeNode*)node;
- (void) clearAllChild;

- (NSInteger) indexOfChild:(MICTreeNode*) node;
- (MICTreeNode*) childAt:(NSInteger)index;
- (MICTreeNode*) forEach:(bool (^)(MICTreeNode*)) visit;
- (MICTreeNode*) forEach_postorder:(bool (^)(MICTreeNode*)) visit;

- (bool) isAncestorOf:(MICTreeNode*) node;
- (bool) isDescendantOf:(MICTreeNode*) node;


@end

/**
 * ツリー型コレクションクラス
 */
@interface MICTree : NSObject

@property (nonatomic) MICTreeNode* root;
@property (nonatomic,readonly) NSInteger countOfNodes;

- (MICTree*) init;
- (MICTree*) initWithRoot:(MICTreeNode*)root;
- (MICTreeNode*) forEach:(bool (^)(MICTreeNode*)) visit;
- (MICTreeNode*) forEachPostorder:(bool (^)(MICTreeNode*)) visit;
- (void) clear;
- (void) setRoot:(MICTreeNode *)root;


@end
