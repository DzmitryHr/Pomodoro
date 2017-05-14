//
//  TimerConroller.h
//  PomodoroTech
//
//  Created by Kronan on 5/13/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TimerController;

@protocol TimerControllerDelegate<NSObject>
-(void)timerControllerDidStarted:(TimerController *)timerController;
-(void)timerControllerDidStop:(TimerController *)timerController;
-(void)timerController:(TimerController *)timerController timeDidChanged:(NSTimeInterval)time;
@end


@interface TimerController : NSObject

@property (nonatomic, weak) id <TimerControllerDelegate> delegate;

+ (instancetype)sharedInstance;

-(void) startTimer;
-(void) stopTimer;
-(void) installTimerDuration:(NSTimeInterval)duration;


@end
