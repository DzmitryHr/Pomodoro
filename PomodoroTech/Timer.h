//
//  Timer.h
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject

@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger timeToFinish;
@property (nonatomic, assign, getter=isWorkTimer, readonly) BOOL workTimer;


+ (void)startTimerWithDuration:(NSInteger)durarion;
+ (void)stopTimer;

@end
