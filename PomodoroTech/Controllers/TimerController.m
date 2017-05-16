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
    
    TimerControllerStateSetTimerDurationPomodor,
    TimerControllerStateSetTimerDurationShortBreak,
    TimerControllerStateSetTimerDurationLongBreak,
    
    TimerControllerStatePendingStartTimer,
    
    TimerControllerStateTimerStarted,
    TimerControllerStatePendingStopTimer,
    TimerControllerStateTimerStopped,
    
    //TimerControllerStateSetDurationTimerPomodor = 1,
    
//    TimerControllerStateStartTimerPomodor = 1,
//    TimerControllerStateStartTimerShortBreak = 3,
//    TimerControllerStateStartTimerLongBreak = 4,
    
//    TimerControllerStateChangeTask = 6,

};

@interface TimerController()

@property (nonatomic, assign) TimerControllerState currentState;
@property (nonatomic, assign) NSTimeInterval timerDuration;
@property (nonatomic, assign) NSTimeInterval timerDurationPomodor;
@property (nonatomic, assign) NSTimeInterval timerDurationShortBreak;
@property (nonatomic, assign) NSTimeInterval timerDurationLongBreak;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *startTime;

@property (nonatomic, assign) NSInteger quantityOfShortBreak;

@end



@implementation TimerController

static const int MIN = 60;
- (NSTimeInterval)timerDurationShortBreak
{
    if (!_timerDurationShortBreak){
        _timerDurationShortBreak = 2 * MIN;
    }
    return _timerDurationShortBreak;
}


- (NSTimeInterval)timerDurationLongBreak
{
    if (!_timerDurationLongBreak){
        _timerDurationLongBreak = 3 * MIN;
    }
    return _timerDurationLongBreak;
}


+ (instancetype)sharedInstance
{
    static TimerController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TimerController alloc] init];
    });
    return sharedInstance;
}


- (void)startTimerWithDurationPomodor:(NSTimeInterval)durationPomodor
{
    self.timerDurationPomodor = durationPomodor;
    [self installTimerDuration:durationPomodor];
    [self processState:TimerControllerStatePendingStartTimer];
    
}


- (void)startTimerWithDurationBreak:(NSTimeInterval)durationBreak
{
    [self installTimerDuration:durationBreak];
    [self processState:TimerControllerStatePendingStartTimer];
    
}


- (void)stopTimer
{
    [self processState:TimerControllerStatePendingStopTimer];
    
}


- (void)installTimerDuration:(NSTimeInterval)duration
{
    if (self.currentState != TimerControllerStateTimerStarted){
        self.timerDuration = duration;
    } else {
        @throw [NSException exceptionWithName:NSStringFromClass([self class]) reason:@"invalid currentState" userInfo:nil];
    }
}


-(void)processState:(TimerControllerState)state
{
    switch (state) {
            
        case TimerControllerStateDefault:
            self.currentState = state;
            [self.delegate timerController:self timeDidChanged:self.timerDurationPomodor];
            [self.delegate timerControllerDidStop:self];
            break;
            
        case TimerControllerStatePendingStartTimer: {
            self.currentState = state;
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
            self.currentState = state;
            NSTimeInterval timeIntervalLost = [[NSDate date] timeIntervalSinceDate:self.startTime];
            
            if (timeIntervalLost >= self.timerDuration){
                [self processState:TimerControllerStatePendingStopTimer];
                
            } else {
                [self.delegate timerController:self timeDidChanged:(self.timerDuration - timeIntervalLost)];
                
            };
    
            break;
        }
            
        case TimerControllerStatePendingStopTimer:{
            self.currentState = state;
           
            if (self.timer){
                [self.timer invalidate];
                self.timer = nil;
            }

            if (self.timerDuration == self.timerDurationPomodor){
                if (self.quantityOfShortBreak < 4){
                    self.quantityOfShortBreak++;
                    [self startTimerWithDurationBreak:self.timerDurationShortBreak];
                } else {
                    self.quantityOfShortBreak = 0;
                    [self startTimerWithDurationBreak:self.timerDurationLongBreak];
                }
            } else {
                [self.delegate timerController:self timeDidChanged:0];
                [self processState:TimerControllerStateTimerStopped];
            };
            
            break;
        }
            
        case TimerControllerStateTimerStopped:{
            self.currentState = state;
            [self.delegate timerController:self timeDidChanged:self.timerDurationPomodor];
            [self.delegate timerControllerDidStop:self];
            
            break;
        }
            
        default:
            break;
    }
    
}





@end
