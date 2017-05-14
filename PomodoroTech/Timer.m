//
//  Timer.m
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "Timer.h"


@interface Timer()

@property (nonatomic, strong) NSTimer *nsTimer;
@property (nonatomic, assign, readwrite) NSInteger timeToFinish;

@end


@implementation Timer


-(void) startTimerWithDuration:(NSInteger)durarion
{
    // time count to zero
    __block NSInteger timeBackCount = durarion;
    
    self.nsTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        timeBackCount--;
        self.timeToFinish = timeBackCount;
        
        if (!timeBackCount){
            [self stopTimer];
        }
    }];
    
}

-(void) stopTimer
{
    // stop time count
    if ([self.nsTimer isValid]){
        [self.nsTimer invalidate];
    }
    
    //DO еслил таймер еще работает и считает помидор, то остановить его и помедор не защитать.
    
    if (!self.timeToFinish){
        // сообщить другим, что таймер окончил свою работу
    }
    
}


@end
