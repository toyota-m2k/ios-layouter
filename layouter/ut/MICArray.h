//
//  MICArray.h
//
//  Created by 豊田 光樹 on 2014/11/04.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MICRectArray : NSObject {
}

- (MICRectArray*) init;
- (MICRectArray*) initWithCapacity:(int)capacity;
- (MICRectArray*) initWithArray:(MICRectArray*)src;

- (void) add:(CGRect)rc;
- (void) insert:(CGRect)rc at:(int)idx;
- (void) removeAt:(int) idx;
- (CGRect) getAt:(int)idx;

@end