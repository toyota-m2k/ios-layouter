//
//  MICArray.h
//
//  Created by @toyota-m2k on 2014/11/04.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
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