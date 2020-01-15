//
//  MICListeners.h
//  loginMock
//
//  Created by Mitsuki Toyota on 2019/12/17.
//  Copyright © 2019 MichaelSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MICTargetSelector.h"

@interface MICListeners : NSObject

+ (instancetype) listeners;

- (id) addListener:(id)target action:(SEL)action;
- (id) addListener:(MICTargetSelector*)listener;
- (void) removeListener:(id)key;
- (void) removeAll;
- (void) fire:(id)param;
- (void) forEach:(void (^)(MICTargetSelector*))cb;


@end

