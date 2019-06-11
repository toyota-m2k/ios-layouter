//
//  MICUiVirtualView.h
//  DTable
//
//  Created by @toyota-m2k on 2014/11/26.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#if 0

#import <UIKit/UIKit.h>

@class MICUiVirtualView;

@protocol MICUiVirtualViewDelegate <NSObject>
- (UIView*) realViewForVirtualView:(MICUiVirtualView*)vv reuse:(UIView*)reuseView;
@end

@interface MICUiVirtualView : NSObject

@property (nonatomic) CGRect frame;
@property (nonatomic,readonly) UIView* view;
@property (nonatomic,weak,readonly) id<MICUiVirtualViewDelegate> delegate;
@property (nonatomic) id clientData;
@property (nonatomic,readonly) bool isVirtual;
@property (nonatomic) bool lockCache;

- (UIView*) detachCache;
- (UIView*) prepareCache:(UIView*)reuseView;

- (MICUiVirtualView*) initWithRealView:(UIView*)view clientData:(id)anyData;
- (MICUiVirtualView*) initWithDelegate:(id<MICUiVirtualViewDelegate>)delegate inRect:(CGRect)frame clientData:(id)anyData;

@end

@interface MICUiVirtualViewCachePool : NSObject

@property (nonatomic) int maxCacheCount;

- (void) fetchView:(MICUiVirtualView*)vv;
- (void) releaseView:(MICUiVirtualView*)vv;
- (void) clearPool:(int)maxCount;
- (void) clearAllPool;

@end

#endif