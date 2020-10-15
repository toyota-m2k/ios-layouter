//
//  WPLDef.h
//
//  Created by @toyota-m2k on 2020/03/30.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol IWPLDisposable <NSObject>
- (void) dispose;
@end

#define WPL_DISPOSE(d) if(d!=nil) { [d dispose]; d=nil; }


