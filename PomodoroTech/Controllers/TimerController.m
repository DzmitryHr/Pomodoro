//
//  TimerConroller.m
//  PomodoroTech
//
//  Created by Kronan on 5/13/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TimerController.h"
typedef NS_ENUM(NSInteger, TimerControllerState)
{
    TimerControllerStateDefault = 0,
    
    TimerControllerStatePendingStartTimer,
    TimerControllerStateTimerStarted,
    TimerControllerStatePendingStopTimer,
    
    //TimerControllerStateSetDurationTimerPomodor = 1,
    
//    TimerControllerStateStartTimerPomodor = 1,
//    TimerControllerStateStartTimerShortBreak = 3,
//    TimerControllerStateStartTimerLongBreak = 4,
    
    TimerControllerStateTimerStopped,
    
//    TimerControllerStateChangeTask = 6,

};

@interface TimerController()

@property (nonatomic, assign) TimerControllerState currentState;
@property (nonatomic, assign) NSTimeInterval timerDuration;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *startTime;

@end



@implementation TimerController

+ (instancetype)sharedInstance
{
    static TimerController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TimerController alloc] init];
    });
    return sharedInstance;
}


-(void) startTimer
{
    [self processState:TimerControllerStatePendingStartTimer];
    
}


-(void) stopTimer
{
    [self processState:TimerControllerStatePendingStopTimer];
    
}


-(void) installTimerDuration:(NSTimeInterval)duration
{
    if (self.currentState == TimerControllerStateDefault ||
        self.currentState == TimerControllerStateTimerStopped){
        self.timerDuration = duration;
    } else {
        @throw [NSException exceptionWithName:NSStringFromClass([self class]) reason:@"invalid currentState" userInfo:nil];
    }
    
    
}


-(void)processState:(TimerControllerState)state
{
    switch (state) {
        case TimerControllerStateDefault:
            [self.delegate timerController:self timeDidChanged:self.timerDuration];
            [self.delegate timerControllerDidStop:self];
            break;
        case TimerControllerStatePendingStartTimer: {
            self.startTime = [NSDate date];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         repeats:YES
                                                           block:^(NSTimer * _Nonnull timer) {
                                                               [self processState:TimerControllerStateTimerStarted];
                                                           }];
            [self.delegate timerControllerDidStarted:self];
            break;
        }
        case TimerControllerStateTimerStarted:{
            NSTimeInterval timeIntervalLost = [[NSDate date] timeIntervalSinceDate:self.startTime];
            
            if (timeIntervalLost >= self.timerDuration){
                [self processState:TimerControllerStatePendingStopTimer];
                
            } else {
                [self.delegate timerController:self timeDidChanged:(self.timerDuration - timeIntervalLost)];
                
            };
    
            break;
        }
        case TimerControllerStatePendingStopTimer:{
            if (self.timer){
                [self.timer invalidate];
                self.timer = nil;
            }
            [self.delegate timerController:self timeDidChanged:0];
            [self processState:TimerControllerStateTimerStopped];
            break;
        }
        case TimerControllerStateTimerStopped:{
            [self.delegate timerController:self timeDidChanged:self.timerDuration];
            [self.delegate timerControllerDidStop:self];
            
            break;
        }
            
            
        default:
            break;
    }
    
    self.currentState = state;
}





@end
